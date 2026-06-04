import 'package:flutter_test/flutter_test.dart';

// Meniru logika penentuan status sesi dari SessionService/SessionModel.
// Ref: SPEC Section 5.4 - Status Transitions
String tentukanStatusSesi({
  required int currentParticipants,
  required int maxParticipants,
  required String currentStatus,
}) {
  if (currentStatus == 'canceled' || currentStatus == 'completed' || currentStatus == 'ongoing') {
    return currentStatus;
  }
  
  if (currentParticipants >= maxParticipants) {
    return 'full';
  } else {
    return 'open';
  }
}

bool isParticipantLimitValid(int limit) {
  return limit >= 2 && limit <= 10;
}

void main() {
  group('SessionService — Logika Transisi Status Sesi', () {
    test('sesi terbuka (open) jika jumlah peserta kurang dari batas maksimal', () {
      final status = tentukanStatusSesi(
        currentParticipants: 2,
        maxParticipants: 4,
        currentStatus: 'open',
      );
      expect(status, 'open');
    });

    test('sesi berubah menjadi penuh (full) saat kuota terpenuhi', () {
      final status = tentukanStatusSesi(
        currentParticipants: 4,
        maxParticipants: 4,
        currentStatus: 'open',
      );
      expect(status, 'full');
    });

    test('sesi penuh berubah kembali menjadi terbuka (open) ketika peserta keluar', () {
      final status = tentukanStatusSesi(
        currentParticipants: 3,
        maxParticipants: 4,
        currentStatus: 'full',
      );
      expect(status, 'open');
    });

    test('sesi yang dibatalkan (canceled) statusnya tetap canceled meskipun kuota berubah', () {
      final status = tentukanStatusSesi(
        currentParticipants: 1,
        maxParticipants: 4,
        currentStatus: 'canceled',
      );
      expect(status, 'canceled');
    });

    test('sesi yang selesai (completed) statusnya tetap completed meskipun kuota berubah', () {
      final status = tentukanStatusSesi(
        currentParticipants: 2,
        maxParticipants: 4,
        currentStatus: 'completed',
      );
      expect(status, 'completed');
    });
  });

  group('SessionService — Validasi Kapasitas Peserta', () {
    test('kapasitas 2 valid (batas bawah)', () {
      expect(isParticipantLimitValid(2), isTrue);
    });

    test('kapasitas 10 valid (batas atas)', () {
      expect(isParticipantLimitValid(10), isTrue);
    });

    test('kapasitas 5 valid (tengah)', () {
      expect(isParticipantLimitValid(5), isTrue);
    });

    test('kapasitas 1 tidak valid (di bawah batas)', () {
      expect(isParticipantLimitValid(1), isFalse);
    });

    test('kapasitas 11 tidak valid (di atas batas)', () {
      expect(isParticipantLimitValid(11), isFalse);
    });

    test('kapasitas negatif tidak valid', () {
      expect(isParticipantLimitValid(-5), isFalse);
    });
  });
}
