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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'User Approval & Roles',
      body: Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: 'Pending'),
              Tab(text: 'All Users'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.pendingUsers.isEmpty) {
                    return const EmptyStateView(
                      title: 'No pending approvals',
                      message: 'New sign-ins waiting for owner approval will show here.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: controller.pendingUsers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final user = controller.pendingUsers[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(user.name.isEmpty ? user.email : user.name),
                              const SizedBox(height: 4),
                              Text(user.email),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: () => controller.approve(
                                      user,
                                      AppConstants.employeeRole,
                                    ),
                                    child: const Text('Approve as Employee'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => controller.approve(
                                      user,
                                      AppConstants.technicianRole,
                                    ),
                                    child: const Text('Approve as Technician'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => controller.approve(
                                      user,
                                      AppConstants.ownerRole,
                                    ),
                                    child: const Text('Approve as Owner'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => controller.blockUser(user),
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
                    itemBuilder: (BuildContext context, int index) {
                      final user = controller.users[index];
                      final bool isBlocked = user.status == AppConstants.blockedStatus;
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(user.name.isEmpty ? user.email : user.name),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('${user.email}\n${user.role} - ${user.status}'),
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
                                child: Text('Make owner'),
                              ),
                              const PopupMenuItem(
                                value: AppConstants.employeeRole,
                                child: Text('Make employee'),
                              ),
                              const PopupMenuItem(
                                value: AppConstants.technicianRole,
                                child: Text('Make technician'),
                              ),
                              PopupMenuItem(
                                value: isBlocked ? 'unblock' : 'block',
                                child: Text(isBlocked ? 'Unblock user' : 'Block user'),
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
