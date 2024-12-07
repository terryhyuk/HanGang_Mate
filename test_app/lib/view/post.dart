import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RiverPark_Mate/constants/theme.dart';
import 'package:RiverPark_Mate/view/post_view.dart';
import 'package:RiverPark_Mate/view/post_write.dart';
import 'package:RiverPark_Mate/vm/post_handler.dart';
import 'package:RiverPark_Mate/vm/login_handler.dart';
import 'package:RiverPark_Mate/ws/admin_post.dart';

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

  // 시간대별 메시지와 색상 반환 함수
  Map<String, dynamic> getTimeBasedStyle() {
    final currentTime = DateTime.now().hour;
    if (currentTime >= 6 && currentTime < 12) {
      return {
        "message": "문의 게시판",
        "color": morningClr,
      };
    } else if (currentTime >= 12 && currentTime < 17) {
      return {
        "message": "문의 게시판",
        "color": afternoonClr,
      };
    } else if (currentTime >= 17 && currentTime < 24) {
      return {
        "message": "문의 게시판",
        "color": eveningClr,
      };
    } else {
      return {
        "message": "문의 게시판",
        "color": nightClr,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final LoginHandler loginHandler = Get.find<LoginHandler>();
    final style = getTimeBasedStyle();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getPosts();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backClr,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            style["message"],
            style: TextStyle(
              color: style["color"],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      backgroundColor: backClr,
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      itemCount: controller.posts.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: screenHeight * 0.01),
                      itemBuilder: (context, index) {
                        final post = controller.posts[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.black),
                          ),
                          elevation: 0,
                          color: Colors.white,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(screenWidth * 0.04),
                            title: Text(
                              post.question,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: infoTextClr,
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
                                          color: infoTextClr,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      post.public == 'Y'
                                          ? Icons.public
                                          : Icons.lock,
                                      size: screenWidth * 0.04,
                                      color: infoTextClr,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    GestureDetector(
                                      onTap: loginHandler.isObserver == 'Y'
                                          ? () => Get.to(() => AdminPost(),
                                              arguments: post.seq)
                                          : null,
                                      child: Text(
                                        post.complete == 'Y' ? '답변완료' : '답변대기',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: post.complete == 'Y'
                                              ? Colors.green
                                              : Colors.orange,
                                          decoration:
                                              loginHandler.isObserver == 'Y'
                                                  ? TextDecoration.underline
                                                  : TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () => Get.to(() => PostView(post: post)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: infoTextClr),
                      iconSize: screenWidth * 0.06,
                      onPressed: () => controller.previousPage(),
                    ),
                    Obx(() => Text(
                          '${controller.currentPage.value} / ${controller.totalPages.value}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: infoTextClr,
                          ),
                        )),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: infoTextClr),
                      iconSize: screenWidth * 0.06,
                      onPressed: () => controller.nextPage(),
                    ),
                  ],
                ),
                if (loginHandler.isObserver != 'Y') ...[
                  Positioned(
                    right: 0,
                    child: SizedBox(
                      width: screenWidth * 0.3,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: style["color"],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
