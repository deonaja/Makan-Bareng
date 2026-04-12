class ReviewModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String sessionId;
  final double rating;
  final String comment;
  final DateTime timestamp;

  const ReviewModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.sessionId,
    required this.rating,
    this.comment = '',
    required this.timestamp,
  });
}
