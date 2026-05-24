import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String sessionId;
  final String sessionTitle; // DENORMALIZED — tampil tanpa query sessions

  // Reviewer (yang ngasih review) — DENORMALIZED dari users
  final String reviewerId;
  final String reviewerName;
  final String reviewerPhotoUrl;

  // Reviewee (yang direview) — DENORMALIZED dari users
  final String revieweeId;
  final String revieweeName;

  final double rating; // 1.0 - 5.0
  final String comment; // boleh kosong
  final DateTime createdAt;

  const ReviewModel({
    required this.reviewId,
    required this.sessionId,
    required this.sessionTitle,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerPhotoUrl,
    required this.revieweeId,
    required this.revieweeName,
    required this.rating,
    this.comment = '',
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReviewModel(
      reviewId: doc.id,
      sessionId: data['sessionId'] ?? '',
      sessionTitle: data['sessionTitle'] ?? '',
      reviewerId: data['reviewerId'] ?? '',
      reviewerName: data['reviewerName'] ?? '',
      reviewerPhotoUrl: data['reviewerPhotoUrl'] ?? '',
      revieweeId: data['revieweeId'] ?? '',
      revieweeName: data['revieweeName'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reviewId': reviewId,
      'sessionId': sessionId,
      'sessionTitle': sessionTitle,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerPhotoUrl': reviewerPhotoUrl,
      'revieweeId': revieweeId,
      'revieweeName': revieweeName,
      'rating': rating,
      'comment': comment,
      // createdAt di-set oleh ReviewService pakai FieldValue.serverTimestamp()
    };
  }

  ReviewModel copyWith({
    String? reviewId,
    String? sessionId,
    String? sessionTitle,
    String? reviewerId,
    String? reviewerName,
    String? reviewerPhotoUrl,
    String? revieweeId,
    String? revieweeName,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      sessionId: sessionId ?? this.sessionId,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerPhotoUrl: reviewerPhotoUrl ?? this.reviewerPhotoUrl,
      revieweeId: revieweeId ?? this.revieweeId,
      revieweeName: revieweeName ?? this.revieweeName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}