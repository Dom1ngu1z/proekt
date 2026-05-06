import 'package:flutter/foundation.dart';

/// NavigationHistoryProvider - управляет историей навигации между экранами
class NavigationHistoryProvider extends ChangeNotifier {
  final List<String> _history = [];
  int _currentIndex = -1;

  /// Добавить новый маршрут в историю
  void push(String route) {
    // Удаляем все маршруты после текущего (если мы вернулись назад и перешли куда-то еще)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // Не добавляем дублирующиеся маршруты подряд
    if (_history.isEmpty || _history.last != route) {
      _history.add(route);
      _currentIndex = _history.length - 1;
      notifyListeners();
    }
  }

  /// Проверить, можно ли перейти назад
  bool get canGoBack => _currentIndex > 0;

  /// Проверить, можно ли перейти вперед
  bool get canGoForward => _currentIndex < _history.length - 1;

  /// Получить предыдущий маршрут
  String? getPreviousRoute() {
    if (canGoBack) {
      return _history[_currentIndex - 1];
    }
    return null;
  }

  /// Получить следующий маршрут
  String? getNextRoute() {
    if (canGoForward) {
      return _history[_currentIndex + 1];
    }
    return null;
  }

  /// Перейти назад
  String? goBack() {
    if (canGoBack) {
      _currentIndex--;
      notifyListeners();
      return _history[_currentIndex];
    }
    return null;
  }

  /// Перейти вперед
  String? goForward() {
    if (canGoForward) {
      _currentIndex++;
      notifyListeners();
      return _history[_currentIndex];
    }
    return null;
  }

  /// Очистить историю
  void clear() {
    _history.clear();
    _currentIndex = -1;
    notifyListeners();
  }

  /// Получить всю историю для дебагинга
  List<String> get history => List.unmodifiable(_history);

  /// Получить текущий индекс
  int get currentIndex => _currentIndex;
}

