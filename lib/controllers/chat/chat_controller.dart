import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Starts a chat between the current user and another user.
  /// Requires the other user's UID and email.
  Future<String> startChat(String otherUserId, String otherUserEmail) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    // Check if a chat already exists between these users.
    final chatQuery = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .get();

    String chatId = '';
    for (final doc in chatQuery.docs) {
      final participants = List<String>.from(doc.data()['participants']);
      if (participants.contains(otherUserId)) {
        chatId = doc.id;
        break;
      }
    }

    // If no chat exists, create one and include both user IDs and emails.
    if (chatId.isEmpty) {
      final newChatRef = _firestore.collection('chats').doc();
      await newChatRef.set({
        'participants': [currentUser.uid, otherUserId],
        'participantsEmails': [currentUser.email, otherUserEmail],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': null,
      });
      chatId = newChatRef.id;
    }
    return chatId;
  }

  /// Sends a message with [messageText] to the chat with the given [chatId].
  Future<void> sendMessage(String chatId, String messageText) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || messageText.trim().isEmpty) return;

    // Add message document to the 'messages' subcollection.
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': messageText,
      'senderId': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the chat document with the latest message details.
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
