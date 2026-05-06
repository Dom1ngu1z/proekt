class SocialComment {
  const SocialComment({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.authorId,
  });

  final String id;
  final String postId;
  final String? authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  factory SocialComment.fromMap(Map<String, dynamic> map) {
    return SocialComment(
      id: map['id']?.toString() ?? '',
      postId: map['post_id']?.toString() ?? '',
      authorId: map['author_id']?.toString(),
      authorName: map['author_name']?.toString() ?? 'Аноним',
      content: map['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return <String, dynamic>{
      'post_id': postId,
      'author_id': authorId,
      'author_name': authorName,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

