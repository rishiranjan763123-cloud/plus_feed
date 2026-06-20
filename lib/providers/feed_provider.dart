import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

final likeErrorProvider = StateProvider<String?>((ref) => null);

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Post>>(
  FeedNotifier.new,
);

class FeedNotifier extends AsyncNotifier<List<Post>> {
  final PostService _service = PostService();

  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  final Map<String, int> _pendingTaps = {};
  final Map<String, Post> _originalSnapshots = {};
  final Map<String, Timer> _debounceTimers = {};

  bool get hasMore => _hasMore;

  @override
  Future<List<Post>> build() async {
    _page = 0;
    _hasMore = true;
    return _service.fetchPosts(page: 0);
  }

  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.fetchPosts(page: 0));
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    final currentList = state.value;
    if (currentList == null) return;

    _isLoadingMore = true;
    _page++;
    try {
      final newPosts = await _service.fetchPosts(page: _page);
      if (newPosts.length < AppConstants.pageSize) {
        _hasMore = false;
      }
      state = AsyncData([...currentList, ...newPosts]);
    } catch (_) {
      _page--;
    } finally {
      _isLoadingMore = false;
    }
  }

  void toggleLike(String postId) {
    final currentList = state.value;
    if (currentList == null) return;
    final index = currentList.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    _originalSnapshots.putIfAbsent(postId, () => currentList[index]);

    final post = currentList[index];
    final newIsLiked = !post.isLiked;
    final newCount = newIsLiked ? post.likeCount + 1 : post.likeCount - 1;
    final updated = post.copyWith(isLiked: newIsLiked, likeCount: newCount);

    final newList = [...currentList];
    newList[index] = updated;
    state = AsyncData(newList);

    _pendingTaps[postId] = (_pendingTaps[postId] ?? 0) + 1;

    _debounceTimers[postId]?.cancel();
    _debounceTimers[postId] = Timer(
      AppConstants.likeDebounceDuration,
      () => _syncLike(postId),
    );
  }

  Future<void> _syncLike(String postId) async {
    final taps = _pendingTaps.remove(postId) ?? 0;
    final original = _originalSnapshots.remove(postId);

    final isOddNumberOfTaps = taps % 2 == 1;
    if (!isOddNumberOfTaps) return;

    try {
      await _service.toggleLikeRpc(postId);
    } catch (_) {
      if (original != null) {
        final currentList = state.value;
        if (currentList != null) {
          final idx = currentList.indexWhere((p) => p.id == postId);
          if (idx != -1) {
            final reverted = [...currentList];
            reverted[idx] = original;
            state = AsyncData(reverted);
          }
        }
      }
      ref.read(likeErrorProvider.notifier).state =
          "Couldn't update like. Check your connection.";
    }
  }
}