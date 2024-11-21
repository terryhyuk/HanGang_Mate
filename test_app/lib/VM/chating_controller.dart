import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/Model/message.dart';
import 'package:test_app/vm/login_handler.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Message> messages = <Message>[].obs;
  final LoginHandler _loginHandler = LoginHandler();
  final RxString currentRoomId = ''.obs;
  final RxString isObserver = 'F'.obs;

  String get userEmail => _loginHandler.box.read('userEmail') ?? '';
  String get userId => _loginHandler.box.read('userId') ?? '';

  @override
  void onInit() {
    super.onInit();
    checkObserver();
  }

  createOrJoinChatRoom(String roomId) async {
    if (roomId.isEmpty) return;
    try {
      final chatRoomRef = _firestore.collection('chatRooms').doc(roomId);
      final chatRoomDoc = await chatRoomRef.get();
      if (!chatRoomDoc.exists) {
        await chatRoomRef.set({
          'userId': userId,
          'userEmail': userEmail,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }
      currentRoomId.value = roomId;
      listenToMessages();
    } catch (e) {
      // print('채팅방 생성/참여 중 오류 발생: $e');
    }
  }

  checkObserver() async {
    if (userEmail.isEmpty) return;
    try {
      final url = Uri.parse(
          'http://127.0.0.1:8000/user/checkObserver?email=$userEmail');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        isObserver.value = data['is_observer'] ? 'T' : 'F';
      } else {
        throw Exception(
            'Failed to check observer status: ${response.statusCode}');
      }
    } catch (e) {
      isObserver.value = 'F';
    }
  }

  listenToMessages() {
    if (currentRoomId.isEmpty) return;

    _firestore
        .collection('chatRooms')
        .doc(currentRoomId.value)
        .collection('messages')
        .orderBy('timestamp', descending: false) // 변경: true에서 false로
        .snapshots()
        .listen((snapshot) {
      messages.value =
          snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    }, onError: (error) {
      // print('Error listening to messages: $error');
    });
  }

  sendMessage(String roomId, String content, String userEmail) async {
    if (roomId.isEmpty) return;

    try {
      final chatRoomRef = _firestore.collection('chatRooms').doc(roomId);
      final chatRoomDoc = await chatRoomRef.get();

      if (!chatRoomDoc.exists) {
        await createOrJoinChatRoom(roomId);
      }

      final message = Message(
        userEmail: userEmail,
        senderId: userEmail,
        content: content,
        timestamp: DateTime.now(),
        observer: isObserver.value.toString(),
      );

      await chatRoomRef.collection('messages').add({
        ...message.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      await chatRoomRef.update({
        'lastMessage': content,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      if (currentRoomId.value != roomId) {
        currentRoomId.value = roomId;
        listenToMessages();
      }
    } catch (e) {
      // print('Error sending message: $e');
    }
  }

  deleteChatHistory(String roomId) async {
    try {
      // 메시지 삭제
      final messagesRef =
          _firestore.collection('chatRooms').doc(roomId).collection('messages');
      final messageDocs = await messagesRef.get();
      for (var doc in messageDocs.docs) {
        await doc.reference.delete();
      }

      // 채팅방 정보 업데이트
      await _firestore.collection('chatRooms').doc(roomId).update({
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // 로컬 메시지 목록 초기화
      messages.clear();

      // print('채팅 내역이 삭제되었습니다.');
    } catch (e) {
      // print('채팅 내역 삭제 중 오류 발생: $e');
    }
  }
}
