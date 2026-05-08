import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/social_comment.dart';
import '../models/social_post.dart';
import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import '../widgets/detail_scaffold.dart';
import '../widgets/empty_state.dart';

class PostDetailView extends StatefulWidget {
  const PostDetailView({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = true;
  SocialPost? _post;
  List<SocialComment> _comments = <SocialComment>[];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final provider = context.read<SocialProvider>();
      final post = await provider.fetchPost(widget.postId);
      if (post == null) {
        setState(() {
          _post = null;
          _comments = <SocialComment>[];
        });
        return;
      }
      final comments = await provider.fetchComments(widget.postId);
      setState(() {
        _post = post;
        _comments = comments;
      });
    } catch (error) {
      _errorMessage = 'Не удалось загрузить пост: $error';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final social = context.watch<SocialProvider>();
    return DetailScaffold(
      title: 'Пост',
      actions: <Widget>[
        if (_post != null)
          IconButton(
            onPressed: () { _toggleLike(); },
            icon: Icon(_post!.isLikedByMe ? Icons.favorite : Icons.favorite_border),
            tooltip: _post!.isLikedByMe ? 'Убрать лайк' : 'Поставить лайк',
          ),
      ],
      child: _buildBody(context, auth, social),
    );
  }

  Widget _buildBody(BuildContext context, AuthProvider auth, SocialProvider social) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    final post = _post;
    if (post == null) {
      return const EmptyState(
        icon: Icons.article_outlined,
        title: 'Пост не найден',
        subtitle: 'Попробуйте открыть другой пост.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(post.groupName, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Автор: ${post.authorName} • ${_formatDate(post.createdAt)}'),
                  const SizedBox(height: 12),
                  Text(post.content),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: () { _toggleLike(); },
                        icon: Icon(post.isLikedByMe ? Icons.favorite : Icons.favorite_border),
                        label: Text('${post.likesCount} лайков'),
                      ),
                      OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.mode_comment_outlined),
                        label: Text('${post.commentsCount} комментариев'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Комментарии', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (_comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Комментариев пока нет.'),
            )
          else
            ..._comments.map(
              (comment) => Card(
                child: ListTile(
                  title: Text(comment.authorName),
                  subtitle: Text(comment.content),
                  trailing: Text(_formatDate(comment.createdAt)),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Оставить комментарий',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: social.isSubmitting ? null : () { _addComment(auth.displayName); },
                    icon: const Icon(Icons.send),
                    label: const Text('Отправить'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike() async {
    final provider = context.read<SocialProvider>();
    final updated = await provider.toggleLike(widget.postId);
    if (!mounted || updated == null) {
      return;
    }
    setState(() {
      _post = updated;
    });
  }

  Future<void> _addComment(String authorName) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }
    final provider = context.read<SocialProvider>();
    final comment = await provider.addComment(
      postId: widget.postId,
      authorName: authorName,
      content: text,
    );
    if (!mounted || comment == null) {
      return;
    }
    _commentController.clear();
    await _load();
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day.$month $hour:$minute';
  }
}



