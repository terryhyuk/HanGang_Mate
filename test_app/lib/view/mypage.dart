import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_app/VM/test.dart';

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
            User? user = await AuthService().signInWithGoogle();
            if (user != null) {
              print('로그인 성공: ${user.displayName}');
            } else {
              print('로그인 실패');
            }
          },
        ),
      ),
    );
  }
}
