import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:RiverPark_Mate/view/chat/chatroom.dart';
import 'package:RiverPark_Mate/vm/chating_controller.dart';
import 'package:get/get.dart';
import 'package:RiverPark_Mate/vm/login_handler.dart';

class Chat extends StatelessWidget {
  Chat({super.key});

  final ChatController chatController = Get.put(ChatController());
  final LoginHandler loginHandler = Get.find<LoginHandler>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('1:1 문의'),
        centerTitle: false,
      ),
      body: Obx(() {
        final isAdmin = loginHandler.isObserver == 'Y';
        if (isAdmin) {
          return StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('chatRooms').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final chatRooms = snapshot.data?.docs ?? [];
              return ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final room = chatRooms[index];
                  return GestureDetector(
                    onLongPress: () {
                      showDeleteConfirmDialog(context, room.id);
                    },
                    child: ListTile(
                      title: Text(room['userEmail'] ?? 'Unknown User'),
                      subtitle: Text(room['lastMessage'] ?? ''),
                      onTap: () {
                        Get.to(() => ChatScreen(
                              roomId: room.id,
                              userEmail: room['userEmail'],
                            ));
                      },
                    ),
                  );
                },
              );
            },
          );
        } else {
          return Center(
            child: ElevatedButton(
              child: const Text('1:1 문의하기'),
              onPressed: () {
                final currentUserEmail = loginHandler.userEmail.value;
                if (currentUserEmail.isNotEmpty) {
                  Get.to(() => ChatScreen(
                        roomId: currentUserEmail,
                        userEmail: currentUserEmail,
                      ));
                }
              },
            ),
          );
        }
      }),
    );
  }

  deleteChatroom(String roomId) {
    chatController.deleteChatRoom(roomId);
  }

  showDeleteConfirmDialog(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("채팅방 삭제"),
          content: const Text("이 채팅방을 삭제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: const Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("삭제"),
              onPressed: () {
                deleteChatroom(roomId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
