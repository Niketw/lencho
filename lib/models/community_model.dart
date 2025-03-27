import 'package:cloud_firestore/cloud_firestore.dart';
import 'community_base.dart';

class Community extends CommunityBase {
  final String name;
  final String description;
  final List<String> tags;
  final bool isPublic;
  final String createdBy;
  final Timestamp? createdAt;
  final int memberCount;
  final String? creatorLocation;
  final String? creatorEmail;
  final String? imageContent; // Now storing Base64 image data

  Community({
    required String id,
    required this.name,
    required this.description,
    required this.tags,
    required this.isPublic,
    required this.createdBy,
    this.createdAt,
    required this.memberCount,
    this.creatorLocation,
    this.creatorEmail,
    this.imageContent,
  }) : super(id: id);

  factory Community.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Community(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isPublic: data['isPublic'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'],
      memberCount: data['memberCount'] ?? 0,
      creatorLocation: data['creatorLocation'],
      creatorEmail: data['creatorEmail'],
      imageContent: data['imageContent'], // Retrieve Base64 image data
    );
  }
}
