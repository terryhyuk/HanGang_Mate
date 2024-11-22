import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String userEmail;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String observer;

  Message({
    required this.userEmail,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.observer,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      userEmail: map['userEmail'] ?? '',
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      observer: map['observer'] ?? 'F',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userEmail': userEmail,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'observer': observer,
    };
  }
}
