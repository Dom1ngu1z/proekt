# Функциональность навигации "Назад и Вперед"

## Описание добавленных изменений

В приложение добавлены следующие компоненты для улучшенной навигации между экранами:

### 1. **DetailScaffold** (`lib/widgets/detail_scaffold.dart`)
Специальный scaffold для страниц деталей (пост, группа) с встроенной кнопкой "Назад":
- Автоматически добавляет кнопку `←` (arrow_back) в AppBar
- Кнопка вызывает `context.pop()` для возврата на предыдущий экран
- Поддерживает дополнительные экшены и floating action button

### 2. **NavigationHistoryProvider** (`lib/providers/navigation_history_provider.dart`)
Provider для отслеживания истории навигации:
- `push(route)` - добавить маршрут в историю
- `canGoBack` - проверить возможность перейти назад
- `canGoForward` - проверить возможность перейти вперед
- `goBack()` - перейти на предыдущий маршрут
- `goForward()` - перейти на следующий маршрут
- Уведомляет слушателей об изменениях через `notifyListeners()`

### 3. **NavigationHistoryWidget** (`lib/widgets/navigation_history_widget.dart`)
Виджет для отображения кнопок "Назад" и "Вперед":
```dart
NavigationHistoryWidget(
  canGoBack: navigationHistory.canGoBack,
  canGoForward: navigationHistory.canGoForward,
  onBackPressed: () => context.read<NavigationHistoryProvider>().goBack(),
)
```

### 4. **Обновленный GoRouter** (`lib/app.dart`)
Отслеживание истории навигации через callback redirect:
```dart
redirect: (context, state) {
  // Добавляем маршрут в историю
  context.read<NavigationHistoryProvider>().push(state.matchedLocation);
  // ... остальная логика redirect
}
```

### 5. **MainScaffold обновлен** (`lib/widgets/main_scaffold.dart`)
- Добавлен параметр `showBackButton` для отображения кнопки "Назад"
- Используется `context.pop()` для навигации назад
- По умолчанию `false` для основных экранов BottomNavigationBar

### 6. **PostDetailView и GroupDetailView обновлены**
- Используют новый `DetailScaffold` вместо обычного `Scaffold`
- Имеют встроенные кнопки "Назад" в AppBar
- Поддерживают pull-to-refresh для обновления данных

### 7. **CreatePostView обновлен**
- Показывает кнопку "Назад" когда открывается из GroupDetailView
- Использует `context.canPop()` для определения, была ли последняя навигация

## Как использовать

### Базовая навигация "Назад"
Автоматически на всех страницах деталей (пост, группа):
```
Пользователь → Открывает пост → Видит кнопку ← → Нажимает → Возврат на ленту/группу
```

### Расширенная история навигации
Для использования в вашем коде:
```dart
final navHistory = context.read<NavigationHistoryProvider>();

if (navHistory.canGoBack) {
  navHistory.goBack(); // Перейти назад
}

if (navHistory.canGoForward) {
  navHistory.goForward(); // Перейти вперед
}

// Просмотр истории (для дебагинга)
print(navHistory.history); // List<String>
```

## Архитектура навигации

```
GoRouter (инициализирует маршруты)
    ↓
redirect callback (отслеживает посещение)
    ↓
NavigationHistoryProvider.push(location)
    ↓
Слушатели получают notifyListeners()
    ↓
Виджеты могут проверить canGoBack/canGoForward
```

## Примеры использования

### В DetailScaffold:
```dart
DetailScaffold(
  title: 'Пост',
  actions: [likeButton],
  child: postContent,
)
```
Кнопка "Назад" будет автоматически добавлена.

### Для пользовательской навигации:
```dart
IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () => context.pop(),
)
```

### Проверка возможности навигации:
```dart
context.watch<NavigationHistoryProvider>().canGoBack
  ? context.pop()
  : Navigator.of(context).maybePop();
```

## Поток данных

1. Пользователь нажимает на пост → `context.go('/post/:id')`
2. GoRouter срабатывает, вызывает `redirect()`
3. `redirect()` вызывает `NavigationHistoryProvider.push('/post/:id')`
4. Provider добавляет маршрут в историю и вызывает `notifyListeners()`
5. Все слушатели (виджеты) получают обновление
6. `DetailScaffold` показывает кнопку "Назад"
7. Пользователь нажимает кнопку "Назад" → `context.pop()`
8. GoRouter возвращает на предыдущий маршрут

## Особенности

✅ **Автоматическое отслеживание** - история ведется автоматически в `redirect()`  
✅ **Без дублей** - не добавляет одинаковые маршруты подряд  
✅ **Очистка истории** - при возврате назад удаляет "будущие" маршруты  
✅ **Type-safe** - полная поддержка типов Dart  
✅ **Локализованные тексты** - "Назад" на русском (tooltip)  

## Файлы, которые были добавлены/изменены

### Добавлены:
- `lib/widgets/detail_scaffold.dart`
- `lib/widgets/navigation_history_widget.dart`
- `lib/providers/navigation_history_provider.dart`
- `lib/services/navigation_history.dart`

### Изменены:
- `lib/main.dart` - добавлен NavigationHistoryProvider в MultiProvider
- `lib/app.dart` - добавлено отслеживание истории в redirect callback
- `lib/widgets/main_scaffold.dart` - добавлена кнопка "Назад"
- `lib/views/post_detail_view.dart` - использует DetailScaffold
- `lib/views/group_detail_view.dart` - использует DetailScaffold
- `lib/views/create_post_view.dart` - поддерживает showBackButton

## Примечания

- Кнопка "Вперед" не отображается по умолчанию, но инфраструктура полностью готова
- В мобильных приложениях обычно используется встроенная кнопка "Назад" системы
- На Web версии можно добавить кнопку "Вперед" рядом с "Назад" при необходимости

## Возможные улучшения

1. Добавить поддержку Web-браузерных кнопок "Назад/Вперед"
2. Добавить кнопку "Вперед" в UI для Web версии
3. Сохранять историю при пересоздании приложения (persistent state)
4. Добавить визуальные индикаторы (breadcrumbs) пути навигации
5. Интеграция с фиксированной историей маршрутов в определенных потоках (flows)

