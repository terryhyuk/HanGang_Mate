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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 공원 선택 드롭다운
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '공원 선택',
                            border: const OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.02,
                            ),
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
                              child: Text(
                                park,
                                style: TextStyle(fontSize: screenWidth * 0.035),
                              ),
                            );
                          }).toList(),
                        )),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  // 주차장 선택 드롭다운
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: '주차장 선택',
                            border: const OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.02,
                            ),
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
                              child: Text(
                                park.pname,
                                style: TextStyle(fontSize: screenWidth * 0.035),
                              ),
                            );
                          }).toList(),
                        )),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              // 내용 입력 필드
              TextField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: '내용을 입력하세요.',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.02,
                  ),
                ),
                style: TextStyle(fontSize: screenWidth * 0.035),
                maxLines: 10,
              ),
              SizedBox(height: screenHeight * 0.02),

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
                      Text(
                        '공개',
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.08),
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
                      Text(
                        '비공개',
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                    ],
                  )
                ],
              ),

              SizedBox(height: screenHeight * 0.04),

              // 게시글 올리기 버튼
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.5, screenHeight * 0.06),
                  ),
                  onPressed: () async {
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

                    final confirmed = await Get.dialog<bool>(
                      AlertDialog(
                        title: Text(
                          '확인',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                        content: Text(
                          '게시글을 등록하시겠습니까?',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: Text(
                              '취소',
                              style: TextStyle(fontSize: screenWidth * 0.035),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.back(result: true),
                            child: Text(
                              '확인',
                              style: TextStyle(fontSize: screenWidth * 0.035),
                            ),
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
                        Get.back(result: true);
                        Get.snackbar(
                          '성공',
                          '게시글이 등록되었습니다.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green[100],
                          duration: const Duration(seconds: 2),
                        );
                      }
                    }
                  },
                  child: Text(
                    '게시글 올리기',
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
