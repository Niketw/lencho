import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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
  final TextEditingController _postController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _isMember = false;
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkMembershipStatus();
  }

  Future<void> _checkMembershipStatus() async {
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
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
      setState(() {
        _isLoading = false;
      });
    }
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
              onPressed: _showCommunitySettings,
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

  Widget _buildCommunityHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.communityData['imageUrl'] != null
                    ? NetworkImage(widget.communityData['imageUrl'])
                    : null,
                child: widget.communityData['imageUrl'] == null
                    ? Text(widget.communityData['name'][0].toUpperCase())
                    : null,
                radius: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.communityData['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
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
              for (String tag
                  in List<String>.from(widget.communityData['tags'] ?? []))
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: const InputDecoration(
                hintText: 'Write a post...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _createPost,
          ),
        ],
      ),
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
                        if (!authorSnapshot.hasData) {
                          return const Text('Loading...');
                        }

                        final userData =
                            authorSnapshot.data!.data() as Map<String, dynamic>;
                        return Row(
                          children: [
                            Text(
                              userData['email'] ?? 'Unknown',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${userData['city']}, ${userData['state']}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(postData['content']),
                    if (postData['imageUrl'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.network(postData['imageUrl']),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(postData['createdAt'] as Timestamp),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () => _showComments(post.id),
                        ),
                        Text('${postData['comments'] ?? 0}'),
                        IconButton(
                          icon: const Icon(Icons.thumb_up),
                          onPressed: () => _likePost(post.id),
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
      final batch = FirebaseFirestore.instance.batch();

      // Add member document
      batch.set(
        FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.communityId)
            .collection('members')
            .doc(currentUser!.uid),
        {
          'userId': currentUser!.uid,
          'role': 'member',
          'joinedAt': FieldValue.serverTimestamp(),
        },
      );

      // Update member count
      batch.update(
        FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.communityId),
        {'memberCount': FieldValue.increment(1)},
      );

      await batch.commit();
      setState(() {
        _isMember = true;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to join community: $e');
    }
  }

  Future<void> _leaveCommunity() async {
    if (!_isMember || currentUser == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Remove member document
      batch.delete(
        FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.communityId)
            .collection('members')
            .doc(currentUser!.uid),
      );

      // Update member count
      batch.update(
        FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.communityId),
        {'memberCount': FieldValue.increment(-1)},
      );

      await batch.commit();
      setState(() {
        _isMember = false;
        _isAdmin = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to leave community: $e');
    }
  }

  Future<void> _createPost() async {
    if (!_isMember || currentUser == null || _postController.text.isEmpty)
      return;

    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('posts')
          .add({
        'content': _postController.text,
        'authorId': currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
      });

      _postController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post: $e');
    }
  }

  void _showCommunitySettings() {
    // Implement community settings dialog
  }

  void _showComments(String postId) {
    // Implement comments dialog
  }

  Future<void> _likePost(String postId) async {
    // Implement post liking functionality
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
