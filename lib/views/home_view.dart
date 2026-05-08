import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/social_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/group_card.dart';
import '../widgets/main_scaffold.dart';
import '../widgets/post_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<SocialProvider>().loadMoreFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SocialProvider>();
    return MainScaffold(
      title: 'Соцсеть группы',
      selectedIndex: 0,
      actions: <Widget>[
        IconButton(
          onPressed: provider.isLoading ? null : () { provider.refresh(); },
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, SocialProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.groups.isEmpty && provider.feed.isEmpty) {
      return EmptyState(
        icon: Icons.forum_outlined,
        title: 'Лента пуста',
        subtitle: 'Добавьте посты в Supabase, чтобы увидеть их здесь.',
        action: FilledButton(
          onPressed: () { provider.refresh(); },
          child: const Text('Обновить'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (provider.errorMessage != null) ...<Widget>[
            MaterialBanner(
              content: Text(provider.errorMessage!),
              actions: <Widget>[
                TextButton(
                  onPressed: () { provider.refresh(); },
                  child: const Text('Повторить'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          _buildHero(context, provider),
          const SizedBox(height: 20),
          Text('Популярные сообщества', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final group = provider.groups[index];
                return SizedBox(
                  width: 280,
                  child: GroupCard(
                    group: group,
                    onTap: () { context.go('/group/${group.id}'); },
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemCount: provider.groups.length,
            ),
          ),
          const SizedBox(height: 24),
          Text('Лента', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (provider.highlightedFeed.isEmpty)
            const EmptyState(
              icon: Icons.article_outlined,
              title: 'Постов пока нет',
              subtitle: 'Опубликуйте первый пост в группе.',
            )
          else
            ...provider.highlightedFeed.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PostCard(
                  post: post,
                  onTap: () { context.go('/post/${post.id}'); },
                  onLike: () { provider.toggleLike(post.id); },
                  onComment: () { context.go('/post/${post.id}'); },
                ),
              ),
            ),
          if (provider.isLoadingMore) ...<Widget>[
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ],
          if (provider.hasMoreFeed) ...<Widget>[
            const SizedBox(height: 24),
            const Center(child: Text('Прокрутите ниже, чтобы загрузить ещё посты')),
          ],
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, SocialProvider provider) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Добро пожаловать в мини-комьюнити',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Здесь лента, группы, профиль, авторизация и публикации хранятся в Supabase. Можно писать посты и комментарии на русском языке.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () { context.go('/create'); },
                  icon: const Icon(Icons.edit),
                  label: const Text('Создать пост'),
                ),
                OutlinedButton.icon(
                  onPressed: provider.groups.isEmpty
                      ? null
                      : () { context.go('/group/${provider.groups.first.id}'); },
                  icon: const Icon(Icons.group),
                  label: const Text('Открыть группу'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


