import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../controllers/users_controller.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final UsersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<UsersController>();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _roleLabel(String role) {
    switch (role) {
      case AppConstants.ownerRole:
        return 'Admin';
      case AppConstants.employeeRole:
        return 'Employee';
      case AppConstants.technicianRole:
        return 'Technician';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      title: 'Users & Roles',
      body: Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: 'Pending Approval'),
              Tab(text: 'All Users'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                // ── Pending tab ──────────────────────────────────────────
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.pendingUsers.isEmpty) {
                    return const EmptyStateView(
                      title: 'No pending approvals',
                      message: 'New sign-ins waiting for admin approval will appear here.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: controller.pendingUsers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, int index) {
                      final user = controller.pendingUsers[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                user.name.isEmpty ? user.email : user.name,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(user.email,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  )),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  FilledButton(
                                    onPressed: () => controller.approve(
                                        user, AppConstants.employeeRole),
                                    child: const Text('Approve as Employee'),
                                  ),
                                  FilledButton(
                                    onPressed: () => controller.approve(
                                        user, AppConstants.technicianRole),
                                    child: const Text('Approve as Technician'),
                                  ),
                                  FilledButton(
                                    onPressed: () => controller.approve(
                                        user, AppConstants.ownerRole),
                                    child: const Text('Approve as Admin'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => controller.blockUser(user),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.error,
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),

                // ── All Users tab ─────────────────────────────────────────
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.users.isEmpty) {
                    return const EmptyStateView(
                      title: 'No users found',
                      message: 'Approved and blocked users will appear here.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: controller.users.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, int index) {
                      final user = controller.users[index];
                      final bool isBlocked =
                          user.status == AppConstants.blockedStatus;
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            user.name.isEmpty ? user.email : user.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(user.email),
                                const SizedBox(height: 2),
                                Row(
                                  children: <Widget>[
                                    _RoleChip(_roleLabel(user.role)),
                                    const SizedBox(width: 6),
                                    _StatusChip(user.status, isBlocked),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (String value) {
                              if (value == 'block') {
                                controller.blockUser(user);
                              } else if (value == 'unblock') {
                                controller.unblockUser(user);
                              } else {
                                controller.changeRole(user, value);
                              }
                            },
                            itemBuilder: (_) => <PopupMenuEntry<String>>[
                              const PopupMenuItem(
                                value: AppConstants.ownerRole,
                                child: Text('Make Admin'),
                              ),
                              const PopupMenuItem(
                                value: AppConstants.employeeRole,
                                child: Text('Make Employee'),
                              ),
                              const PopupMenuItem(
                                value: AppConstants.technicianRole,
                                child: Text('Make Technician'),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: isBlocked ? 'unblock' : 'block',
                                child: Text(
                                  isBlocked ? 'Unblock' : 'Block',
                                  style: TextStyle(
                                      color: isBlocked
                                          ? null
                                          : theme.colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status, this.isBlocked);
  final String status;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    final color = isBlocked
        ? Theme.of(context).colorScheme.errorContainer
        : Theme.of(context).colorScheme.primaryContainer;
    final textColor = isBlocked
        ? Theme.of(context).colorScheme.onErrorContainer
        : Theme.of(context).colorScheme.onPrimaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
