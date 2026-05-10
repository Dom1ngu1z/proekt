# 🚀 Quick Start: Функциональность "Назад и Вперед"

## ⏱️ За 5 минут

### Что было добавлено?
**Кнопка "Назад" ← автоматически активируется на всех страницах деталей**

### Как это выглядит?
```
Обычный экран:          Экран деталей:
┌──────────────┐        ┌──────────────┐
│   Пост       │   →    │ ← Пост       │  ← Новая кнопка!
├──────────────┤        ├──────────────┤
│ Содержимое   │        │ Содержимое   │
└──────────────┘        └──────────────┘
```

### Как это работает?
1. Пользователь открывает пост → `context.go('/post/123')`
2. GoRouter регистрирует это в истории
3. Страница отображается с кнопкой ← 
4. Пользователь нажимает ← → `context.pop()`
5. Возврат на предыдущий экран

---

## 💻 Для разработчиков

### Использование в существующих экранах
**Ничего не менять!** Кнопка добавляется автоматически для:
- ✅ PostDetailView
- ✅ GroupDetailView
- ✅ CreatePostView (когда открывается из деталей)

### Создание нового экрана деталей
```dart
import 'package:flutter/material.dart';
import '../widgets/detail_scaffold.dart';

class MyDetailPage extends StatelessWidget {
  final String id;
  
  const MyDetailPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Мой экран',
      actions: [myButton],  // Optional
      child: MyContent(),
    );
  }
}
```

### Прямое управление навигацией
```dart
// Получить провайдер
final navHistory = context.read<NavigationHistoryProvider>();

// Проверить возможность
print('Может назад? ${navHistory.canGoBack}');      // true/false
print('Может вперед? ${navHistory.canGoForward}');  // true/false

// Перемещаться
if (navHistory.canGoBack) {
  navHistory.goBack();  // Вернуться на один шаг
}

if (navHistory.canGoForward) {
  navHistory.goForward();  // Перейти на один шаг вперед
}

// Посмотреть историю
print('История маршрутов: ${navHistory.history}');
// Output: ['/home', '/group/456', '/post/123']
```

---

## 📱 Примеры использования

### Пример 1: Открыть пост с историей
```dart
// В HomeView → PostCard
onTap: () {
  context.go('/post/${post.id}');
  // История: ['/', '/home', '/post/123']
  // Кнопка ← вернет на '/home'
}
```

### Пример 2: Открыть группу
```dart
// В HomeView → GroupCard
onTap: () {
  context.go('/group/${group.id}');
  // История: ['/', '/home', '/group/456']
  // Кнопка ← вернет на '/home'
}
```

### Пример 3: Создать пост из группы
```dart
// В GroupDetailView
onPressed: () {
  provider.selectGroup(group.id);
  context.go('/create');
  // История: ['/', '/home', '/group/456', '/create']
  // CreatePostView покажет кнопку ← 
  // Нажатие вернет на '/group/456'
}
```

### Пример 4: Условная кнопка "Назад"
```dart
// В любом виджете
if (context.canPop()) {
  IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Navigator.of(context).pop(),
  );
}
```

---

## 🎯 Главные компоненты

### 1️⃣ DetailScaffold
```dart
DetailScaffold(
  title: 'Название',              // Заголовок в AppBar
  actions: [button1, button2],    // Действия справа (optional)
  child: pageContent,             // Основной контент
)
// Автоматически добавляет кнопку ← слева
```

### 2️⃣ NavigationHistoryProvider
```dart
// Import
import 'providers/navigation_history_provider.dart';

// Использование
final navHistory = context.read<NavigationHistoryProvider>();
final canGoBack = navHistory.canGoBack;
final history = navHistory.history;

// Методы
navHistory.push('/route');
navHistory.goBack();
navHistory.goForward();
navHistory.clear();
```

### 3️⃣ Обновленный MainScaffold
```dart
MainScaffold(
  title: 'Название',
  selectedIndex: 0,
  showBackButton: false,  // Новое! Показать кнопку ←
  child: content,
)
```

---

## ✅ Чек-лист реализации

- [x] DetailScaffold создан и работает
- [x] NavigationHistoryProvider создан и работает
- [x] GoRouter отслеживает историю
- [x] PostDetailView использует новый scaffold
- [x] GroupDetailView использует новый scaffold
- [x] CreatePostView поддерживает adaptive кнопку
- [x] Все тесты пройдены
- [x] Анализ кода без ошибок
- [x] Документация написана
- [x] Готово к production

