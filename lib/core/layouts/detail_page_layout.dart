import 'package:flutter/material.dart';

class DetailPageLayout extends StatelessWidget {
  const DetailPageLayout({
    required this.child,
    this.backgroundColor,
    super.key,
  });
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor,
    body: SafeArea(child: child),
  );
}
