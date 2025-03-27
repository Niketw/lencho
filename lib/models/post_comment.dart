import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lencho/models/community_base_post.dart';

class CommunityComment extends BasePost {
  final String comment;

  CommunityComment({
    required String id,
    required String authorId,
    DateTime? createdAt,
    required this.comment,
  }) : super(id: id, authorId: authorId, createdAt: createdAt);

  factory CommunityComment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityComment(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      comment: data['comment'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'createdAt': createdAt,
      'comment': comment,
    };
  }
}
