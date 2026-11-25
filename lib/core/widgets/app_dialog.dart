import 'package:flutter/material.dart';

abstract final class AppDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
  }) => showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(title: Text(title), content: content),
  );
}
