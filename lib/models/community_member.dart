import 'package:cloud_firestore/cloud_firestore.dart';
import 'community_base.dart';

class CommunityMember extends CommunityBase {
  final String userId;
  final String role;
  final Timestamp? joinedAt;
  final String? email;
  final String? location;

  CommunityMember({
    required String id,
    required this.userId,
    required this.role,
    this.joinedAt,
    this.email,
    this.location,
  }) : super(id: id);

  factory CommunityMember.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityMember(
      id: doc.id,
      userId: data['userId'] ?? '',
      role: data['role'] ?? 'member',
      joinedAt: data['joinedAt'],
      email: data['email'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt,
      'email': email,
      'location': location,
    };
  }
}
