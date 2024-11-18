import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/view/feed_write.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  title: Text(
                    'Test $index',
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => Get.to(() => const FeedWrite()),
              child: const Text(
                '게시글 작성',
              ),
            ),
          )
        ],
      ),
    );
  }
}
