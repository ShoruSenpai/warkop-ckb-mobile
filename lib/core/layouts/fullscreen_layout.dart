import 'package:flutter/material.dart';

class FullscreenLayout extends StatelessWidget {
  const FullscreenLayout({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(body: child);
}
