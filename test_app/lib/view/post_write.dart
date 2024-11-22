import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:RiverPark_Mate/Model/parking.dart';
import 'package:RiverPark_Mate/model/post_request.dart';
import 'package:RiverPark_Mate/vm/location_handler.dart';
import 'package:RiverPark_Mate/vm/post_handler.dart';
import 'package:RiverPark_Mate/vm/login_handler.dart';
import 'package:RiverPark_Mate/constants/theme.dart';

class PostWrite extends GetView<PostHandler> {
  PostWrite({super.key});

  final LocationHandler _locationHandler = Get.find<LocationHandler>();
  final LoginHandler _loginHandler = Get.find<LoginHandler>();
  final TextEditingController questionController = TextEditingController();

  Map<String, dynamic> getTimeBasedStyle() {
    final currentTime = DateTime.now().hour;
    if (currentTime >= 6 && currentTime < 12) {
      return {"message": "문의글 작성", "color": morningClr};
    } else if (currentTime >= 12 && currentTime < 17) {
      return {"message": "문의글 작성", "color": afternoonClr};
    } else if (currentTime >= 17 && currentTime < 24) {
      return {"message": "문의글 작성", "color": eveningClr};
    } else {
      return {"message": "문의글 작성", "color": nightClr};
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
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    children: [
                      // 공원 선택 드롭다운
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: '공원 선택',
                                labelStyle: const TextStyle(color: infoTextClr),
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
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: infoTextClr,
                                    ),
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
                                labelStyle: const TextStyle(color: infoTextClr),
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
                                  .map<DropdownMenuItem<String>>(
                                      (Parking park) {
                                return DropdownMenuItem<String>(
                                  value: park.pname,
                                  child: Text(
                                    park.pname,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: infoTextClr,
                                    ),
                                  ),
                                );
                              }).toList(),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // 내용 입력 필드
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: TextField(
                    controller: questionController,
                    decoration: InputDecoration(
                      labelText: '내용을 입력하세요.',
                      labelStyle: const TextStyle(color: infoTextClr),
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.02,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: infoTextClr,
                    ),
                    maxLines: 10,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // 공개/비공개 라디오 버튼
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Obx(() => Radio<String>(
                                value: 'Y',
                                groupValue: controller.isPublic.value,
                                onChanged: (String? value) {
                                  if (value != null) {
                                    controller.isPublic.value = value;
                                  }
                                },
                              )),
                          Text(
                            '공개',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: infoTextClr,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: screenWidth * 0.08),
                      Row(
                        children: [
                          Obx(() => Radio<String>(
                                value: 'N',
                                groupValue: controller.isPublic.value,
                                onChanged: (String? value) {
                                  if (value != null) {
                                    controller.isPublic.value = value;
                                  }
                                },
                              )),
                          Text(
                            '비공개',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: infoTextClr,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // 게시글 올리기 버튼
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.5, screenHeight * 0.06),
                    backgroundColor: style["color"],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                    '문의등록',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                    ),
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
