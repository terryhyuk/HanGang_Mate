import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/view/post_write.dart';

class Post extends StatelessWidget {
  const Post({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 게시판'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(() => PostWrite());
              },
              child: const Text('문의등록'),
            ),
          ],
        ),
      ),
    );
  }
}
