import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lencho/screens/chat/chat_page.dart';
import 'package:lencho/screens/chat/user_search_page.dart';
import 'package:lencho/widgets/home/header_widgets.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentEmail = currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 247, 255, 1),
      body: currentUser == null || currentEmail.isEmpty
          ? const Center(
              child: Text(
                'Please log in to access chat',
                style: TextStyle(color: Color(0xFF2D5A27)),
              ),
            )
          : Column(
              children: [
                // Custom header.
                const HomeHeader(isHome: false),
                // Permanent search bar for users.
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: InkWell(
                    onTap: () {
                      // Navigate to the user search page.
                      Get.to(() => const UserSearchPage());
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2D5A27).withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFACE268).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.search,
                            color: Color(0xFF2D5A27),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Search users...',
                            style: TextStyle(
                              color: Color(0xFF2D5A27),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Chat list.
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .where('participantsEmails', arrayContains: currentEmail)
                        .orderBy('lastMessageTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final chatDocs =
                          snapshot.hasData ? snapshot.data!.docs : [];
                      if (chatDocs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No chat history found',
                                style: TextStyle(color: Color(0xFF2D5A27)),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFACE268),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  Get.to(() => const UserSearchPage());
                                },
                                child: const Text(
                                  'Find someone to chat with',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemCount: chatDocs.length,
                        itemBuilder: (context, index) {
                          final chatDoc = chatDocs[index];
                          final chatData =
                              chatDoc.data() as Map<String, dynamic>;

                          // Retrieve participant emails.
                          final List<dynamic> emailsDynamic =
                              chatData['participantsEmails'] ?? [];
                          final List<String> emails = emailsDynamic
                              .map((e) => e.toString())
                              .toList();

                          // Retrieve the user IDs.
                          final participants =
                              List<String>.from(chatData['participants']);
                          final otherUserId = participants.firstWhere(
                            (id) => id != currentUser.uid,
                            orElse: () => 'Unknown',
                          );

                          // Retrieve the other user's email.
                          final otherEmails = emails
                              .where((email) => email != currentEmail)
                              .toList();
                          final otherUserEmail = otherEmails.isNotEmpty
                              ? otherEmails.first
                              : 'Unknown';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFACE268),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Text(
                                  otherUserEmail.isNotEmpty
                                      ? otherUserEmail[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Color(0xFF2D5A27),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              otherUserEmail,
                              style: const TextStyle(
                                color: Color(0xFF2D5A27),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              chatData['lastMessage'] ??
                                  'Start a conversation',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(color: Color(0xFF2D5A27)),
                            ),
                            trailing: chatData['lastMessageTime'] != null
                                ? Text(
                                    _formatTimestamp(chatData['lastMessageTime']
                                        as Timestamp),
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
                ),
              ],
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
