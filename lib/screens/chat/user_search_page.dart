import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/chat/chat_controller.dart';
import 'package:lencho/screens/chat/chat_page.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({Key? key}) : super(key: key);

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  String _searchQuery = '';
  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

  final ChatController chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find People'),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                if (value.length >= 3) {
                  _performSearch(value);
                } else if (value.isEmpty) {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
            ),
          ),
          // Search results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: _searchQuery.length < 3
                            ? const Text('Type at least 3 characters to search')
                            : const Text('No users found'),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final userDoc = _searchResults[index];
                          final userData = userDoc.data() as Map<String, dynamic>;
                          final userEmail = userData['email'] ?? 'No email';

                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(userEmail.isNotEmpty
                                  ? userEmail[0].toUpperCase()
                                  : '?'),
                            ),
                            title: Text(userEmail),
                            subtitle: Text(userData['city'] ?? ''),
                            onTap: () async {
                              // Start a chat with this user.
                              final otherUserId = userDoc.id;
                              final otherUserEmail = userEmail;
                              final chatId = await chatController.startChat(
                                  otherUserId, otherUserEmail);
                              Get.to(() => ChatPage(
                                    chatId: chatId,
                                    otherUserId: otherUserId,
                                  ));
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) async {
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _firestore
          .collection('UserDetails')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      // Filter out the current user.
      final filteredResults =
          results.docs.where((doc) => doc.id != currentUser!.uid).toList();

      setState(() {
        _searchResults = filteredResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Failed to search: $e');
    }
  }
}
