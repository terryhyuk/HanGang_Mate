import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:test_app/Model/message.dart';
import 'package:test_app/vm/chating_controller.dart';
import 'package:test_app/vm/login_handler.dart';

class ChatScreen extends StatelessWidget {
  final String roomId;
  final String userEmail;

  ChatScreen({
    Key? key,
    required this.roomId,
    required this.userEmail,
  }) : super(key: key);

  final ChatController chatController = Get.find<ChatController>();
  final LoginHandler loginHandler = Get.find<LoginHandler>();
  final TextEditingController sendController = TextEditingController();
  final ScrollController scrollController =
      ScrollController(); // ScrollController 추가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('${userEmail}님과의 1:1 문의'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => logoutChat(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          DateChip(
            date: DateTime.now(),
            color: const Color.fromARGB(255, 221, 241, 194),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: scrollController, // ScrollController 설정
                reverse: false, // 최신 메시지를 아래에 표시
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  Message message = chatController.messages[index];
                  bool isMessageFromCurrentUser =
                      message.userEmail == loginHandler.userEmail.value;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: isMessageFromCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        BubbleSpecialThree(
                          text: message.content,
                          color: isMessageFromCurrentUser
                              ? const Color.fromARGB(255, 71, 168, 248)
                              : const Color.fromARGB(255, 172, 172, 172),
                          tail: true,
                          isSender: isMessageFromCurrentUser,
                          textStyle: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          DateFormat('h:mm a').format(message.timestamp),
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.07,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Color.fromARGB(8, 0, 0, 0), blurRadius: 10)
                ],
              ),
              child: TextField(
                controller: sendController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () => sendMessage(),
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    iconSize: 25,
                  ),
                  hintText: "메시지를 입력하세요",
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  void sendMessage() {
    if (sendController.text.isNotEmpty) {
      chatController.sendMessage(
        roomId,
        sendController.text,
        loginHandler.userEmail.value,
      );
      sendController.clear();

      // 새로운 메시지를 보낸 후 스크롤을 맨 아래로 이동
      Future.delayed(Duration(milliseconds: 100), () {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    }
  }

  void logoutChat() {
    Get.dialog(
      AlertDialog(
        title: const Text('채팅방 나가기'),
        content: const Text('채팅 내역이 모두 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('확인'),
            onPressed: () async {
              await chatController.deleteChatHistory(roomId);
              Get.back();
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
