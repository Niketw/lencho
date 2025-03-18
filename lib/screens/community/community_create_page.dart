import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CommunityCreatePage extends StatefulWidget {
  const CommunityCreatePage({Key? key}) : super(key: key);

  @override
  State<CommunityCreatePage> createState() => _CommunityCreatePageState();
}

class _CommunityCreatePageState extends State<CommunityCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _createCommunity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'You must be logged in to create a community');
        return;
      }

      // Get user details
      final userDoc = await FirebaseFirestore.instance
          .collection('UserDetails')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        Get.snackbar('Error', 'User profile not found');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // Create the community
      final communityRef =
          await FirebaseFirestore.instance.collection('communities').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'tags': _tagsController.text
            .split(',')
            .map((e) => e.trim().toLowerCase())
            .toList(),
        'isPublic': _isPublic,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'memberCount': 1,
        'creatorLocation': '${userData['city']}, ${userData['state']}',
        'creatorEmail': userData['email'],
      });

      // Add creator as admin in members subcollection
      await communityRef.collection('members').doc(user.uid).set({
        'userId': user.uid,
        'role': 'admin',
        'joinedAt': FieldValue.serverTimestamp(),
        'email': userData['email'],
        'location': '${userData['city']}, ${userData['state']}',
      });

      Get.back();
      Get.snackbar('Success', 'Community created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create community: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Community'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Community Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a community name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma-separated)',
                        border: OutlineInputBorder(),
                        hintText: 'agriculture, farming, organic',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter at least one tag';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Public Community'),
                      subtitle: const Text(
                        'Public communities are visible to everyone',
                      ),
                      value: _isPublic,
                      onChanged: (value) => setState(() => _isPublic = value),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _createCommunity,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Create Community'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
