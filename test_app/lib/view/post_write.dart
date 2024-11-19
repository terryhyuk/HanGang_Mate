import 'package:flutter/material.dart';

class PostWrite extends StatelessWidget {
  const PostWrite({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> parks = [
      '망원한강공원',
      '강서한강공원',
      '난지한강공원',
      '이촌한강공원',
      '뚝섬한강공원'
    ];
    String selectedPark = parks[0];
    bool isPublic = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 공원 선택 드롭다운
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '공원 선택'),
              value: selectedPark,
              onChanged: (String? newValue) {
                // 공원 선택 시 처리
              },
              items: parks.map<DropdownMenuItem<String>>((String park) {
                return DropdownMenuItem<String>(
                  value: park,
                  child: Text(park),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 제목 입력 필드
            const TextField(
              decoration: InputDecoration(
                labelText: '제목을 입력하세요.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 내용 입력 필드
            const TextField(
              decoration: InputDecoration(
                labelText: '내용을 입력하세요.',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 16),

            // 공개/비공개 라디오 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isPublic,
                      onChanged: (bool? value) {
                        // 공개 선택 시 처리
                      },
                    ),
                    const Text('공개'),
                  ],
                ),
                Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: isPublic,
                      onChanged: (bool? value) {
                        // 비공개 선택 시 처리
                      },
                    ),
                    const Text('비공개'),
                  ],
                )
              ],
            ),

            // 게시글 올리기 버튼
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.lightGreen,
                    // foregroundColor: Colors.white,
                    ),
                onPressed: () {
                  // 게시글 올리기 처리
                },
                child: const Text(
                  '게시글 올리기',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
