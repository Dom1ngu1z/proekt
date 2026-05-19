# Соцсеть группы

Мини-приложение на Flutter для учебного проекта по теме социальной сети групп.

##Что реализовано

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

Откройте `lib/config/supabase_config.dart`


## Запуск

```powershell
flutter pub get
flutter run
```


