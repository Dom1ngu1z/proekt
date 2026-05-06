import '../models/social_group.dart';
import '../models/social_comment.dart';
import '../models/social_post.dart';
import '../models/user_profile.dart';

abstract class SocialRepository {
  Future<List<SocialGroup>> fetchGroups();
  Future<List<SocialPost>> fetchFeed({
    int limit = 10,
    int offset = 0,
    String? currentUserId,
  });
  Future<List<SocialPost>> fetchPostsForGroup(
    String groupId, {
    int limit = 20,
    int offset = 0,
    String? currentUserId,
  });
  Future<SocialPost?> fetchPostById(String postId, {String? currentUserId});
  Future<List<SocialComment>> fetchComments(String postId);
  Future<SocialPost> createPost({
    required String groupId,
    required String groupName,
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    String? tag,
    String? imageUrl,
  });
  Future<SocialComment> createComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
  });
  Future<SocialPost> toggleLike({
    required String postId,
    required String userId,
  });
  Future<UserProfile?> fetchProfile(String userId);
  Future<UserProfile> upsertProfile({
    required String userId,
    required String displayName,
    String? username,
    String? avatarUrl,
  });
}

