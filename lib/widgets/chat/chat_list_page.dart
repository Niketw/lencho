import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lencho/widgets/chat/chat_page.dart';
import 'package:lencho/widgets/chat/user_search_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentEmail = currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Get.to(() => const UserSearchPage());
            },
          ),
        ],
      ),
      body: currentUser == null || currentEmail.isEmpty
          ? const Center(child: Text('Please log in to access chat'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participantsEmails', arrayContains: currentEmail)
                  // If some documents have null for lastMessageTime, consider using a default value in your query
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chatDocs = snapshot.hasData ? snapshot.data!.docs : [];
                if (chatDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No chat history found'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => const UserSearchPage());
                          },
                          child: const Text('Find someone to chat with'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    final chatDoc = chatDocs[index];
                    final chatData = chatDoc.data() as Map<String, dynamic>;

                    // Debug print to inspect chat document data.
                    print("Chat Document Data: $chatData");

                    // Retrieve participant emails.
                    final List<dynamic> emailsDynamic =
                        chatData['participantsEmails'] ?? [];
                    final List<String> emails =
                        emailsDynamic.map((e) => e.toString()).toList();

                    // Retrieve the user IDs.
                    final participants =
                        List<String>.from(chatData['participants']);
                    final otherUserId = participants.firstWhere(
                      (id) => id != currentUser.uid,
                      orElse: () => 'Unknown',
                    );

                    // Retrieve the other user's email.
                    final otherEmails =
                        emails.where((email) => email != currentEmail).toList();
                    final otherUserEmail =
                        otherEmails.isNotEmpty ? otherEmails.first : 'Unknown';

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(otherUserEmail.isNotEmpty
                            ? otherUserEmail[0].toUpperCase()
                            : '?'),
                      ),
                      title: Text(otherUserEmail),
                      subtitle: Text(
                        chatData['lastMessage'] ?? 'Start a conversation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: chatData['lastMessageTime'] != null
                          ? Text(
                              _formatTimestamp(
                                  chatData['lastMessageTime'] as Timestamp),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      onTap: () {
                        Get.to(() => ChatPage(
                              chatId: chatDoc.id,
                              otherUserId: otherUserId,
                            ));
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
