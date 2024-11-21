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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      itemCount: controller.posts.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final post = controller.posts[index];
                        return Card(
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                            title: Text(
                              post.question,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: screenHeight * 0.01),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        formatDate(post.date),
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      post.public == 'Y'
                                          ? Icons.public
                                          : Icons.lock,
                                      size: screenWidth * 0.04,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Text(
                                      post.complete == 'Y' ? '답변완료' : '답변대기',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                      ),
                                    ),
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
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 페이지 컨트롤 - 중앙 배치
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      iconSize: screenWidth * 0.06,
                      onPressed: () => controller.previousPage(),
                    ),
                    Obx(() => Text(
                          '${controller.currentPage.value} / ${controller.totalPages.value}',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        )),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      iconSize: screenWidth * 0.06,
                      onPressed: () => controller.nextPage(),
                    ),
                  ],
                ),
                // 문의등록 버튼 - 오른쪽 배치
                Positioned(
                  right: 0,
                  child: SizedBox(
                    width: screenWidth * 0.3,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Get.to(() => PostWrite());
                        if (result == true) {
                          controller.getPosts();
                        }
                      },
                      label: Text(
                        '문의등록',
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
