import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lencho/controllers/community/community_post_controller.dart';

class CreateCommentDialog extends StatefulWidget {
  final String communityId;
  final String postId;
  
  const CreateCommentDialog({
    Key? key,
    required this.communityId,
    required this.postId,
  }) : super(key: key);

  @override
  State<CreateCommentDialog> createState() => _CreateCommentDialogState();
}

class _CreateCommentDialogState extends State<CreateCommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  final CommunityPostController _postController = Get.find<CommunityPostController>();

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a comment');
      return;
    }
    setState(() => _isLoading = true);
    await _postController.commentPost(
      communityId: widget.communityId,
      postId: widget.postId,
      comment: _commentController.text.trim(),
    );
    setState(() => _isLoading = false);
    Navigator.of(context).pop(); // Close dialog after submission
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Comment'),
      content: TextField(
        controller: _commentController,
        decoration: const InputDecoration(
          hintText: 'Enter your comment',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _submitComment,
                child: const Text('Submit'),
              ),
      ],
    );
  }
}