---

## 🧪 Тестирование

### Локально
```bash
# Проверить синтаксис
flutter analyze
# ✅ No issues found!

# Запустить тесты
flutter test test/widget_test.dart
# ✅ All tests passed!

# Запустить приложение
flutter run
```

### На устройстве
1. Откройте ленту постов
2. Нажмите на пост → видно кнопку ←
3. Нажмите ← → вернулись на ленту
4. Откройте группу → видно кнопку ←
5. Нажмите ← → вернулись на ленту

---

## 🎨 Визуальные примеры

### По умолчанию (без ← кнопки)
```
┌──────────────────────────────┐
│ Лента                    🔄  │
├──────────────────────────────┤
│                              │
│  Список постов...            │
│                              │
└──────────────────────────────┘
```

### С ← кнопкой (PostDetailView)
```
┌──────────────────────────────┐
│ ← Пост                    ❤️  │  ← Новая функция!
├──────────────────────────────┤
│                              │
│  Полный контент поста        │
│  + Комментарии               │
│                              │
└──────────────────────────────┘
```

---

## 📊 Структура истории

### Что происходит при навигации

```
User action                  → Результат в истории
─────────────────────────────────────────────────────
1. Открывает приложение      → ['/loading'] または ['/auth']
2. Успешно входит            → ['/loading', '/home']
3. Нажимает на пост          → ['/loading', '/home', '/post/123']
4. Нажимает ←                → ['/loading', '/home'] (текущий: '/home')
5. Нажимает на группу        → ['/loading', '/home', '/group/456']
6. Нажимает ← из группы      → ['/loading', '/home'] (текущий: '/home')
```

---

## 🚀 Производительность

- **Нулевые оверхеды** - отслеживание происходит в redirect()
- **Нет лишних перестроек** - используется notifyListeners() только при смене
- **Оптимизировано** - не добавляет дубли маршрутов
- **Type-safe** - полная поддержка типов Dart

---

## 💡 Советы и трюки

### Проверить историю в консоли
```dart
final navHistory = context.read<NavigationHistoryProvider>();
debugPrint('История навигации: ${navHistory.history}');
debugPrint('Текущий индекс: ${navHistory.currentIndex}');
debugPrint('Может вернуться? ${navHistory.canGoBack}');
debugPrint('Может перейти вперед? ${navHistory.canGoForward}');
```

### Очистить историю при logout
```dart
@override
void signOut() async {
  // ... logout logic
  context.read<NavigationHistoryProvider>().clear();
  context.go('/auth');
}
```

### Пользовательская логика навигации
```dart
// Хотите вернуться на 2 шага назад?
// Используйте GoRouter напрямую
context.go('/group/${previousGroupId}');

// Или управляйте историей вручную
final navHistory = context.read<NavigationHistoryProvider>();
for (int i = 0; i < 2; i++) {
  navHistory.goBack();
}
```

---

## ❓ Часто задаваемые вопросы

### Q: Кнопка "Вперед" нужна?
**A:** Инфраструктура готова! Просто используйте `canGoForward` и `goForward()` если нужно.

### Q: Работает ли с жестом свайпа (iOS)?
**A:** Да! Наша кнопка ← + встроенный жест свайпа работают вместе.

### Q: Можно ли отключить кнопку?
**A:** Нет нужды - она только показывается когда `context.canPop()` == true.

### Q: Как это влияет на производительность?
**A:** Минимально - всего несколько строк в redirect() callback'е.

### Q: Совместимо ли с web?
**A:** Да! На Web можно добавить кнопку "Вперед" рядом с "Назад".

---

## 📚 Дополнительная информация

Для получения дополнительной информации см.:
- **COMPLETION_SUMMARY.md** - Полный отчет
- **NAVIGATION_FEATURES.md** - Архитектура и детали
- **NAVIGATION_UPDATE.md** - Примеры использования
- **FILES_SUMMARY.md** - Список всех изменений
- **PROJECT_INDEX.md** - Структура всего проекта

---

## ✨ Результат

✅ **Кнопка "Назад" работает на всех экранах деталей**  
✅ **История навигации отслеживается автоматически**  
✅ **Type-safe и производительно**  
✅ **Полная инфраструктура для расширения**  
✅ **Все тесты пройдены**  
✅ **Готово к использованию в production**  

---

**Дата**: 10 мая 2026  
**Версия**: 2.0  
**Статус**: ✅ ГОТОВО

