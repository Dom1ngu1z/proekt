import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/social_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/group_card.dart';
import '../widgets/main_scaffold.dart';

class GroupsView extends StatelessWidget {
  const GroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SocialProvider>();
    return MainScaffold(
      title: 'Сообщества',
      selectedIndex: 1,
      child: provider.groups.isEmpty
          ? const EmptyState(
              icon: Icons.groups_outlined,
              title: 'Группы не найдены',
              subtitle: 'После подключения к Supabase здесь появится список сообществ.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final group = provider.groups[index];
                final isSelected = provider.selectedGroupId == group.id;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Выбрано для ленты',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    GroupCard(
                      group: group,
                      onTap: () => context.go('/group/${group.id}'),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemCount: provider.groups.length,
            ),
    );
  }
}


