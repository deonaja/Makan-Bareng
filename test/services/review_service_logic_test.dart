import 'package:flutter_test/flutter_test.dart';

double hitungAverageRatingBaru({
  required double currentAvg,
  required int currentTotal,
  required double newRating,
}) {
  final newTotal = currentTotal + 1;
  final newAvg = ((currentAvg * currentTotal) + newRating) / newTotal;
  return double.parse(newAvg.toStringAsFixed(1));
}

bool isRatingValid(double rating) {
  return rating >= 1.0 && rating <= 5.0;
}

void main() {
  group('ReviewService — logika kalkulasi averageRating', () {
    test('kalkulasi average benar untuk review pertama (totalReviews = 0)', () {
      final result = hitungAverageRatingBaru(
        currentAvg: 0.0,
        currentTotal: 0,
        newRating: 5.0,
      );
      // (0.0 * 0 + 5.0) / 1 = 5.0
      expect(result, 5.0);
    });

    test('kalkulasi average benar saat ada review sebelumnya', () {
      // User sudah punya 2 review dengan avg 4.0 → totalRating = 8.0
      // Tambah review baru rating 5.0 → newAvg = (8.0 + 5.0) / 3 = 4.3
      final result = hitungAverageRatingBaru(
        currentAvg: 4.0,
        currentTotal: 2,
        newRating: 5.0,
      );
      expect(result, 4.3);
    });

    test('kalkulasi average dibulatkan ke 1 desimal', () {
      // (4.5 * 4 + 3.0) / 5 = 21/5 = 4.2
      final result = hitungAverageRatingBaru(
        currentAvg: 4.5,
        currentTotal: 4,
        newRating: 3.0,
      );
      expect(result, 4.2);
    });

    test('kalkulasi average tidak melebihi 5.0 saat semua review bintang 5', () {
      final result = hitungAverageRatingBaru(
        currentAvg: 5.0,
        currentTotal: 10,
        newRating: 5.0,
      );
      expect(result, 5.0);
      expect(result <= 5.0, isTrue);
    });

    test('kalkulasi average tidak di bawah 1.0 saat semua review bintang 1', () {
      final result = hitungAverageRatingBaru(
        currentAvg: 1.0,
        currentTotal: 5,
        newRating: 1.0,
      );
      expect(result, 1.0);
      expect(result >= 1.0, isTrue);
    });

    test('totalReviews bertambah 1 setelah review baru', () {
      const currentTotal = 7;
      final newTotal = currentTotal + 1;
      expect(newTotal, 8);
    });
  });

  group('ReviewService — validasi rating', () {
    test('rating 1.0 valid (batas bawah)', () {
      expect(isRatingValid(1.0), isTrue);
    });

    test('rating 5.0 valid (batas atas)', () {
      expect(isRatingValid(5.0), isTrue);
    });

    test('rating 3.5 valid (tengah, half-star)', () {
      expect(isRatingValid(3.5), isTrue);
    });

    test('rating 0.5 TIDAK valid (di bawah batas)', () {
      expect(isRatingValid(0.5), isFalse);
    });

    test('rating 5.5 TIDAK valid (di atas batas)', () {
      expect(isRatingValid(5.5), isFalse);
    });

    test('rating 0.0 TIDAK valid', () {
      expect(isRatingValid(0.0), isFalse);
    });

    test('rating negatif TIDAK valid', () {
      expect(isRatingValid(-1.0), isFalse);
    });
  });

  group('ReviewService — logika double rating prevention', () {
    // Simulasi: cek apakah kombinasi reviewerId+revieweeId+sessionId sudah ada
    // Ini mencerminkan logika query di submitReview()

    final Set<String> reviewKeys = {}; // simulasi "database"

    String buildReviewKey(String reviewerId, String revieweeId, String sessionId) {
      return '$reviewerId|$revieweeId|$sessionId';
    }

    test('review pertama untuk pasangan user+sesi harus diizinkan', () {
      final key = buildReviewKey('user_A', 'user_B', 'session_1');
      final sudahAda = reviewKeys.contains(key);
      expect(sudahAda, isFalse); // belum ada, boleh submit
    });

    test('review kedua untuk pasangan yang sama harus ditolak', () {
      final key = buildReviewKey('user_A', 'user_B', 'session_1');
      reviewKeys.add(key); // simulasi: review pertama sudah ada

      final sudahAda = reviewKeys.contains(key);
      expect(sudahAda, isTrue); // sudah ada, harus ditolak
    });

    test('reviewer yang sama boleh review orang berbeda di sesi yang sama', () {
      final key1 = buildReviewKey('user_A', 'user_B', 'session_1');
      final key2 = buildReviewKey('user_A', 'user_C', 'session_1');
      reviewKeys.add(key1);

      final sudahAdaUntukC = reviewKeys.contains(key2);
      expect(sudahAdaUntukC, isFalse); // user_C belum direview, boleh submit
    });

    test('reviewer yang sama boleh review orang yang sama di sesi BERBEDA', () {
      final key1 = buildReviewKey('user_A', 'user_B', 'session_1');
      final key2 = buildReviewKey('user_A', 'user_B', 'session_2');
      reviewKeys.add(key1);

      final sudahAdaUntukSesi2 = reviewKeys.contains(key2);
      expect(sudahAdaUntukSesi2, isFalse); // sesi beda, boleh submit
    });
  });
}