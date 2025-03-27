import 'package:cloud_firestore/cloud_firestore.dart';
import 'chats.dart';

class messages extends chats {
  final String text;
  final String senderId;
  final DateTime? timestamp;

  messages({
    required String id,
    required List<String> participants,
    required List<String> participantsEmails,
    required String lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    required this.text,
    required this.senderId,
    this.timestamp,
  }) : super(
          id: id,
          participants: participants,
          participantsEmails: participantsEmails,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
          createdAt: createdAt,
        );

  factory messages.fromFirestore(Map<String, dynamic> data, String documentId) {
    return messages(
      id: documentId,
      participants: List<String>.from(data['participants'] ?? []),
      participantsEmails: List<String>.from(data['participantsEmails'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp,
    });
    return map;
  }
}
