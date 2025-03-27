import 'dart:io';
import 'dart:convert'; // For base64Encode
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lencho/models/community_model.dart';
import 'package:lencho/models/community_member.dart';
import 'package:lencho/models/community_post.dart';
import 'package:permission_handler/permission_handler.dart';

class CommunityController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a new community with an optional image.
  /// The image is stored as a Base64-encoded string in the 'imageContent' field.
  Future<void> createCommunity({
    required String name,
    required String description,
    required List<String> tags,
    required bool isPublic,
    File? imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'You must be logged in to create a community');
      return;
    }

    // Request storage permission if imageFile is provided.
    String? imageContent;
    if (imageFile != null) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar('Permission Denied', 'Storage permission is required to select an image');
        return;
      }
      final bytes = await imageFile.readAsBytes();
      imageContent = base64Encode(bytes);
    }

    final userDoc = await _firestore.collection('UserDetails').doc(user.uid).get();
    if (!userDoc.exists) {
      Get.snackbar('Error', 'User profile not found');
      return;
    }
    final userData = userDoc.data() as Map<String, dynamic>;

    // Optionally, you can create a Community instance and then use toMap().
    // For simplicity, we'll build the map inline.
    final communityMap = {
      'name': name.trim(),
      'description': description.trim(),
      'tags': tags.map((e) => e.trim().toLowerCase()).toList(),
      'isPublic': isPublic,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'memberCount': 1,
      'creatorLocation': '${userData['city']}, ${userData['state']}',
      'creatorEmail': userData['email'],
      'imageContent': imageContent,
    };

    final communityRef = await _firestore.collection('communities').add(communityMap);

    // Add creator as admin in members subcollection.
    await communityRef.collection('members').doc(user.uid).set({
      'userId': user.uid,
      'role': 'admin',
      'joinedAt': FieldValue.serverTimestamp(),
      'email': userData['email'],
      'location': '${userData['city']}, ${userData['state']}',
    });

    Get.back();
    Get.snackbar('Success', 'Community created successfully');
  }

  /// Join a community.
  Future<void> joinCommunity(String communityId) async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'You must be logged in to join communities');
      return;
    }
    try {
      final batch = _firestore.batch();
      final communityDoc = _firestore.collection('communities').doc(communityId);
      batch.set(
        communityDoc.collection('members').doc(user.uid),
        {
          'userId': user.uid,
          'role': 'member',
          'joinedAt': FieldValue.serverTimestamp(),
        },
      );
      batch.update(communityDoc, {'memberCount': FieldValue.increment(1)});
      await batch.commit();
    } catch (e) {
      Get.snackbar('Error', 'Failed to join community: $e');
    }
  }

  /// Leave a community.
  Future<void> leaveCommunity(String communityId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final batch = _firestore.batch();
      final communityDoc = _firestore.collection('communities').doc(communityId);
      batch.delete(communityDoc.collection('members').doc(user.uid));
      batch.update(communityDoc, {'memberCount': FieldValue.increment(-1)});
      await batch.commit();
    } catch (e) {
      Get.snackbar('Error', 'Failed to leave community: $e');
    }
  }

  /// Create a new post in a community with an optional image.
  /// This method uses the new CommunityPost model. The image is converted to a Base64 string.
  Future<void> createPost({
    required String communityId,
    required String content,
    File? imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null || content.trim().isEmpty) {
      Get.snackbar('Error', 'User not logged in or post content is empty');
      return;
    }

    String? imageContent;
    if (imageFile != null) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar('Permission Denied', 'Storage permission is required to select an image');
        return;
      }
      final bytes = await imageFile.readAsBytes();
      imageContent = base64Encode(bytes);
    }

    // Create a CommunityPost instance.
    final post = CommunityPost(
      id: '', // Firestore will generate the document ID.
      content: content,
      authorId: user.uid,
      createdAt: null, // Will be replaced by the server timestamp.
      likes: 0,
      comments: 0,
      imageContent: imageContent,
    );

    // Convert the model to a map and inject the server timestamp.
    final postMap = post.toMap();
    postMap['createdAt'] = FieldValue.serverTimestamp();

    try {
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .add(postMap);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post: $e');
    }
  }
}
