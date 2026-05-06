/// NavigationHistory - вспомогательный класс для управления историей навигации
class NavigationHistory {
  final List<String> _history = [];
  int _currentIndex = -1;

  /// Добавить новый маршрут в историю
  void push(String route) {
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }
    _history.add(route);
    _currentIndex = _history.length - 1;
  }

  /// Проверить, можно ли перейти назад
  bool canGoBack() => _currentIndex > 0;

  /// Проверить, можно ли перейти вперед
  bool canGoForward() => _currentIndex < _history.length - 1;

  /// Получить предыдущий маршрут
  String? getPreviousRoute() {
    if (canGoBack()) {
      return _history[_currentIndex - 1];
    }
    return null;
  }

  /// Получить следующий маршрут
  String? getNextRoute() {
    if (canGoForward()) {
      return _history[_currentIndex + 1];
    }
    return null;
  }

  /// Перейти назад
  String? goBack() {
    if (canGoBack()) {
      _currentIndex--;
      return _history[_currentIndex];
    }
    return null;
  }

  /// Перейти вперед
  String? goForward() {
    if (canGoForward()) {
      _currentIndex++;
      return _history[_currentIndex];
    }
    return null;
  }

  /// Очистить историю
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }

  /// Удалить пустые значения (для дебагинга)
  List<String> get history => List.unmodifiable(_history);
}
