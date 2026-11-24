import 'package:flutter/material.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({required this.label, this.color, super.key});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color ?? Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      child: Text(label),
    ),
  );
}
