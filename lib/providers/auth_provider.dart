import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;
  StreamSubscription<AuthState>? _subscription;

  bool _isBootstrapping = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  Session? _session;
  UserProfile? _profile;

  bool get isBootstrapping => _isBootstrapping;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _session != null;
  Session? get session => _session;
  UserProfile? get profile => _profile;
  String get displayName => _profile?.displayName ?? _session?.user.email ?? 'Пользователь';
  String get email => _session?.user.email ?? '';

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    _session = _repository.currentSession;
    if (_session != null) {
      _profile = await _repository.fetchProfile(_session!.user.id);
    }
    _subscription ??= _repository.authStateChanges.listen(_handleAuthStateChange);
    _isBootstrapping = false;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.signIn(email: email, password: password);
      return true;
    } catch (error) {
      _errorMessage = 'Не удалось войти: $error';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    String? username,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
        username: username,
      );
      return true;
    } catch (error) {
      _errorMessage = 'Не удалось зарегистрироваться: $error';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.signOut();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    final userId = _session?.user.id;
    if (userId == null) {
      return;
    }
    _profile = await _repository.fetchProfile(userId);
    notifyListeners();
  }

  Future<void> ensureProfile({required String displayName, String? username}) async {
    final userId = _session?.user.id;
    if (userId == null) {
      return;
    }
    _profile = await _repository.upsertProfile(
      userId: userId,
      displayName: displayName,
      username: username,
    );
    notifyListeners();
  }

  Future<void> _handleAuthStateChange(AuthState data) async {
    _session = data.session;
    if (_session == null) {
      _profile = null;
    } else {
      _profile = await _repository.fetchProfile(_session!.user.id);
      _profile ??= await _repository.upsertProfile(
        userId: _session!.user.id,
        displayName: _session!.user.userMetadata?['display_name']?.toString() ?? _session!.user.email ?? 'Пользователь',
        username: _session!.user.userMetadata?['username']?.toString(),
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}


