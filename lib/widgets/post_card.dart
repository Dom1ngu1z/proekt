import 'package:flutter/material.dart';

import '../models/social_post.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  final SocialPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    child: Text(post.authorName.substring(0, 1).toUpperCase()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          post.authorName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          '${post.groupName} • ${_formatDate(post.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (post.tag != null)
                    Chip(
                      label: Text(post.tag!),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(post.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(post.content),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  ActionChip(
                    avatar: Icon(
                      post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                    ),
                    label: Text('${post.likesCount}'),
                    onPressed: onLike,
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: Text('${post.commentsCount}'),
                    onPressed: onComment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$day.$month $hours:$minutes';
  }
}


