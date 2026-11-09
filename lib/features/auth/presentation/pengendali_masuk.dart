import 'package:flutter/widgets.dart';

class LoginController {
  void submit(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}