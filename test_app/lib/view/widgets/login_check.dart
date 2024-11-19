import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/vm/login_handler.dart';

class LoginCheck extends GetView<LoginHandler> {
  final String message;

  const LoginCheck({
    super.key,
    this.message = '이 기능을 사용하려면 로그인이 필요합니다.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => controller.signInWithGoogle(),
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }
}
