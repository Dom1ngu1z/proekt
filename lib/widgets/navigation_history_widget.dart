import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// NavigationHistoryWidget - виджет для отображения кнопок "Назад" и "Вперед"
/// (для браузер-подобной навигации, хотя в мобильных приложениях это редко используется)
class NavigationHistoryWidget extends StatelessWidget {
  const NavigationHistoryWidget({
    super.key,
    this.canGoBack = false,
    this.canGoForward = false,
    this.onBackPressed,
    this.onForwardPressed,
  });

  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback? onBackPressed;
  final VoidCallback? onForwardPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Назад',
          onPressed: canGoBack ? (onBackPressed ?? () => context.pop()) : null,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          tooltip: 'Вперед',
          onPressed: canGoForward ? onForwardPressed : null,
        ),
      ],
    );
  }
}

