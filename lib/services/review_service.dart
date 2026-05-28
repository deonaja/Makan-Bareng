import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  // Singleton — ref: SPEC Section 8.1 aturan ke-5
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _reviews => _firestore.collection('reviews');
  CollectionReference get _users => _firestore.collection('users');

  Future<void> submitReview({
    required String sessionId,
    required String sessionTitle,
    required String reviewerId,
    required String reviewerName,
    required String reviewerPhotoUrl,
    required String revieweeId,
    required String revieweeName,
    required double rating,
    String comment = '',
  }) async {
    try {
      // Validasi rating sebelum kirim ke Firestore (extra safety di luar Rules)
      // Ref: SPEC Section 9.3 — rating validation
      if (rating < 1.0 || rating > 5.0) {
        throw Exception('Rating harus antara 1 sampai 5');
      }

      // Cek double rating — satu user tidak boleh review orang yang sama di sesi yang sama
      final existing = await _reviews
          .where('reviewerId', isEqualTo: reviewerId)
          .where('revieweeId', isEqualTo: revieweeId)
          .where('sessionId', isEqualTo: sessionId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Kamu sudah memberikan review kepada pengguna ini di sesi ini');
      }

      final newReviewRef = _reviews.doc(); // auto-generated ID
      final revieweeRef = _users.doc(revieweeId);

      // Jalankan transaction — atomic update reviews + users counter
      // Ref: SPEC Section 7 — review WAJIB pakai transaction biar rating akurat
      await _firestore.runTransaction((transaction) async {
        // Baca data user yang direview untuk kalkulasi averageRating baru
        final revieweeSnap = await transaction.get(revieweeRef);
        if (!revieweeSnap.exists) {
          throw Exception('Pengguna yang akan direview tidak ditemukan');
        }

        final revieweeData = revieweeSnap.data() as Map<String, dynamic>;
        final currentTotal = (revieweeData['totalReviews'] ?? 0) as int;
        final currentAvg = (revieweeData['averageRating'] ?? 0.0).toDouble();

        // Hitung averageRating baru secara incremental
        // newAvg = (oldAvg * oldCount + newRating) / newCount
        final newTotal = currentTotal + 1;
        final newAvg = ((currentAvg * currentTotal) + rating) / newTotal;

        // 1. Buat review document baru
        transaction.set(newReviewRef, {
          'reviewId': newReviewRef.id,
          'sessionId': sessionId,
          'sessionTitle': sessionTitle,
          'reviewerId': reviewerId,
          'reviewerName': reviewerName,
          'reviewerPhotoUrl': reviewerPhotoUrl,
          'revieweeId': revieweeId,
          'revieweeName': revieweeName,
          'rating': rating,
          'comment': comment,
          'createdAt': FieldValue.serverTimestamp(), // SPEC: pakai serverTimestamp
        });

        // 2. Update counter di users/{revieweeId}
        // Ref: SPEC Section 5.1 — averageRating & totalReviews adalah denormalized counter
        transaction.update(revieweeRef, {
          'averageRating': double.parse(newAvg.toStringAsFixed(1)),
          'totalReviews': newTotal,
        });
      });
    } catch (e) {
      throw Exception('Gagal mengirim review: $e');
    }
  }

  Stream<List<ReviewModel>> streamReviewsForUser(String userId) {
    try {
      return _reviews
          .where('revieweeId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList());
    } catch (e) {
      throw Exception('Gagal memuat review pengguna: $e');
    }
  }

  Stream<List<ReviewModel>> streamReviewsForSession(String sessionId) {
    try {
      return _reviews
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList());
    } catch (e) {
      throw Exception('Gagal memuat review sesi: $e');
    }
  }

  Future<bool> hasReviewed({
    required String reviewerId,
    required String revieweeId,
    required String sessionId,
  }) async {
    try {
      final result = await _reviews
          .where('reviewerId', isEqualTo: reviewerId)
          .where('revieweeId', isEqualTo: revieweeId)
          .where('sessionId', isEqualTo: sessionId)
          .limit(1)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal memeriksa status review: $e');
    }
  }
}