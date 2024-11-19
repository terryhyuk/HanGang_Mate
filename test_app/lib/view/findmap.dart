import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/vm/login_handler.dart';

class Findmap extends GetView<LoginHandler> {
  const Findmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Map'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await controller.signOut();
          },
          child: const Text(
            '로그아웃',
          ),
        ),
      ),
    );
  }
}
