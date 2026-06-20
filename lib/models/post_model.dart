class Post {
  final String id;
  final DateTime createdAt;
  final String thumbUrl;
  final String mobileUrl;
  final String rawUrl;
  final int likeCount;
  final bool isLiked;

  const Post({
    required this.id,
    required this.createdAt,
    required this.thumbUrl,
    required this.mobileUrl,
    required this.rawUrl,
    required this.likeCount,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json, {bool isLiked = false}) {
    return Post(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      thumbUrl: json['media_thumb_url'] as String? ?? '',
      mobileUrl: json['media_mobile_url'] as String? ?? '',
      rawUrl: json['media_raw_url'] as String? ?? '',
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: isLiked,
    );
  }

  Post copyWith({int? likeCount, bool? isLiked}) {
    return Post(
      id: id,
      createdAt: createdAt,
      thumbUrl: thumbUrl,
      mobileUrl: mobileUrl,
      rawUrl: rawUrl,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}