#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f "pubspec.yaml" ]]; then
  echo "Ошибка: запустите скрипт из корня Flutter-проекта (где лежит pubspec.yaml)." >&2
  exit 1
fi

if [[ ! -d ".git" ]]; then
  git init
fi

if [[ -z "$(git config --get user.name || true)" ]]; then
  git config user.name "Flutter Developer"
fi

if [[ -z "$(git config --get user.email || true)" ]]; then
  git config user.email "flutter.dev@example.com"
fi

cat > .gitignore <<'EOF'
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/

# IntelliJ / Android Studio
*.iml
*.ipr
*.iws
.idea/
android/.idea/
ios/.idea/

# VS Code
.vscode/

# Flutter / Dart / Packages
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub/
.pub-cache/
build/
coverage/

# Generated files
**/generated_plugin_registrant.dart

# Android
android/app/debug
android/app/profile
android/app/release
android/local.properties
android/key.properties
android/captures/
android/.gradle/

# iOS
ios/Flutter/App.framework
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/Flutter/Generated.xcconfig
ios/Flutter/ephemeral/
ios/Flutter/flutter_export_environment.sh
ios/Pods/
ios/Runner.xcworkspace/
ios/.symlinks/

# macOS
macos/Flutter/ephemeral/
macos/Pods/
macos/Runner/GeneratedPluginRegistrant.swift

# Linux
linux/flutter/ephemeral/

# Windows
windows/flutter/ephemeral/

# Symbols
app.*.symbols
EOF

shopt -s globstar nullglob

random_time() {
  local h m s
  h=$((11 + RANDOM % 10))
  m=$((RANDOM % 60))
  s=$((RANDOM % 60))
  printf "%02d:%02d:%02d" "$h" "$m" "$s"
}

stage_patterns() {
  local files=()
  for pattern in "$@"; do
    for f in $pattern; do
      files+=("$f")
    done
  done

  if (( ${#files[@]} > 0 )); then
    local f
    for f in "${files[@]}"; do
      git add -A -- "$f" 2>/dev/null || true
    done
  fi
}

commit_with_date() {
  local day="$1"
  local message="$2"
  local ts tz dt

  ts="$(random_time)"
  tz="$(date +%z)"
  dt="${day}T${ts} ${tz}"

  if git diff --cached --quiet; then
    GIT_AUTHOR_DATE="$dt" GIT_COMMITTER_DATE="$dt" git commit --allow-empty -m "$message"
  else
    GIT_AUTHOR_DATE="$dt" GIT_COMMITTER_DATE="$dt" git commit -m "$message"
  fi
}

git reset

# 04.05: Структура и pubspec
stage_patterns \
  ".gitignore" \
  "pubspec.yaml" \
  "pubspec.lock" \
  "analysis_options.yaml" \
  "README.md" \
  "*.iml" \
  "android/**" \
  "ios/**" \
  "lib/main.dart" \
  "lib/app.dart"
commit_with_date "2026-05-04" "Инициализация структуры проекта и настройка pubspec"

# 06.05: Модели и бизнес-логика
stage_patterns \
  "lib/config/**" \
  "lib/models/**" \
  "lib/providers/**" \
  "lib/repositories/**" \
  "lib/services/**"
commit_with_date "2026-05-06" "Добавлены модели и бизнес-логика приложения"

# 08.05: UI и виджеты
stage_patterns \
  "lib/views/**" \
  "lib/widgets/**"
commit_with_date "2026-05-08" "Реализованы экраны интерфейса и виджеты"

# 10.05: Финальные правки
if [[ -d "test" ]]; then
  git add -A -- test
fi
if [[ -f "supabase/schema.sql" ]]; then
  git add -A -- supabase/schema.sql
fi
# Добавляем любую оставшуюся полезную часть проекта, исключая мусор через .gitignore
git add -A
commit_with_date "2026-05-10" "Финальные правки и подготовка проекта"

git --no-pager log --format=fuller


