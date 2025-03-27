import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lencho/models/community_base_post.dart';

class CommunityPost extends BasePost {
  final String content;
  final int likes;
  final int comments;
  final String? imageContent; // Base64 encoded image data

  CommunityPost({
    required String id,
    required String authorId,
    DateTime? createdAt,
    required this.content,
    required this.likes,
    required this.comments,
    this.imageContent,
  }) : super(id: id, authorId: authorId, createdAt: createdAt);

  factory CommunityPost.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      content: data['content'] ?? '',
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      imageContent: data['imageContent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'createdAt': createdAt,
      'content': content,
      'likes': likes,
      'comments': comments,
      'imageContent': imageContent,
    };
  }
}
