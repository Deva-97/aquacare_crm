import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color resolvedColor = color ?? Theme.of(context).colorScheme.primary;
    return Chip(
      label: Text(label),
      backgroundColor: resolvedColor.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: resolvedColor,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
