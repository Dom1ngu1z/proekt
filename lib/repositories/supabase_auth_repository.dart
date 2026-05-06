import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signIn({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    String? username,
  }) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{
        'display_name': displayName,
        if (username != null && username.isNotEmpty) 'username': username,
      },
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) {
      return null;
    }
    return UserProfile.fromMap(Map<String, dynamic>.from(response as Map));
  }

  @override
  Future<UserProfile> upsertProfile({
    required String userId,
    required String displayName,
    String? username,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{
      'id': userId,
      'display_name': displayName,
      'username': username,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _client
        .from('profiles')
        .upsert(payload)
        .select()
        .single();
    return UserProfile.fromMap(Map<String, dynamic>.from(response as Map));
  }
}


