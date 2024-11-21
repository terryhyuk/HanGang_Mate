import 'package:flutter/material.dart';
import 'package:test_app/model/posting.dart';

class PostView extends StatelessWidget {
  final Posting post;

  const PostView({super.key, required this.post});

  String formatDate(String? date) {
    if (date == null) return '';

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
    final baseFontSize = screenWidth * 0.035;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 작성자 정보
                    Text(
                      '작성자: ${post.userEmail}',
                      style: TextStyle(
                        fontSize: baseFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // 주차장 정보
                    if (post.hname != null) ...[
                      Text(
                        '공원: ${post.hname}',
                        style: TextStyle(
                          fontSize: baseFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                    if (post.pname != null) ...[
                      Text(
                        '주차장: ${post.pname}',
                        style: TextStyle(
                          fontSize: baseFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                    ],

                    // 작성일자와 상태
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            formatDate(post.date),
                            style: TextStyle(
                              fontSize: baseFontSize,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              post.public == 'Y' ? Icons.public : Icons.lock,
                              size: baseFontSize * 1.2,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              post.complete == 'Y' ? '답변완료' : '답변대기',
                              style: TextStyle(
                                fontSize: baseFontSize,
                                color: post.complete == 'Y'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // 문의 내용
            Text(
              '문의내용',
              style: TextStyle(
                fontSize: baseFontSize * 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Card(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Text(
                  post.question,
                  style: TextStyle(fontSize: baseFontSize * 1.1),
                ),
              ),
            ),

            // 답변 섹션
            SizedBox(height: screenHeight * 0.02),
            Text(
              '답변',
              style: TextStyle(
                fontSize: baseFontSize * 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Card(
              color: post.answer != null ? Colors.blue[50] : Colors.grey[50],
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Text(
                  post.answer ?? '아직 답변이 등록되지 않았습니다.',
                  style: TextStyle(
                    fontSize: baseFontSize * 1.1,
                    color:
                        post.answer != null ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
