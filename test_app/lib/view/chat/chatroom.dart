import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:test_app/Model/message.dart';
import 'package:test_app/vm/chating_controller.dart';
import 'package:test_app/vm/login_handler.dart';

class ChatScreen extends StatelessWidget {
  final String roomId;
  final String userEmail;

  ChatScreen({
    super.key,
    required this.roomId,
    required this.userEmail,
  });

  final ChatController chatController = Get.find<ChatController>();
  final LoginHandler loginHandler = Get.find<LoginHandler>();
  final TextEditingController sendController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // print(loginHandler.box.read('observer'));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('$roomId님의 1:1 문의'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              logoutChat();
            },
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
                reverse: false, // 변경: true에서 false로
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  Message message = chatController.messages[index];
                  bool isCurrentUserObserver =
                      chatController.isObserver.value == 'T';
                  bool isMessageFromObserver = message.observer == 'T';
                  bool shouldAlignRight = isCurrentUserObserver
                      ? isMessageFromObserver
                      : !isMessageFromObserver;
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: shouldAlignRight
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: shouldAlignRight
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            BubbleSpecialThree(
                              text: message.content,
                              color: shouldAlignRight
                                  ? const Color.fromARGB(255, 71, 168, 248)
                                  : const Color.fromARGB(255, 172, 172, 172),
                              tail: true,
                              textStyle: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
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
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    iconSize: 25,
                  ),
                  hintText: "Type your message here",
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  sendMessage() {
    if (sendController.text.isNotEmpty) {
      String userEmail = loginHandler.box.read('userEmail');
      chatController.sendMessage(
        roomId,
        sendController.text,
        userEmail,
      );
      sendController.clear();
    }
  }

  logoutChat() {
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
