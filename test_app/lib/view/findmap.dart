import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/vm/login_handler.dart';
import 'package:test_app/ws/admin_post.dart';

class Findmap extends GetView<LoginHandler> {
  const Findmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그아웃'),
        actions: [
          IconButton(
              onPressed: () => Get.to(AdminPost()), icon: const Icon(Icons.add))
        ],
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
