import 'package:flutter/material.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    required this.title,
    required this.body,
    this.actions,
    super.key,
  });
  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    body: SafeArea(child: body),
  );
}
