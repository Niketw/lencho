import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lencho/models/community_post.dart';
import 'package:lencho/models/post_comment.dart';

class CommunityPostController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a new post in a community with an optional image.
  /// The image is converted to a Base64 string and stored in Firestore under `imageContent`.
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

    // Convert the image file to Base64 if provided.
    String? imageContent;
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      imageContent = base64Encode(bytes);
    }

    // Instead of writing a raw map, we create a CommunityPost instance
    // Note: We leave 'createdAt' as null because we'll use FieldValue.serverTimestamp() in the map.
    final post = CommunityPost(
      id: '', // Firestore will generate the ID for us
      authorId: user.uid,
      content: content,
      createdAt: null,
      likes: 0,
      comments: 0,
      imageContent: imageContent,
    );

    // Build the map, injecting the server timestamp for createdAt.
    final postMap = post.toMap()..['createdAt'] = FieldValue.serverTimestamp();

    try {
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .add(postMap);
      Get.snackbar('Success', 'Post created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post: $e');
    }
  }

  Future<void> toggleLike(String communityId, String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final likeDocRef = _firestore
        .collection('communities')
        .doc(communityId)
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(user.uid);
    
    final postDocRef = _firestore
        .collection('communities')
        .doc(communityId)
        .collection('posts')
        .doc(postId);
    
    try {
      final likeDoc = await likeDocRef.get();
      
      if (likeDoc.exists) {
        // User already liked the post: remove the like.
        print('User already liked the post. Removing like...');
        
        await _firestore.runTransaction((transaction) async {
          // Do all reads first.
          final postSnapshot = await transaction.get(postDocRef);
          final currentLikes = (postSnapshot.data()?['likes'] ?? 0) as int;
          
          // Now perform the writes.
          transaction.delete(likeDocRef);
          transaction.update(postDocRef, {
            'likes': currentLikes > 0 ? currentLikes - 1 : 0,
          });
        });
        print('Like removed successfully.');
      } else {
        // User has not liked the post: add the like.
        print('User has not liked the post. Adding like...');
        
        await _firestore.runTransaction((transaction) async {
          // Do the read first.
          final postSnapshot = await transaction.get(postDocRef);
          final currentLikes = (postSnapshot.data()?['likes'] ?? 0) as int;
          
          // Then perform the writes.
          transaction.set(likeDocRef, {
            'userId': user.uid,
            'likedAt': FieldValue.serverTimestamp(),
          });
          transaction.update(postDocRef, {'likes': currentLikes + 1});
        });
        print('Like added successfully.');
      }
    } catch (e) {
      print('Error in toggleLike: $e');
      Get.snackbar('Error', 'Failed to toggle like: $e');
    }
  }


  /// Add a comment to a post and update the comment count.
  Future<void> commentPost({
    required String communityId,
    required String postId,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null || comment.trim().isEmpty) {
      Get.snackbar('Error', 'User not logged in or comment is empty');
      return;
    }

    // Create a CommunityComment instance.
    final comm = CommunityComment(
      id: '', // Firestore will generate an ID for the comment
      authorId: user.uid,
      comment: comment,
      createdAt: null,
    );

    // Build the map and inject the server timestamp.
    final commentMap = comm.toMap()..['createdAt'] = FieldValue.serverTimestamp();

    try {
      // Add comment in a subcollection under the post document.
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add(commentMap);
      // Increase the comment count.
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .update({'comments': FieldValue.increment(1)});
      Get.snackbar('Success', 'Comment added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment: $e');
    }
  }
}
