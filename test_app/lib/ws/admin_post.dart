import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:test_app/ws/answer_handler.dart';

class AdminPost extends StatelessWidget {
  AdminPost({super.key});
  final TextEditingController titleController = TextEditingController();
  final TextEditingController qsController = TextEditingController();
  final TextEditingController awController = TextEditingController();
  final adminHandler = Get.put(AnswerHandler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('답변하기'),
      ),
      body: GetBuilder<AnswerHandler>(
        builder: (controller) {
        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding:  EdgeInsets.fromLTRB(10,5,10,10),
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
                                  color: Colors.black, // Border color
                                  width: 0.5, // Border width
                                ),
                              ),
                              child: Text('지점: 지점명')),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black, // Border color
                            width: 0.5, // Border width
                          ),
                        ),
                        child: TextField(
                          controller: titleController,
                          readOnly: true,
                          maxLines: null,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20,0,0,0),
                              hintText: '문의 제목',
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none),
                        )),
                  ),                
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('작성자: '),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black, // Border color
                              width: 0.5, // Border width
                            ),
                          ),
                          child: TextField(
                            controller: qsController,
                            readOnly: true,
                            maxLines: null,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                hintText: '문의내용',
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none),
                          )),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black, // Border color
                            width: 0.5, // Border width
                          ),
                        ),
                        child: TextField(
                          controller: awController,
                          maxLines: null,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              hintText: '답변을 입력해주세요.',
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC3D974),
                                  foregroundColor: Colors.black
                                ),                                        
                      onPressed: () async{
                        await answerAction('답변완료', awController.text, 0);
                      }, 
                      child: Text('작성완료')),
                  )
                ],
              ),
            ),
          ),
        );
        }
      ),
    );
  }
  answerAction(String complete, String answer, int seq) async {
    var result = await adminHandler.answerJSONData(complete, answer, seq);
    if (result == 'OK') {
      Get.back();
    } else {
      errorSnackBar();
      print('Error');
    }
  }  
  errorSnackBar() {
    Get.snackbar('Error', '다시 확인해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color.fromARGB(255, 206, 53, 42),
        colorText: Colors.white);
  }    
}
