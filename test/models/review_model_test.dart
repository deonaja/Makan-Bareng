import 'package:flutter_test/flutter_test.dart';
import 'package:makan_bareng/models/review_model.dart';

void main() {
  group('ReviewModel', () {
    final reviewDummy = ReviewModel(
      reviewId: 'review_001',
      sessionId: 'session_abc',
      sessionTitle: 'Makan Siang Bareng',
      reviewerId: 'user_reviewer',
      reviewerName: 'Budi',
      reviewerPhotoUrl: 'https://example.com/budi.jpg',
      revieweeId: 'user_reviewee',
      revieweeName: 'Siti',
      rating: 4.5,
      comment: 'Orangnya asik dan tepat waktu!',
      createdAt: DateTime(2026, 5, 24, 12, 0),
    );

    test('semua field tersimpan dengan benar saat konstruksi', () {
      expect(reviewDummy.reviewId, 'review_001');
      expect(reviewDummy.sessionId, 'session_abc');
      expect(reviewDummy.sessionTitle, 'Makan Siang Bareng');
      expect(reviewDummy.reviewerId, 'user_reviewer');
      expect(reviewDummy.reviewerName, 'Budi');
      expect(reviewDummy.reviewerPhotoUrl, 'https://example.com/budi.jpg');
      expect(reviewDummy.revieweeId, 'user_reviewee');
      expect(reviewDummy.revieweeName, 'Siti');
      expect(reviewDummy.rating, 4.5);
      expect(reviewDummy.comment, 'Orangnya asik dan tepat waktu!');
    });

    test('comment default kosong kalau tidak diisi', () {
      final tanpaComment = ReviewModel(
        reviewId: 'r_002',
        sessionId: 'session_xyz',
        sessionTitle: 'Makan Malam',
        reviewerId: 'user_a',
        reviewerName: 'Andi',
        reviewerPhotoUrl: '',
        revieweeId: 'user_b',
        revieweeName: 'Rina',
        rating: 3.0,
        createdAt: DateTime(2026, 5, 24),
      );
      expect(tanpaComment.comment, '');
    });

    test('toFirestore() menghasilkan map dengan field yang benar', () {
      final map = reviewDummy.toFirestore();

      expect(map['reviewId'], 'review_001');
      expect(map['sessionId'], 'session_abc');
      expect(map['sessionTitle'], 'Makan Siang Bareng');
      expect(map['reviewerId'], 'user_reviewer');
      expect(map['reviewerName'], 'Budi');
      expect(map['reviewerPhotoUrl'], 'https://example.com/budi.jpg');
      expect(map['revieweeId'], 'user_reviewee');
      expect(map['revieweeName'], 'Siti');
      expect(map['rating'], 4.5);
      expect(map['comment'], 'Orangnya asik dan tepat waktu!');
    });

    test('toFirestore() TIDAK boleh mengandung createdAt', () {
      final map = reviewDummy.toFirestore();
      expect(map.containsKey('createdAt'), isFalse);
    });

    test('copyWith() menghasilkan instance baru dengan field yang di-override', () {
      final updated = reviewDummy.copyWith(
        rating: 5.0,
        comment: 'Luar biasa!',
      );

      expect(updated.rating, 5.0);
      expect(updated.comment, 'Luar biasa!');
      expect(updated.reviewId, reviewDummy.reviewId);
      expect(updated.reviewerId, reviewDummy.reviewerId);
      expect(updated.revieweeId, reviewDummy.revieweeId);
    });

    test('copyWith() tidak mengubah instance asli (immutable)', () {
      reviewDummy.copyWith(rating: 1.0);
      expect(reviewDummy.rating, 4.5);
    });

    test('rating 1.0 dan 5.0 adalah nilai valid (boundary test)', () {
      final minRating = reviewDummy.copyWith(rating: 1.0);
      final maxRating = reviewDummy.copyWith(rating: 5.0);
      expect(minRating.rating, 1.0);
      expect(maxRating.rating, 5.0);
    });
  });
}