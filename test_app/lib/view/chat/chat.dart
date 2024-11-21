import 'package:flutter/material.dart';
import 'package:test_app/view/chat/chatroom.dart';
import 'package:test_app/vm/chating_controller.dart';
import 'package:get/get.dart';
import 'package:test_app/vm/login_handler.dart';

class Chat extends StatelessWidget {
  Chat({super.key});

  final ChatController chatController = Get.put(ChatController());
  final LoginHandler loginHandler = LoginHandler();

  @override
  Widget build(BuildContext context) {
    // print(loginHandler.box.read('userEmail'));
    // print(loginHandler.box.read('observer'));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('1:1 문의'),
        centerTitle: false,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('1:1 문의하기'),
          onPressed: () {
            final currentUserEmail = loginHandler.box.read('userEmail');
            if (currentUserEmail != null) {
              Get.to(() => ChatScreen(
                    roomId: currentUserEmail,
                    userEmail: loginHandler.box.read('userEmail'),
                  ));
            }
          },
        ),
      ),
    );
  }
}
