import '../core/supabase_client.dart';
import '../core/constants.dart';
import '../models/post_model.dart';

class PostService {
  final _client = SupabaseService.client;

 
  Future<List<Post>> fetchPosts({required int page}) async {
    final from = page * AppConstants.pageSize;
    final to = from + AppConstants.pageSize - 1;

    final response = await _client
        .from('posts')
        .select()
        .order('created_at', ascending: false)
        .range(from, to);

    final rows = response as List;
    final postIds = rows.map((p) => p['id'] as String).toList();

    Set<String> likedIds = {};
    if (postIds.isNotEmpty) {
      final likes = await _client
          .from('user_likes')
          .select('post_id')
          .eq('user_id', AppConstants.hardcodedUserId)
          .inFilter('post_id', postIds);
      likedIds = (likes as List).map((l) => l['post_id'] as String).toSet();
    }

    return rows
        .map((json) => Post.fromJson(
              json as Map<String, dynamic>,
              isLiked: likedIds.contains(json['id']),
            ))
        .toList();
  }

  
  Future<void> toggleLikeRpc(String postId) async {
    await _client.rpc('toggle_like', params: {
      'p_post_id': postId,
      'p_user_id': AppConstants.hardcodedUserId,
    });
  }
}