class Post {
  final String id;
  final String userName;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  List<String> likedBy;
  List<Comment> comments;

  Post({
    required this.id,
    required this.userName,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.likedBy = const [],
    this.comments = const [],
  });
}

class Comment {
  final String userName;
  final String text;
  final DateTime time;

  Comment({
    required this.userName,
    required this.text,
    required this.time,
  });
}
