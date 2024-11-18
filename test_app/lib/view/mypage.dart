import 'package:flutter/material.dart';
import 'package:test_app/vm/login_handler.dart';

class Mypage extends StatelessWidget {
  const Mypage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mypage'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Google로 로그인'),
          onPressed: () async {
            await LoginHandler().signInWithGoogle();
          },
        ),
      ),
    );
  }
}
