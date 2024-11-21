import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/view/post_write.dart';
import 'package:test_app/vm/post_handler.dart';

class Post extends GetView<PostHandler> {
  const Post({super.key});

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getPosts();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 게시판'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.posts.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final post = controller.posts[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              post.question,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(formatDate(post.date)),
                                    const Spacer(),
                                    Icon(
                                      post.public == 'Y'
                                          ? Icons.public
                                          : Icons.lock,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        post.complete == 'Y' ? '답변완료' : '답변대기'),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              // 게시글 상세보기 구현 예정
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => controller.previousPage(),
                    ),
                    Obx(() => Text(
                        '${controller.currentPage.value} / ${controller.totalPages.value}')),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => controller.nextPage(),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Get.to(() => PostWrite());
                    if (result == true) {
                      controller.getPosts();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('문의등록'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
