import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/ws/answer_handler.dart';

class AdminPost extends GetView<AnswerHandler> {
  AdminPost({super.key}) {
    Get.put(AnswerHandler());
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController qsController = TextEditingController();
  final TextEditingController awController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var seq = Get.arguments ?? 26;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.showPostJSONData(seq);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('답변하기'),
      ),
      body: Obx(() {
        if (controller.post.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        qsController.text = controller.post.value[2];
        awController.text = controller.post.value[3] ?? '';

        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 120,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Text('주차장: ${controller.post.value[1]}'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('작성자: ${controller.post.value[0].split('@')[0]}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 0.8,
                          ),
                        ),
                        child: TextField(
                          controller: qsController,
                          readOnly: true,
                          maxLines: null,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(20),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 0.8,
                        ),
                      ),
                      child: TextField(
                        controller: awController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(20),
                          hintText: '답변을 입력하세요',
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC3D974),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        await answerAction('Y', awController.text, seq);
                      },
                      child: const Text('작성완료'),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  answerAction(String complete, String answer, int seq) async {
    var result = await controller.answerJSONData(complete, answer, seq);
    if (result == 'OK') {
      Get.back(result: true);
      Get.snackbar(
        '성공',
        '답변이 등록되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        '다시 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 206, 53, 42),
        colorText: Colors.white,
      );
    }
  }
}
