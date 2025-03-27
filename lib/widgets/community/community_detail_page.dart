import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/community/community_controller.dart';
import 'package:lencho/controllers/community/community_post_controller.dart';
import 'package:lencho/widgets/community/comment_dialog.dart';
import 'package:lencho/widgets/home/header_widgets.dart';
import 'package:lencho/widgets/community/create_post_dialog.dart';

class CommunityDetailPage extends StatefulWidget {
  final String communityId;
  final Map<String, dynamic> communityData;

  const CommunityDetailPage({
    Key? key,
    required this.communityId,
    required this.communityData,
  }) : super(key: key);

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _isMember = false;
  bool _isAdmin = false;
  bool _isLoading = true;
  final CommunityController _communityController = Get.put(CommunityController());
  final CommunityPostController _postController = Get.put(CommunityPostController());

  @override
  void initState() {
    super.initState();
    _checkMembershipStatus();
  }

  Future<void> _checkMembershipStatus() async {
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final memberDoc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('members')
          .doc(currentUser!.uid)
          .get();
      setState(() {
        _isMember = memberDoc.exists;
        _isAdmin = memberDoc.exists && memberDoc.data()?['role'] == 'admin';
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking membership: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCommunityHeader() {
    Widget avatar;
    if (widget.communityData['imageContent'] != null) {
      final imageBytes = base64Decode(widget.communityData['imageContent']);
      avatar = CircleAvatar(
        backgroundImage: MemoryImage(imageBytes),
        radius: 30,
      );
    } else {
      avatar = CircleAvatar(
        backgroundColor: const Color(0xFFACE268).withOpacity(0.2),
        child: Text(
          widget.communityData['name'][0].toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF2D5A27),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        radius: 30,
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFF4BE),
                        Color(0xFFACE268),
                      ],
                    ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.communityData['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A27),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.communityData['memberCount']} members',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (!_isLoading && currentUser != null)
            _isMember ? _buildLeaveButton() : _buildJoinButton(),
        ],
      ),
    );
  }

  Widget _buildJoinButton() {
    return InkWell(
      onTap: _joinCommunity,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFACE268), Color(0xFF7BBF3F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'Join',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveButton() {
    return OutlinedButton(
      onPressed: _leaveCommunity,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: const Text(
        'Leave',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPostCreation() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Make a Post',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFACE268),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CreatePostDialog(communityId: widget.communityId),
          );
        },
      ),
    );
  }

  /// Helper to display a preview of the first 2 comments and a link to view all comments.
  Widget _buildPostComments(String communityId, String postId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .limit(2)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final commentsDocs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...commentsDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('UserDetails')
                    .doc(data['authorId'])
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text('Loading...', style: TextStyle(fontSize: 14)),
                    );
                  }
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final email = userData['email'] ?? 'Unknown';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A27),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data['comment'] ?? '',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF2D5A27)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
            FutureBuilder<int>(
              future: FirebaseFirestore.instance
                  .collection('communities')
                  .doc(communityId)
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .get()
                  .then((value) => value.docs.length),
              builder: (context, countSnapshot) {
                if (!countSnapshot.hasData) return const SizedBox();
                final totalCount = countSnapshot.data!;
                if (totalCount > 2) {
                  return GestureDetector(
                    onTap: () => _showComments(postId),
                    child: Text(
                      'View all $totalCount comments',
                      style: const TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No posts yet', style: TextStyle(color: Color(0xFF2D5A27))));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post = snapshot.data!.docs[index];
            final postData = post.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFFACE268).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('UserDetails')
                          .doc(postData['authorId'])
                          .get(),
                      builder: (context, authorSnapshot) {
                        if (!authorSnapshot.hasData) return const Text('Loading...');
                        final userData = authorSnapshot.data!.data() as Map<String, dynamic>;
                        return Row(
                          children: [
                            Text(
                              userData['email'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5A27),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${userData['city']}, ${userData['state']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      postData['content'],
                      style: const TextStyle(
                        color: Color(0xFF2D5A27),
                        fontSize: 16,
                      ),
                    ),
                    if (postData['imageContent'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.memory(base64Decode(postData['imageContent'])),
                      ),
                    const SizedBox(height: 8),
                    _buildPostComments(widget.communityId, post.id),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(postData['createdAt'] as Timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.comment, color: Color(0xFF2D5A27)),
                          onPressed: () => _showComments(post.id),
                        ),
                        Text(
                          '${postData['comments'] ?? 0}',
                          style: const TextStyle(
                            color: Color(0xFF2D5A27),
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.thumb_up, color: Color(0xFF2D5A27)),
                          onPressed: () => _postController.toggleLike(widget.communityId, post.id),
                        ),
                        Text(
                          '${postData['likes'] ?? 0}',
                          style: const TextStyle(
                            color: Color(0xFF2D5A27),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _joinCommunity() async {
    if (currentUser == null) {
      Get.snackbar('Error', 'You must be logged in to join communities');
      return;
    }
    try {
      await _communityController.joinCommunity(widget.communityId);
      setState(() => _isMember = true);
    } catch (e) {
      Get.snackbar('Error', 'Failed to join community: $e');
    }
  }

  Future<void> _leaveCommunity() async {
    if (!_isMember || currentUser == null) return;
    try {
      await _communityController.leaveCommunity(widget.communityId);
      setState(() {
        _isMember = false;
        _isAdmin = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to leave community: $e');
    }
  }

  void _showComments(String postId) {
    showDialog(
      context: context,
      builder: (_) => CreateCommentDialog(
        communityId: widget.communityId,
        postId: postId,
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background remains unchanged.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const HomeHeader(isHome: false),
                _buildCommunityHeader(),
                if (_isMember) _buildPostCreation(),
                Expanded(child: _buildPostsList()),
              ],
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
