import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/social_group.dart';
import '../models/social_post.dart';
import '../providers/social_provider.dart';
import '../widgets/detail_scaffold.dart';
import '../widgets/empty_state.dart';
import '../widgets/post_card.dart';

class GroupDetailView extends StatefulWidget {
  const GroupDetailView({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupDetailView> createState() => _GroupDetailViewState();
}

class _GroupDetailViewState extends State<GroupDetailView> {
  bool _isLoading = true;
  SocialGroup? _group;
  List<SocialPost> _posts = <SocialPost>[];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<SocialProvider>();
      final groups = provider.groups;
      _group = groups.where((group) => group.id == widget.groupId).firstOrNull;
      _posts = await provider.loadGroupPosts(widget.groupId);
    } catch (error) {
      _errorMessage = 'Не удалось загрузить группу: $error';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return DetailScaffold(
        title: 'Группа',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return DetailScaffold(
        title: 'Группа',
        child: Center(child: Text(_errorMessage!)),
      );
    }

    final group = _group;
    if (group == null) {
      return DetailScaffold(
        title: 'Группа',
        child: const EmptyState(
          icon: Icons.group_off,
          title: 'Группа не найдена',
          subtitle: 'Попробуйте открыть другое сообщество.',
        ),
      );
    }

    final provider = context.watch<SocialProvider>();

    return DetailScaffold(
      title: group.name,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              color: group.accentColor.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(group.category, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(group.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(group.description),
                    const SizedBox(height: 12),
                    Text('${group.membersCount} участников'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        provider.selectGroup(group.id);
                        context.go('/create');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Написать пост'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Посты сообщества', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (_posts.isEmpty)
              const EmptyState(
                icon: Icons.article_outlined,
                title: 'Пока нет постов',
                subtitle: 'Опубликуйте первый пост в этой группе.',
              )
            else
              ..._posts.map(
                (post) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PostCard(
                    post: post,
                    onTap: () { context.go('/post/${post.id}'); },
                    onLike: () { provider.toggleLike(post.id).then((updated) { if (updated != null) _load(); }); },
                    onComment: () { context.go('/post/${post.id}'); },
                  ),
                ),
              ),
           ],
         ),
       ),
     );
   }
}

extension _FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
