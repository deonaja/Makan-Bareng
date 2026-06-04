import 'package:flutter_test/flutter_test.dart';

// Meniru logika privat di AuthService agar dapat diuji secara unit tanpa Firebase.
// Ref: SPEC Section 10.1 & 11.3
String terjemahkanAuthError(String code, {String? message}) {
  switch (code) {
    case 'email-already-in-use':
      return 'Email sudah terdaftar';
    case 'weak-password':
      return 'Password terlalu lemah (minimal 6 karakter)';
    case 'invalid-email':
      return 'Format email tidak valid';
    case 'user-not-found':
      return 'Akun tidak ditemukan';
    case 'wrong-password':
      return 'Password salah';
    case 'invalid-credential':
      return 'Email atau password salah';
    case 'user-disabled':
      return 'Akun ini telah dinonaktifkan';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Coba lagi nanti';
    default:
      return 'Terjadi kesalahan: ${message ?? 'unknown error'}';
  }
}

String dapatkanAvatarUrl(String name) {
  final encoded = Uri.encodeComponent(name);
  return 'https://ui-avatars.com/api/?name=$encoded&background=random&size=200';
}

void main() {
  group('AuthService — Terjemahan Error Firebase Auth', () {
    test('email-already-in-use menghasilkan pesan yang sesuai', () {
      expect(terjemahkanAuthError('email-already-in-use'), 'Email sudah terdaftar');
    });

    test('weak-password menghasilkan pesan yang sesuai', () {
      expect(terjemahkanAuthError('weak-password'), 'Password terlalu lemah (minimal 6 karakter)');
    });

    test('invalid-email menghasilkan pesan yang sesuai', () {
      expect(terjemahkanAuthError('invalid-email'), 'Format email tidak valid');
    });

    test('user-not-found menghasilkan pesan yang sesuai', () {
      expect(terjemahkanAuthError('user-not-found'), 'Akun tidak ditemukan');
    });

    test('wrong-password menghasilkan pesan yang sesuai', () {
      expect(terjemahkanAuthError('wrong-password'), 'Password salah');
    });

    test('invalid-credential menghasilkan pesan yang sesuai', () {
      expect(terjemahkanAuthError('invalid-credential'), 'Email atau password salah');
    });

    test('user-disabled menghasilkan pesan yang sesuai', () {
      expect(terjemahkanAuthError('user-disabled'), 'Akun ini telah dinonaktifkan');
    });

    test('too-many-requests menghasilkan pesan yang sesuai', () {
      expect(terjemahkanAuthError('too-many-requests'), 'Terlalu banyak percobaan. Coba lagi nanti');
    });

    test('error code tidak terdaftar mengembalikan pesan default', () {
      expect(
        terjemahkanAuthError('unknown-code', message: 'Something went wrong'),
        'Terjadi kesalahan: Something went wrong',
      );
    });
  });

  group('AuthService — Logika Generator Avatar', () {
    test('generate avatar URL dengan nama tunggal', () {
      final name = 'Budi';
      final url = dapatkanAvatarUrl(name);
      expect(url, contains('name=Budi'));
      expect(url, contains('background=random'));
      expect(url, contains('size=200'));
    });

    test('generate avatar URL dengan nama berspasi (URL encoding)', () {
      final name = 'Budi Raharjo';
      final url = dapatkanAvatarUrl(name);
      expect(url, contains('name=Budi%20Raharjo'));
    });

    test('generate avatar URL dengan karakter khusus', () {
      final name = 'Made & Deon';
      final url = dapatkanAvatarUrl(name);
      expect(url, contains('name=Made%20%26%20Deon'));
    });
  });
}
