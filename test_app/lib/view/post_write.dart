import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/Model/parking.dart';
import 'package:test_app/model/post_request.dart';
import 'package:test_app/vm/location_handler.dart';
import 'package:test_app/vm/post_handler.dart';
import 'package:test_app/vm/login_handler.dart';

class PostWrite extends GetView<PostHandler> {
  PostWrite({super.key});

  final LocationHandler _locationHandler = Get.find<LocationHandler>();
  final LoginHandler _loginHandler = Get.find<LoginHandler>();
  final TextEditingController questionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 공원 선택 드롭다운
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '공원 선택',
                            border: OutlineInputBorder(),
                          ),
                          value: _locationHandler.selectHname.value,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _locationHandler.selectHname.value = newValue;
                              _locationHandler.getParkingLoc();
                            }
                          },
                          items: _locationHandler.hnameList
                              .cast<String>()
                              .map<DropdownMenuItem<String>>((String park) {
                            return DropdownMenuItem<String>(
                              value: park,
                              child: Text(park),
                            );
                          }).toList(),
                        )),
                  ),
                  const SizedBox(width: 16),
                  // 주차장 선택 드롭다운
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: '주차장 선택',
                            border: OutlineInputBorder(),
                          ),
                          value: _locationHandler.parkingInfo.isNotEmpty
                              ? _locationHandler.parkingInfo[0].pname
                              : '',
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              // 선택된 주차장 처리
                            }
                          },
                          items: _locationHandler.parkingInfo
                              .map<DropdownMenuItem<String>>((Parking park) {
                            return DropdownMenuItem<String>(
                              value: park.pname,
                              child: Text(park.pname),
                            );
                          }).toList(),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 내용 입력 필드
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
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
                      Obx(() => Radio<bool>(
                            value: true,
                            groupValue: controller.isPublic.value,
                            onChanged: (bool? value) {
                              if (value != null) {
                                controller.isPublic.value = value;
                              }
                            },
                          )),
                      const Text('공개'),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Row(
                    children: [
                      Obx(() => Radio<bool>(
                            value: false,
                            groupValue: controller.isPublic.value,
                            onChanged: (bool? value) {
                              if (value != null) {
                                controller.isPublic.value = value;
                              }
                            },
                          )),
                      const Text('비공개'),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 32),

              // 게시글 올리기 버튼
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: () async {
                    // 입력값 검증
                    if (questionController.text.trim().isEmpty) {
                      Get.snackbar(
                        '오류',
                        '내용을 입력하세요.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red[100],
                        duration: const Duration(seconds: 2),
                      );
                      return;
                    }

                    // 확인 다이얼로그 표시
                    final confirmed = await Get.dialog<bool>(
                      AlertDialog(
                        title: const Text('확인'),
                        content: const Text('게시글을 등록하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            style: TextButton.styleFrom(
                                // foregroundColor: Colors.blue,
                                ),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      final request = PostRequest(
                        userEmail: _loginHandler.userEmail.value,
                        hname: _locationHandler.selectHname.value,
                        question: questionController.text.trim(),
                      );

                      final success = await controller.submitPost(request);
                      if (success) {
                        Get.back();
                      }
                    }
                  },
                  child: const Text('게시글 올리기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
