import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lencho/controllers/community/community_post_controller.dart';

class CreatePostDialog extends StatefulWidget {
  final String communityId;
  const CreatePostDialog({Key? key, required this.communityId}) : super(key: key);

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _postController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final CommunityPostController _postControllerInstance = Get.find<CommunityPostController>();

  Future<void> _pickImage() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      Get.snackbar('Permission Denied', 'Storage permission is required to pick images', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      print('Picked image path: ${pickedFile.path}');
      setState(() => _selectedImage = File(pickedFile.path));
    } else {
      print('No image was selected.');
    }
  }

  Future<void> _submitPost() async {
    if (_postController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a description');
      return;
    }
    setState(() => _isLoading = true);
    await _postControllerInstance.createPost(
      communityId: widget.communityId,
      content: _postController.text.trim(),
      imageFile: _selectedImage,
    );
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Post'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _postController,
              decoration: const InputDecoration(hintText: 'Write a post...', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.image), onPressed: _pickImage),
                const Text('Add Image'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: _submitPost, child: const Text('Post')),
      ],
    );
  }
}
