abstract class BasePost {
  final String id;
  final String authorId;
  final DateTime? createdAt;

  BasePost({
    required this.id,
    required this.authorId,
    this.createdAt,
  });
}
