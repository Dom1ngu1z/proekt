import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

abstract class AuthRepository {
  Session? get currentSession;

  Stream<AuthState> get authStateChanges;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
    String? username,
  });

  Future<void> signOut();

  Future<UserProfile?> fetchProfile(String userId);

  Future<UserProfile> upsertProfile({
    required String userId,
    required String displayName,
    String? username,
    String? avatarUrl,
  });
}

