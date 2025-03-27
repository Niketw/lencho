import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/community/community_controller.dart';
import 'package:lencho/controllers/community/community_post_controller.dart';
import 'package:lencho/widgets/community/comment_dialog.dart';
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
        child: Text(widget.communityData['name'][0].toUpperCase()),
        radius: 30,
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              avatar,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.communityData['name'],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.communityData['memberCount']} members',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (!_isLoading && currentUser != null)
                _isMember
                    ? ElevatedButton(
                        onPressed: _leaveCommunity,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Leave'),
                      )
                    : ElevatedButton(
                        onPressed: _joinCommunity,
                        child: const Text('Join'),
                      ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.communityData['description'],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (String tag in List<String>.from(widget.communityData['tags'] ?? []))
                Chip(label: Text(tag)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostCreation() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Make a Post'),
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
            // Assuming each comment document has an 'authorId' field.
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['comment'] ?? '',
                          style: const TextStyle(fontSize: 14),
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
        return const Center(child: Text('No posts yet'));
      }
      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final post = snapshot.data!.docs[index];
          final postData = post.data() as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          Text(userData['email'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('${userData['city']}, ${userData['state']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(postData['content']),
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
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const Spacer(),
                      // Comment button added here:
                      IconButton(
                        icon: const Icon(Icons.comment),
                        onPressed: () => _showComments(post.id),
                      ),
                      Text('${postData['comments'] ?? 0}'),
                      IconButton(
                        icon: const Icon(Icons.thumb_up),
                        onPressed: () => _postController.likePost(widget.communityId, post.id),
                      ),
                      Text('${postData['likes'] ?? 0}'),
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

  // Updated _showComments to open the CreateCommentDialog.
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
      appBar: AppBar(
        title: Text(widget.communityData['name']),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Implement community settings dialog if needed.
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
