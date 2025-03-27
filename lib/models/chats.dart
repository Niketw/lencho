import 'package:cloud_firestore/cloud_firestore.dart';

class chats {
  final String id;
  final List<String> participants;
  final List<String> participantsEmails;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final DateTime? createdAt;

  chats({
    required this.id,
    required this.participants,
    required this.participantsEmails,
    required this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
  });

  factory chats.fromFirestore(Map<String, dynamic> data, String documentId) {
    return chats(
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'participantsEmails': participantsEmails,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'createdAt': createdAt,
    };
  }
}
