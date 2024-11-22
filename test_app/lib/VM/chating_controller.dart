import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:test_app/Model/message.dart';
import 'package:test_app/vm/login_handler.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Message> messages = <Message>[].obs;
  final LoginHandler _loginHandler = LoginHandler();
  final RxString currentRoomId = ''.obs;
  final RxString isObserver = 'F'.obs;

  String get userEmail => _loginHandler.box.read('userEmail') ?? '';
  String get userId => _loginHandler.box.read('userId') ?? '';

  createOrJoinChatRoom(String roomId) async {
    if (roomId.isEmpty) return;
    try {
      final chatRoomRef = _firestore.collection('chatRooms').doc(roomId);
      final chatRoomDoc = await chatRoomRef.get();
      if (!chatRoomDoc.exists) {
        await chatRoomRef.set({
          'userId': userId,
          'userEmail': userEmail,
          'createdAt': Timestamp.now(),
          'lastMessage': '',
          'lastMessageTime': Timestamp.now(),
        });
      }
      currentRoomId.value = roomId;
      listenToMessages();
    } catch (e) {
      //
    }
  }

  listenToMessages() {
    if (currentRoomId.isEmpty) return;

    _firestore
        .collection('chatRooms')
        .doc(currentRoomId.value)
        .collection('messages')
        .orderBy('timestamp', descending: false)
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
        observer: isObserver.value == 'Y' ? 'Y' : 'N',
      );

      await chatRoomRef.collection('messages').add({
        ...message.toMap(),
        'timestamp': Timestamp.now(),
      });

      await chatRoomRef.update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.now(),
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
        'lastMessageTime': Timestamp.now(),
      });

      // 로컬 메시지 목록 초기화
      messages.clear();

      // print('채팅 내역이 삭제되었습니다.');
    } catch (e) {
      // print('채팅 내역 삭제 중 오류 발생: $e');
    }
  }

  deleteChatRoom(String roomId) async {
    try {
      // 채팅방 문서 삭제
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(roomId)
          .delete();
      // 채팅방 내의 모든 메시지 삭제
      final messagesRef = FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages');
      final messages = await messagesRef.get();
      for (var doc in messages.docs) {
        await doc.reference.delete();
      }
      // print('채팅방이 성공적으로 삭제되었습니다.');
    } catch (e) {
      // print('채팅방 삭제 중 오류 발생: $e');
    }
  }
}
