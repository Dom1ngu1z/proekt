import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/social_comment.dart';
import '../models/social_group.dart';
import '../models/social_post.dart';
import '../models/user_profile.dart';
import 'social_repository.dart';

class SupabaseSocialRepository implements SocialRepository {
  SupabaseSocialRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<SocialGroup>> fetchGroups() async {
    final response = await _client.from('groups').select().order('name');
    return (response as List<dynamic>)
        .map((row) => SocialGroup.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<List<SocialPost>> fetchFeed({
    int limit = 10,
    int offset = 0,
    String? currentUserId,
  }) async {
    final response = await _client
        .from('posts')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    final posts = _mapPosts(response);
    return _applyLikeState(posts, currentUserId);
  }

  @override
  Future<List<SocialPost>> fetchPostsForGroup(
    String groupId, {
    int limit = 20,
    int offset = 0,
    String? currentUserId,
  }) async {
    final response = await _client
        .from('posts')
        .select()
        .eq('group_id', groupId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    final posts = _mapPosts(response);
    return _applyLikeState(posts, currentUserId);
  }

  @override
  Future<SocialPost?> fetchPostById(String postId, {String? currentUserId}) async {
    final response = await _client.from('posts').select().eq('id', postId).maybeSingle();
    if (response == null) {
      return null;
    }
    final post = SocialPost.fromMap(Map<String, dynamic>.from(response as Map));
    final posts = await _applyLikeState(<SocialPost>[post], currentUserId);
    return posts.first;
  }

  @override
  Future<List<SocialComment>> fetchComments(String postId) async {
    final response = await _client
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: true);
    return (response as List<dynamic>)
        .map((row) => SocialComment.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<SocialPost> createPost({
    required String groupId,
    required String groupName,
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    String? tag,
    String? imageUrl,
  }) async {
    final payload = <String, dynamic>{
      'group_id': groupId,
      'group_name': groupName,
      'author_id': authorId,
      'author_name': authorName,
      'title': title,
      'content': content,
      'tag': tag,
      'image_url': imageUrl,
    };

    final response = await _client.from('posts').insert(payload).select().single();
    return SocialPost.fromMap(Map<String, dynamic>.from(response as Map));
  }

  @override
  Future<SocialComment> createComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
  }) async {
    final response = await _client
        .from('comments')
        .insert(<String, dynamic>{
          'post_id': postId,
          'author_id': authorId,
          'author_name': authorName,
          'content': content,
        })
        .select()
        .single();
    return SocialComment.fromMap(Map<String, dynamic>.from(response as Map));
  }

  @override
  Future<SocialPost> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final existing = await _client
        .from('post_likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing == null) {
      await _client.from('post_likes').insert(<String, dynamic>{
        'post_id': postId,
        'user_id': userId,
      });
    } else {
      await _client
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    }

    final updated = await fetchPostById(postId, currentUserId: userId);
    if (updated == null) {
      throw StateError('Post not found after toggling like');
    }
    return updated;
  }

  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    final response = await _client.from('profiles').select().eq('id', userId).maybeSingle();
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
    final response = await _client
        .from('profiles')
        .upsert(<String, dynamic>{
          'id': userId,
          'display_name': displayName,
          'username': username,
          'avatar_url': avatarUrl,
        })
        .select()
        .single();
    return UserProfile.fromMap(Map<String, dynamic>.from(response as Map));
  }

  List<SocialPost> _mapPosts(dynamic response) {
    return (response as List<dynamic>)
        .map((row) => SocialPost.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<List<SocialPost>> _applyLikeState(List<SocialPost> posts, String? currentUserId) async {
    if (currentUserId == null || posts.isEmpty) {
      return posts;
    }

    final ids = posts.map((post) => post.id).toList();
    final response = await _client
        .from('post_likes')
        .select('post_id')
        .eq('user_id', currentUserId)
        .inFilter('post_id', ids);
    final likedIds = (response as List<dynamic>)
        .map((row) => (row as Map)['post_id']?.toString() ?? '')
        .toSet();

    return posts
        .map(
          (post) => post.copyWith(isLikedByMe: likedIds.contains(post.id)),
        )
        .toList();
  }
}
