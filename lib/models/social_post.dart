class SocialPost {
  const SocialPost({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    this.tag,
    this.imageUrl,
    this.authorId,
    this.isLikedByMe = false,
  });

  final String id;
  final String groupId;
  final String groupName;
  final String? authorId;
  final String authorName;
  final String title;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final String? tag;
  final String? imageUrl;
  final bool isLikedByMe;

  factory SocialPost.fromMap(Map<String, dynamic> map) {
    return SocialPost(
      id: map['id']?.toString() ?? '',
      groupId: map['group_id']?.toString() ?? '',
      groupName: map['group_name']?.toString() ?? 'Группа',
      authorId: map['author_id']?.toString(),
      authorName: map['author_name']?.toString() ?? 'Аноним',
      title: map['title']?.toString() ?? 'Новая запись',
      content: map['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      likesCount: int.tryParse(map['likes_count']?.toString() ?? '') ?? 0,
      commentsCount: int.tryParse(map['comments_count']?.toString() ?? '') ?? 0,
      tag: map['tag']?.toString(),
      imageUrl: map['image_url']?.toString(),
      isLikedByMe: map['is_liked_by_me'] == true,
    );
  }

  SocialPost copyWith({
    String? id,
    String? groupId,
    String? groupName,
    String? authorId,
    String? authorName,
    String? title,
    String? content,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    String? tag,
    String? imageUrl,
    bool? isLikedByMe,
  }) {
    return SocialPost(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      tag: tag ?? this.tag,
      imageUrl: imageUrl ?? this.imageUrl,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return <String, dynamic>{
      'group_id': groupId,
      'author_id': authorId,
      'group_name': groupName,
      'author_name': authorName,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'tag': tag,
      'image_url': imageUrl,
    };
  }
}

