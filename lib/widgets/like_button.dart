import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../providers/feed_provider.dart';

class LikeButton extends ConsumerWidget {
  final Post post;
  const LikeButton({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        GestureDetector(
          // Spam-tap as fast as you want — handled by the debounce
          // logic in FeedNotifier, not here.
          onTap: () => ref.read(feedProvider.notifier).toggleLike(post.id),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              post.isLiked ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(post.isLiked),
              color: post.isLiked ? Colors.red : Colors.grey[700],
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${post.likeCount}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }
}