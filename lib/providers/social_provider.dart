import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/social_comment.dart';
import '../models/social_group.dart';
import '../models/social_post.dart';
import '../repositories/social_repository.dart';

class SocialProvider extends ChangeNotifier {
  SocialProvider(this._repository);

  final SocialRepository _repository;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSubmitting = false;
  bool _hasMoreFeed = true;
  String? _errorMessage;
  List<SocialGroup> _groups = <SocialGroup>[];
  List<SocialPost> _feed = <SocialPost>[];
  String? _selectedGroupId;
  int _feedOffset = 0;
  static const int _feedPageSize = 10;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSubmitting => _isSubmitting;
  bool get hasMoreFeed => _hasMoreFeed;
  String? get errorMessage => _errorMessage;
  List<SocialGroup> get groups => List<SocialGroup>.unmodifiable(_groups);
  List<SocialPost> get feed => List<SocialPost>.unmodifiable(_feed);
  String? get selectedGroupId => _selectedGroupId;

  SocialGroup? get selectedGroup {
    final id = _selectedGroupId;
    if (id == null) {
      return null;
    }
    for (final group in _groups) {
      if (group.id == id) {
        return group;
      }
    }
    return null;
  }

  List<SocialPost> get highlightedFeed {
    return feed;
  }

  String? get currentUserId => Supabase.instance.client.auth.currentUser?.id;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final groups = await _repository.fetchGroups();
      final feed = await _repository.fetchFeed(
        limit: _feedPageSize,
        offset: 0,
        currentUserId: currentUserId,
      );
      _groups = groups;
      _feed = feed;
      _feedOffset = feed.length;
      _hasMoreFeed = feed.length == _feedPageSize;
    } catch (error) {
      _errorMessage = 'Не удалось загрузить ленту: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _feedOffset = 0;
    _hasMoreFeed = true;
    _feed = <SocialPost>[];
    await initialize();
  }

  void selectGroup(String? groupId) {
    _selectedGroupId = groupId;
    notifyListeners();
  }

  Future<void> loadMoreFeed() async {
    if (_isLoading || _isLoadingMore || !_hasMoreFeed) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = await _repository.fetchFeed(
        limit: _feedPageSize,
        offset: _feedOffset,
        currentUserId: currentUserId,
      );
      _feed.addAll(nextPage);
      _feedOffset += nextPage.length;
      _hasMoreFeed = nextPage.length == _feedPageSize;
    } catch (error) {
      _errorMessage = 'Не удалось загрузить следующую страницу: $error';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<List<SocialPost>> loadGroupPosts(String groupId) {
    return _repository.fetchPostsForGroup(
      groupId,
      currentUserId: currentUserId,
      limit: 50,
    );
  }

  Future<SocialPost?> fetchPost(String postId) {
    return _repository.fetchPostById(postId, currentUserId: currentUserId);
  }

  Future<List<SocialComment>> fetchComments(String postId) {
    return _repository.fetchComments(postId);
  }

  Future<SocialPost?> createPost({
    required String groupId,
    required String authorName,
    required String title,
    required String content,
    String? tag,
    String? imageUrl,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      _errorMessage = 'Для публикации нужно войти в аккаунт.';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final group = _groups.firstWhere((item) => item.id == groupId);
      final post = await _repository.createPost(
        groupId: group.id,
        groupName: group.name,
        authorId: userId,
        authorName: authorName,
        title: title,
        content: content,
        tag: tag,
        imageUrl: imageUrl,
      );
      _feed = <SocialPost>[post, ..._feed];
      _feedOffset += 1;
      _selectedGroupId = groupId;
      notifyListeners();
      return post;
    } catch (error) {
      _errorMessage = 'Не удалось создать пост: $error';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<SocialPost?> toggleLike(String postId) async {
    final userId = currentUserId;
    if (userId == null) {
      _errorMessage = 'Для лайка нужно войти в аккаунт.';
      notifyListeners();
      return null;
    }

    final updated = await _repository.toggleLike(postId: postId, userId: userId);
    _replacePost(updated);
    notifyListeners();
    return updated;
  }

  Future<SocialComment?> addComment({
    required String postId,
    required String authorName,
    required String content,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      _errorMessage = 'Для комментариев нужно войти в аккаунт.';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    notifyListeners();
    try {
      final comment = await _repository.createComment(
        postId: postId,
        authorId: userId,
        authorName: authorName,
        content: content,
      );
      final updatedPost = await _repository.fetchPostById(postId, currentUserId: userId);
      if (updatedPost != null) {
        _replacePost(updatedPost);
      }
      return comment;
    } catch (error) {
      _errorMessage = 'Не удалось отправить комментарий: $error';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _replacePost(SocialPost updated) {
    final feedIndex = _feed.indexWhere((item) => item.id == updated.id);
    if (feedIndex != -1) {
      _feed[feedIndex] = updated;
    }
  }
}
