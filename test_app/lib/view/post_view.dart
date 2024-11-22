import 'package:flutter/material.dart';
import 'package:RiverPark_Mate/model/posting.dart';
import 'package:RiverPark_Mate/constants/theme.dart';

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

  Map<String, dynamic> getTimeBasedStyle() {
    final currentTime = DateTime.now().hour;
    if (currentTime >= 6 && currentTime < 12) {
      return {"message": "게시글 상세", "color": morningClr};
    } else if (currentTime >= 12 && currentTime < 17) {
      return {"message": "게시글 상세", "color": afternoonClr};
    } else if (currentTime >= 17 && currentTime < 24) {
      return {"message": "게시글 상세", "color": eveningClr};
    } else {
      return {"message": "게시글 상세", "color": nightClr};
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final style = getTimeBasedStyle();

    return Scaffold(
      backgroundColor: backClr,
      appBar: AppBar(
        backgroundColor: backClr,
        title: Text(
          style["message"],
          style: TextStyle(
            color: style["color"],
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메타 정보 카드
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black),
              ),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '작성자: ${post.userEmail}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: infoTextClr,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    if (post.hname != null) ...[
                      Text(
                        '공원: ${post.hname}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: infoTextClr,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                    if (post.pname != null) ...[
                      Text(
                        '주차장: ${post.pname}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: infoTextClr,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDate(post.date),
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: infoTextClr,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              post.public == 'Y' ? Icons.public : Icons.lock,
                              size: screenWidth * 0.05,
                              color: infoTextClr,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              post.complete == 'Y' ? '답변완료' : '답변대기',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: post.complete == 'Y'
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
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
            const Text(
              '문의내용',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: infoTextClr,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black),
              ),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Text(
                  post.question,
                  style: const TextStyle(
                    fontSize: 16,
                    color: infoTextClr,
                  ),
                ),
              ),
            ),

            // 답변 섹션
            SizedBox(height: screenHeight * 0.02),
            const Text(
              '답변',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: infoTextClr,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black),
              ),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Text(
                  post.answer ?? '아직 답변이 등록되지 않았습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: post.answer != null ? infoTextClr : Colors.grey,
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
