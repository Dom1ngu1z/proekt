import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/social_provider.dart';
import '../widgets/main_scaffold.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<SocialProvider>();
    final groupId = provider.selectedGroupId ?? (provider.groups.isNotEmpty ? provider.groups.first.id : null);

    // Проверяем, был ли CreatePostView открыт из GroupDetailView
    // Если это так, то GoRouter передаст путь вида /group/:id/create или откроется через context.go('/create')
    final isDetailView = context.canPop();

    return MainScaffold(
      title: 'Создать пост',
      selectedIndex: 2,
      showBackButton: isDetailView,
      child: provider.groups.isEmpty
          ? const Center(child: Text('Группы ещё не загружены.'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Text('Публикация в группе', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: groupId,
                    items: provider.groups
                        .map(
                          (group) => DropdownMenuItem<String>(
                            value: group.id,
                            child: Text(group.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => provider.selectGroup(value),
                    decoration: const InputDecoration(
                      labelText: 'Группа',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null ? 'Выберите группу' : null,
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Автор',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(auth.displayName),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Заголовок',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'Введите заголовок';
                      }
                      if (text.length < 3) {
                        return 'Заголовок должен быть не короче 3 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    minLines: 5,
                    maxLines: 9,
                    decoration: const InputDecoration(
                      labelText: 'Текст поста',
                      hintText: 'Напишите пост по-русски или на любом удобном языке',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'Введите содержание поста';
                      }
                      if (text.length < 12) {
                        return 'Текст должен быть не короче 12 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Тег (необязательно)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: provider.isSubmitting ? null : () { _submit(context); },
                    icon: provider.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(provider.isSubmitting ? 'Публикация...' : 'Опубликовать'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final provider = context.read<SocialProvider>();
    final groupId = provider.selectedGroupId ?? provider.groups.first.id;
    final post = await provider.createPost(
      groupId: groupId,
      authorName: auth.displayName,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      tag: _tagController.text.trim().isEmpty ? null : _tagController.text.trim(),
    );

    if (!context.mounted || post == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Пост опубликован в Supabase')),
    );
    context.go('/post/${post.id}');
  }
}

