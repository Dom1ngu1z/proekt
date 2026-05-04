# Соцсеть группы

Мини-приложение на Flutter для учебного проекта по теме социальной сети групп.

## Что реализовано

- 4 экрана с навигацией через `go_router`
- Управление состоянием через `Provider`
- Работа с данными через `Supabase` с локальным fallback-режимом
- Форма создания поста с валидацией
- Архитектурное разделение на `models`, `repositories`, `providers`, `views`, `widgets`

## Структура

- `lib/models` — модели данных групп и постов
- `lib/repositories` — источник данных и интеграция с Supabase
- `lib/providers` — состояние приложения
- `lib/views` — экраны
- `lib/widgets` — переиспользуемые компоненты

## Настройка Supabase

Откройте `lib/config/supabase_config.dart` и замените:

- `YOUR_PROJECT`
- `YOUR_SUPABASE_ANON_KEY`

### Ожидаемые таблицы

#### `groups`

- `id` text / uuid
- `name` text
- `description` text
- `category` text
- `members_count` int
- `accent_color` text, например `#6750A4`
- `cover_image_url` text, необязательно

#### `posts`

- `id` text / uuid
- `group_id` text
- `group_name` text
- `author_name` text
- `title` text
- `content` text
- `created_at` timestamp / text
- `likes_count` int
- `tag` text, необязательно
- `image_url` text, необязательно

## Запуск

```powershell
flutter pub get
flutter run
```

Если Supabase не настроен, приложение всё равно запустится на локальных демо-данных.
