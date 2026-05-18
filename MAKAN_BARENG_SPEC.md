# MakanBareng — Project Specification

> **Versi**: 1.4 — 18 Mei 2026
> **Status**: Final draft, siap dipakai tim
> **Maintainer**: Deon (Backend Lead)

## ⚠️ BACA INI DULU

Dokumen ini adalah **single source of truth** untuk project MakanBareng. Semua keputusan teknis (struktur data, naming, arsitektur) ada di sini. **Jika AI atau temanmu menyarankan sesuatu yang bertentangan dengan dokumen ini, ikuti dokumen ini.** Kalau ada hal yang tidak tercakup, tanya ke Deon dulu sebelum improvise.

Cara pakai dokumen ini untuk vibe-coding dengan AI ada di section paling akhir (lihat: Cara Pakai Dokumen Ini).

---

## 1. Project Overview

**MakanBareng** adalah aplikasi mobile (Android) untuk membantu mahasiswa mencari teman makan siang secara spontan. User bisa membuat sesi makan dengan lokasi & waktu tertentu, atau bergabung dengan sesi yang dibuat user lain. Setelah sesi selesai, peserta bisa saling memberikan rating.

Aplikasi ini adalah tugas besar mata kuliah **Aplikasi Perangkat Bergerak (CBK3GAB3)** di Telkom University, dikerjakan oleh 5 mahasiswa dalam waktu 2 minggu. **Bukan untuk production**, tapi tetap harus berfungsi end-to-end dengan backend asli (bukan mock data).

### Status saat ini
- **Frontend**: Sebagian besar UI sudah jadi dan jalan secara lokal pakai `MockData` + Provider
- **Backend**: 0% — belum ada Firebase sama sekali
- **Misi 2 minggu ke depan**: Ganti semua MockData dengan Firebase, tambah fitur backend (auth real, Firestore, notif, admin)

### Anggota tim & PIC

| Nama | NIM | Tanggung Jawab |
|------|-----|----------------|
| Made Naradeon HP | 103032300101 | Beranda, peta, search & filter |
| Revandi Akbar | 103032300120 | Rating, review, testing |
| Naemu Enggar M | 103032330009 | Sesi, chat, riwayat, notif |
| Muhammad Ihsan P | 103032330023 | Profil, admin dashboard, UI/UX |
| Saladin Setyo H | 103032330194 | Firebase setup, Auth, struktur Firestore |
| **Deon (kamu)** | — | **Backend Lead, dokumentasi spec ini, koordinasi data model** |

---

## 2. Tech Stack & Dependensi

### Frontend
- **Framework**: Flutter (versi stable terbaru, target SDK ≥ 3.0)
- **Bahasa**: Dart
- **State management**: **Provider** (sudah dipakai di prototype, jangan diganti)
- **Build target**: Android (untuk diner) + Web (untuk admin dashboard — 1 codebase)

### Backend (Firebase)
- **Firebase Auth** — registrasi & login (email/password + Google Sign-In)
- **Cloud Firestore** — database utama (NoSQL)
- **Firebase Hosting** — deploy web admin dashboard
- **Firebase Cloud Messaging (FCM)** — **OPSIONAL**, tergantung keputusan tim (lihat catatan di bawah)

### Foto Profil & Gambar (tanpa Firebase Storage)
- **Google Sign-In user**: otomatis pakai `photoURL` dari akun Google mereka
- **Email/Password user**: pakai avatar auto-generated dari URL `https://ui-avatars.com/api/?name=NAMA+USER&background=random` — gratis, tanpa upload
- **Foto cover sesi**: skip, pakai placeholder image atau tanpa foto
- **Foto restaurant (admin)**: simpan sebagai URL eksternal (misal link Google Maps photo), bukan upload file
- **Alasan**: Firebase Storage butuh Blaze plan (kartu kredit). Untuk tugas besar, placeholder + Google photo URL sudah cukup.

### Map & Lokasi
- **`flutter_map` + OpenStreetMap (CartoDB Dark theme)** — **JANGAN ganti ke Google Maps**
  - Alasan: gratis tanpa API key, sudah berjalan di prototype, dosen umumnya menerima alternatif open-source
  - Di laporan akhir: jelaskan ini sebagai "implementasi peta menggunakan OpenStreetMap melalui package `flutter_map` sebagai alternatif open-source dari Google Maps"

### Notifikasi (KEPUTUSAN BELUM FINAL)
**Sementara: pakai `flutter_local_notifications` + Firestore listener (Opsi A)**
- Notif muncul saat ada perubahan Firestore (misal: user join sesi) selama app aktif/background
- **Limitasi**: tidak akan muncul kalau app force-closed atau HP restart
- Gratis, tidak butuh Blaze plan
- **Bisa diupgrade ke FCM Cloud Functions** kalau tim setuju pakai Blaze plan nanti

### Plan Firebase
- **Spark plan (gratis)** — TIDAK perlu kartu kredit
- Quota harian lebih dari cukup untuk demo & testing
- Cek quota: https://firebase.google.com/pricing

### Bahasa
- **Code & komentar**: Bahasa Inggris
- **UI text (label, tombol, error message)**: Bahasa Indonesia
- **Dokumentasi (README, spec)**: Bahasa Indonesia

---

## 3. Fitur & Scope

### IN SCOPE (wajib dikerjakan)

**Untuk Diner (mobile)**:
- ✅ Registrasi & login (email/password + Google Sign-In) — **migrasi dari mock ke Firebase Auth**
- ✅ Edit profil (nama, foto, bio, preferensi makanan)
- ✅ Buat sesi makan (judul, lokasi, waktu mulai, jumlah kursi, deskripsi)
- ✅ Browse list sesi aktif (di Beranda, urut by waktu terdekat)
- ✅ Peta sesi (OpenStreetMap, marker per sesi)
- ✅ Search sesi (by nama/judul)
- ✅ Filter sesi (by jarak, by waktu)
- ✅ Detail sesi + tombol Join
- ✅ Chat per sesi (realtime via Firestore listener) — **migrasi dari mock**
- ✅ Riwayat sesi (sesi yang aku buat + sesi yang aku join)
- ✅ Rating & review setelah sesi selesai
- ✅ Notifikasi (sesuai keputusan: local notification)

**Untuk Admin (web, 1 codebase Flutter)**:
- ✅ Login admin (akun terpisah dengan flag `isAdmin: true` di Firestore)
- ✅ Lihat list users + suspend/delete
- ✅ Lihat list sesi + tutup paksa sesi
- ✅ Kelola data tempat makan (CRUD)
- ✅ Kelola laporan penyalahgunaan (opsional kalau waktu cukup)

### OUT OF SCOPE (JANGAN dikerjakan)

❌ Push notification berbasis FCM Cloud Functions (kecuali tim setuju upgrade ke Blaze)
❌ Biometric authentication (skip)
❌ Payment / split bill
❌ Email verification (cukup pakai default Firebase Auth)
❌ Forgot password flow custom (cukup pakai default Firebase Auth)
❌ Real-time location tracking
❌ Voice/video call
❌ In-app advertising
❌ Multi-bahasa (cuma Bahasa Indonesia)
❌ Dark/light mode toggle (cukup pakai theme yang sudah ada)

**Aturan**: Kalau AI menyarankan fitur yang ada di OUT OF SCOPE, **STOP**. Tanya Deon dulu.

---

## 4. File Structure

Struktur folder sudah ada dari prototype, hanya tambah `services/` dan hapus `src/` (kosong, tidak terpakai).

```
lib/
├── main.dart                  # entry point, init Firebase di sini
├── firebase_options.dart      # auto-generated by `flutterfire configure`
│
├── core/
│   └── theme/
│       ├── app_colors.dart
│       ├── app_text_styles.dart
│       └── app_theme.dart
│
├── models/                    # data class merepresentasikan Firestore documents
│   ├── user_model.dart
│   ├── session_model.dart
│   ├── chat_message_model.dart
│   ├── restaurant_model.dart
│   └── review_model.dart
│
├── services/                  # ⭐ FOLDER BARU — semua interaksi Firebase di sini
│   ├── auth_service.dart      # login, register, logout, get current user
│   ├── user_service.dart      # CRUD users collection
│   ├── session_service.dart   # CRUD sessions, join/leave sesi
│   ├── chat_service.dart      # send & stream messages
│   ├── restaurant_service.dart # CRUD restaurants (untuk admin)
│   ├── review_service.dart    # submit & ambil review
│   └── notification_service.dart # local notification handler
│
├── providers/                 # state management, sudah ada
│   ├── auth_provider.dart     # WRAP AuthService
│   ├── session_provider.dart  # WRAP SessionService
│   ├── chat_provider.dart     # WRAP ChatService
│   └── user_provider.dart     # WRAP UserService
│
├── screens/                   # full-page UI, sudah ada
│   ├── auth/
│   ├── home/
│   ├── session/
│   ├── chat/
│   ├── profile/
│   ├── rating/
│   └── admin/                 # ⭐ FOLDER BARU untuk admin screens
│
├── widgets/                   # reusable components
│
└── data/                      # ⚠️ DEPRECATED — mock_data.dart akan dihapus
    └── mock_data.dart         # hapus setelah Firestore terintegrasi
```

### Aturan struktur folder

1. **JANGAN buat folder baru di luar yang sudah ada** kecuali ada di list ini. Kalau butuh, tanya Deon.
2. **JANGAN panggil Firestore/Auth/Storage langsung dari `screens/` atau `widgets/`.** Selalu lewat `services/` atau `providers/`. Ini aturan emas.
3. **Provider WRAP Service.** Service = ngomong ke Firebase. Provider = state untuk UI + manggil Service. Widget = pakai Provider via `context.read()` atau `context.watch()`.
4. **Hapus `src/feat/`** — kosong dan tidak terpakai.
5. **Hapus `data/mock_data.dart`** setelah semua fitur sudah terhubung ke Firestore. Sementara dibiarkan dulu sebagai fallback waktu development.

### Alur data (penting!)

```
[Widget] → context.read<SessionProvider>().createSession(...)
              ↓
[Provider] → SessionService.createSession(...)
              ↓
[Service]  → FirebaseFirestore.instance.collection('sessions').add(...)
              ↓
          [Firestore Cloud]
```

Kalau ada AI yang mau bikin code yang panggil `FirebaseFirestore.instance` langsung di widget, **STOP**. Itu pelanggaran arsitektur.

---

## Keputusan kecil yang aku ambil tanpa tanya (highlight)

Beberapa keputusan kecil yang aku ambil sendiri di batch ini, untuk transparansi:

1. **`data/mock_data.dart` tetap ada sementara**, dihapus belakangan. Alasan: biar fitur tetap bisa di-test waktu Firebase belum 100% siap.
2. **Bahasa code = Inggris, bahasa UI = Indonesia.** Kalau tim mau code juga pakai Indonesia, bilang aja.
3. **Admin pakai Flutter Web (opsi C)** di codebase yang sama, dengan check `isAdmin` di Firestore. Route admin di-guard supaya cuma admin yang bisa akses.
4. **`notification_service.dart`** sengaja aku spesifikkan biar nggak nyangkut di service lain.
5. **Folder `screens/admin/`** baru ditambah. Sub-foldernya nanti aku detail di batch berikutnya.

Kalau ada yang nggak sreg, bilang sekarang sebelum aku lanjut ke Batch 2 (Data Model).

---

## 5. Data Model (Firestore Schema)

Ini section paling penting. **Semua struktur data harus mengikuti spec ini persis.** Kalau ada field yang dibutuhkan tapi tidak ada di sini, update dokumen ini dulu sebelum implementasi.

### 5.1 Prinsip dasar Firestore

Firestore adalah **NoSQL document database**. Strukturnya beda dengan SQL:

- **Collection** = wadah document sejenis (mirip "tabel" di SQL)
- **Document** = 1 data, isinya seperti JSON object, punya ID unik
- **Field** = key-value di dalam document
- **Subcollection** = collection di dalam document (nested)

**Tidak ada JOIN.** Kalau butuh data dari collection lain, ada 2 cara:
1. **Query terpisah** — ambil dulu ID-nya, terus query collection lain
2. **Denormalisasi** — copy data penting ke document yang butuh

Aturan denormalisasi di project ini:
- ✅ Copy: nama user, foto user URL — data kecil yang sering ditampilkan di list
- ❌ JANGAN copy: email, bio panjang, preferensi — data privat atau jarang ditampilkan
- **Trade-off**: kalau user ganti nama, data lama tidak otomatis update. Untuk tugas besar, ini dapat diterima.

### 5.2 List Collection

Total 6 collection utama + 1 subcollection:

| Collection | Document ID | Tujuan |
|------------|-------------|--------|
| `users` | Firebase Auth UID | Data user (diner + admin) |
| `sessions` | Auto-generated | Sesi makan yang dibuat user |
| `sessions/{id}/messages` | Auto-generated | Chat per sesi (subcollection) |
| `restaurants` | Auto-generated | Tempat makan, dikelola admin |
| `reviews` | Auto-generated | Rating & komentar antar peserta sesi |
| `reports` | Auto-generated | Laporan penyalahgunaan (opsional) |
| `notifications` | Auto-generated | Riwayat notif per user (opsional) |

---

### 5.3 Collection: `users`

**Path**: `users/{userId}`
**Document ID**: Sama persis dengan Firebase Auth UID (`FirebaseAuth.instance.currentUser!.uid`)

```
users/{userId}
├── uid: string                    // sama dengan document ID
├── name: string                   // "Deon Aja"
├── email: string                  // "deon@gmail.com"
├── photoUrl: string               // URL foto. Untuk Google user: dari Google account.
│                                  // Untuk email user: auto-generated "https://ui-avatars.com/api/?name=NAMA"
│                                  // JANGAN upload file, Firebase Storage tidak dipakai.
├── bio: string                    // "Suka makan pedes", default ""
├── foodPreferences: array<string> // ["nasi padang", "ramen", "bakso"], free text dari user, default []
├── isAdmin: boolean               // default false. Set manual di Console untuk admin
├── averageRating: number          // rata-rata rating yang diterima, default 0.0
├── totalReviews: number           // jumlah review yang diterima, default 0
├── sessionsCreated: number        // counter, default 0
├── sessionsJoined: number         // counter, default 0
├── createdAt: timestamp           // server timestamp saat register
├── updatedAt: timestamp           // server timestamp saat ada update
└── lastLoginAt: timestamp         // server timestamp saat login terakhir
```

**Catatan implementasi**:
- `uid` sengaja disimpan juga di field walau sama dengan document ID — biar gampang akses dari objek user tanpa harus baca `doc.id`
- `averageRating`, `totalReviews`, `sessionsCreated`, `sessionsJoined` adalah **denormalized counter** — di-update setiap ada review baru atau sesi baru. Tujuannya: tampil di profil tanpa harus query semua review/sesi.
- `isAdmin` adalah flag manual. **Untuk akun admin pertama, edit langsung di Firebase Console** (set `isAdmin: true`). User biasa selalu `false`.
- `foodPreferences` adalah array string **bebas (free text)** yang user input sendiri. Contoh: `["nasi padang", "ramen", "kopi"]`. Tidak ada constraint list pilihan.

**Contoh document**:
```json
{
  "uid": "abc123XYZ",
  "name": "Deon Aja",
  "email": "deon@telkomuniversity.ac.id",
  "photoUrl": "https://firebasestorage.googleapis.com/.../avatar.jpg",
  "bio": "Mahasiswa TI yang suka kuliner pedas",
  "foodPreferences": ["nasi padang", "mie ayam", "kopi"],
  "isAdmin": false,
  "averageRating": 4.7,
  "totalReviews": 12,
  "sessionsCreated": 5,
  "sessionsJoined": 8,
  "createdAt": "2026-05-18T10:00:00Z",
  "updatedAt": "2026-05-18T14:30:00Z",
  "lastLoginAt": "2026-05-18T14:30:00Z"
}
```

---

### 5.4 Collection: `sessions`

**Path**: `sessions/{sessionId}`
**Document ID**: Auto-generated oleh Firestore (jangan custom)

```
sessions/{sessionId}
├── sessionId: string              // sama dengan document ID
├── title: string                  // "Makan Siang di Warung Bu Tini"
├── description: string            // "Cari teman makan siang, yuk gabung!"
│
├── // === HOST INFO (DENORMALIZED dari users) ===
├── hostId: string                 // userId si pembuat sesi
├── hostName: string               // copy nama dari users — JANGAN query users lagi
├── hostPhotoUrl: string           // copy foto dari users
│
├── // === LOKASI (selalu custom, dipilih user dari peta) ===
├── location: map
│   ├── name: string               // "Warung Bu Tini" — diketik user
│   ├── address: string            // "Jl. Telekomunikasi No. 1, Bandung" — diketik atau dari reverse geocoding
│   ├── latitude: number           // -6.973003, dari hasil tap di peta
│   └── longitude: number          // 107.630440
│
├── // === WAKTU ===
├── scheduledAt: timestamp         // kapan sesi dimulai
├── durationMinutes: number        // estimasi durasi, default 60
│
├── // === PESERTA ===
├── maxParticipants: number        // 2-10, ditentukan host
├── currentParticipants: number    // counter, mulai dari 1 (host)
├── participantIds: array<string>  // [hostId, joinedUserId1, ...] max 10 item
│
├── // === STATUS ===
├── status: string                 // "open" | "full" | "ongoing" | "completed" | "canceled"
├── coverImageUrl: string          // URL placeholder atau kosong "". JANGAN upload file.
│
├── // === TIMESTAMP ===
├── createdAt: timestamp           // server timestamp saat sesi dibuat
├── updatedAt: timestamp           // server timestamp saat ada perubahan
└── completedAt: timestamp         // null sampai sesi selesai
```

**Status transitions**:
```
open → full           (waktu currentParticipants == maxParticipants)
open → canceled       (host batalin)
full → canceled       (host batalin)
open/full → ongoing   (waktu scheduledAt tiba)
ongoing → completed   (host tandai selesai, atau auto setelah durationMinutes)
```

**Catatan implementasi**:
- `participantIds` selalu mencakup `hostId` sebagai elemen pertama. Host = otomatis peserta.
- Untuk join sesi: pakai `FieldValue.arrayUnion([userId])` dan `FieldValue.increment(1)` — atomic, anti race condition.
- Untuk leave sesi: pakai `FieldValue.arrayRemove([userId])` dan `FieldValue.increment(-1)`.
- **Lokasi selalu custom** — user pilih lokasi dengan tap di peta (OpenStreetMap), isi nama tempat & alamat manual. Tidak ada link ke `restaurants` collection. Collection `restaurants` murni untuk data admin dashboard (lihat 5.6).
- **Query yang sering dipakai**:
  - "Sesi yang aku buat" → `where('hostId', '==', currentUserId)`
  - "Sesi yang aku ikut" → `where('participantIds', 'array-contains', currentUserId)`
  - "Sesi aktif (untuk Beranda)" → `where('status', 'in', ['open', 'full']).orderBy('scheduledAt')`

**Contoh document**:
```json
{
  "sessionId": "sess_xyz789",
  "title": "Makan Siang di Warung Bu Tini",
  "description": "Cari teman makan siang yuk!",
  "hostId": "abc123XYZ",
  "hostName": "Deon Aja",
  "hostPhotoUrl": "https://firebasestorage.googleapis.com/.../avatar.jpg",
  "location": {
    "name": "Warung Bu Tini",
    "address": "Jl. Telekomunikasi No. 1, Bandung",
    "latitude": -6.973003,
    "longitude": 107.630440
  },
  "scheduledAt": "2026-05-19T12:00:00Z",
  "durationMinutes": 60,
  "maxParticipants": 5,
  "currentParticipants": 2,
  "participantIds": ["abc123XYZ", "user_002"],
  "status": "open",
  "coverImageUrl": "",
  "createdAt": "2026-05-18T08:00:00Z",
  "updatedAt": "2026-05-18T09:15:00Z",
  "completedAt": null
}
```

---

### 5.5 Subcollection: `sessions/{sessionId}/messages`

**Path**: `sessions/{sessionId}/messages/{messageId}`
**Document ID**: Auto-generated

```
sessions/{sessionId}/messages/{messageId}
├── messageId: string              // sama dengan document ID
├── senderId: string               // userId pengirim
├── senderName: string             // DENORMALIZED dari users
├── senderPhotoUrl: string         // DENORMALIZED dari users
├── text: string                   // isi pesan
├── type: string                   // "text" | "system" — "system" untuk pesan otomatis
├── sentAt: timestamp              // server timestamp
└── readBy: array<string>          // [userId yang sudah baca], default [senderId]
```

**Catatan implementasi**:
- **Kenapa subcollection, bukan collection terpisah?** Karena messages selalu dibaca dalam konteks 1 sesi. Subcollection bikin query simpel: `sessions/{sessionId}/messages` udah otomatis filter by sesi.
- **`type: "system"`** untuk pesan otomatis kayak "Deon Aja bergabung ke sesi" atau "Sesi telah dimulai". Pesan system tidak punya `senderId` valid (pakai `"system"`).
- **`readBy` opsional** — kalau mau implementasi "indicator read by", pakai ini. Kalau tidak, hapus saja field-nya.
- **Query yang sering dipakai**:
  - "Stream chat per sesi" → `orderBy('sentAt', descending: false).limit(50)` + StreamBuilder

**Contoh document**:
```json
{
  "messageId": "msg_001",
  "senderId": "abc123XYZ",
  "senderName": "Deon Aja",
  "senderPhotoUrl": "https://firebasestorage.googleapis.com/.../avatar.jpg",
  "text": "Halo guys, jam 12 ya di Warung Bu Tini",
  "type": "text",
  "sentAt": "2026-05-18T11:30:00Z",
  "readBy": ["abc123XYZ", "user_002"]
}
```

---

### 5.6 Collection: `restaurants`

**Path**: `restaurants/{restaurantId}`
**Document ID**: Auto-generated
**Yang manage**: Admin (lewat web admin dashboard)
**Tujuan**: Data master tempat makan untuk keperluan admin (referensi, statistik, moderasi). **TIDAK terhubung langsung dengan sesi** — di sesi, lokasi selalu custom dari peta.

```
restaurants/{restaurantId}
├── restaurantId: string           // sama dengan document ID
├── name: string                   // "Warung Bu Tini"
├── description: string            // deskripsi singkat
├── address: string                // alamat lengkap
├── location: map                  // {latitude, longitude}
│   ├── latitude: number
│   └── longitude: number
├── categories: array<string>      // ["indonesian", "warung", "halal"]
├── priceRange: string             // "$" | "$$" | "$$$"
├── imageUrl: string               // URL foto restaurant di Storage
├── isVerified: boolean            // di-verify admin, default false
├── createdAt: timestamp
├── updatedAt: timestamp
└── createdBy: string              // adminId yang nambahin
```

**Catatan**:
- Restaurant **HANYA bisa di-CRUD oleh admin** (cek di Security Rules).
- User biasa hanya **READ-ONLY** — bisa lihat list tempat makan sebagai referensi (misal di halaman "Eksplor Tempat Makan").
- **Tidak terhubung dengan sesi**. User bikin sesi pilih lokasi bebas dari peta, bukan dari list ini.

---

### 5.7 Collection: `reviews`

**Path**: `reviews/{reviewId}`
**Document ID**: Auto-generated

```
reviews/{reviewId}
├── reviewId: string               // sama dengan document ID
├── sessionId: string               // referensi ke sesi
├── sessionTitle: string            // DENORMALIZED biar tampil tanpa query sessions
│
├── reviewerId: string              // yang ngasih review
├── reviewerName: string            // DENORMALIZED dari users
├── reviewerPhotoUrl: string        // DENORMALIZED dari users
│
├── revieweeId: string              // yang direview
├── revieweeName: string            // DENORMALIZED
│
├── rating: number                  // 1-5
├── comment: string                 // boleh kosong
├── createdAt: timestamp
```

**Catatan implementasi**:
- **1 user bisa kasih review ke banyak orang** di 1 sesi — buat tiap reviewee, 1 review document.
- **Composite index needed**: `where('revieweeId', '==', userId).orderBy('createdAt', 'desc')` untuk tampil di profil.
- **Saat review baru dibuat**, juga update `users/{revieweeId}.averageRating` dan `totalReviews`. Idealnya lewat transaction biar atomic.

---

### 5.8 Collection: `reports` (opsional, kerjain kalau waktu cukup)

**Path**: `reports/{reportId}`

```
reports/{reportId}
├── reportId: string
├── reportedBy: string              // userId pelapor
├── targetType: string              // "user" | "session" | "message"
├── targetId: string                // ID yang dilaporkan
├── reason: string                  // "spam" | "harassment" | "inappropriate" | "other"
├── description: string             // detail dari pelapor
├── status: string                  // "pending" | "reviewed" | "resolved" | "dismissed"
├── createdAt: timestamp
├── reviewedAt: timestamp           // null sampai admin review
└── reviewedBy: string              // adminId yang handle, "" awalnya
```

---

### 5.9 Collection: `notifications` (opsional)

**Path**: `notifications/{notificationId}`

```
notifications/{notificationId}
├── notificationId: string
├── userId: string                  // penerima notif
├── type: string                    // "session_joined" | "session_starting" | "new_message" | "new_review"
├── title: string                   // "Ada yang join sesimu!"
├── body: string                    // "Andi bergabung ke sesi 'Makan di Warung Bu Tini'"
├── relatedId: string               // sessionId / userId / messageId yang relevan
├── isRead: boolean                 // default false
├── createdAt: timestamp
```

**Catatan**: kalau pakai local notification, collection ini sebenarnya **opsional** — bisa skip kalau mau simpel. Tapi kalau mau ada "inbox notif" di app, simpan di sini.

---

### 5.10 Visualisasi struktur lengkap

```
Firestore (root)
│
├── users/                          # 1 doc per user
│   └── {userId}/
│       └── (fields user)
│
├── sessions/                       # 1 doc per sesi
│   └── {sessionId}/
│       ├── (fields sesi)
│       └── messages/               # subcollection chat
│           └── {messageId}/
│               └── (fields message)
│
├── restaurants/                    # dikelola admin
│   └── {restaurantId}/
│
├── reviews/                        # 1 doc per review per pair user
│   └── {reviewId}/
│
├── reports/                        # opsional
│   └── {reportId}/
│
└── notifications/                  # opsional
    └── {notificationId}/
```

---

### 5.11 Counter & data turunan — siapa update apa?

Beberapa field counter perlu di-update di banyak event. Ini cheat sheet:

| Event | Update di mana |
|-------|----------------|
| User register | `users/{uid}` created dengan default values |
| User login | `users/{uid}.lastLoginAt` updated |
| User buat sesi | `sessions/{id}` created + `users/{hostId}.sessionsCreated` increment |
| User join sesi | `sessions/{id}.participantIds` + `currentParticipants` + `users/{userId}.sessionsJoined` |
| User leave sesi | reverse dari join |
| Sesi penuh | `sessions/{id}.status` → "full" |
| Sesi selesai | `sessions/{id}.status` → "completed" + `completedAt` set |
| Review baru | `reviews/` doc created + `users/{revieweeId}.averageRating` + `totalReviews` updated |
| Pesan baru | `sessions/{id}/messages/{msgId}` created |

**Best practice**: Update yang melibatkan 2+ document harus pakai **Firestore Transaction** atau **WriteBatch** biar atomic. Contoh: review baru → harus update reviews collection DAN users counter dalam 1 transaction. Kalau salah satu gagal, dua-duanya rollback.

Untuk tugas besar, kalau capek, **boleh skip transaction** untuk join/leave (write biasa udah cukup). Tapi review WAJIB pakai transaction biar rating-nya akurat.

---

### 5.12 Composite Index yang perlu dibuat

Beberapa query butuh **composite index** di Firestore. Firestore akan kasih error + link langsung ke Console saat pertama kali query — kamu cukup klik linknya buat auto-create.

Yang akan dibutuhkan:

1. **`sessions`**: `status` (asc) + `scheduledAt` (asc) — untuk list sesi aktif urut waktu
2. **`sessions`**: `participantIds` (array-contains) + `scheduledAt` (desc) — untuk riwayat sesi user
3. **`reviews`**: `revieweeId` (asc) + `createdAt` (desc) — untuk list review di profil
4. **`reviews`**: `sessionId` (asc) + `createdAt` (desc) — untuk lihat review per sesi (opsional)

**Jangan paranoid** — biarin Firestore yang ngasih tau index mana yang perlu. Kamu klik link error, otomatis di-create.

---

## Keputusan kecil di Batch 2 (highlight)

Beberapa keputusan yang aku ambil sendiri:

1. **`uid` disimpan di field walau sama dengan document ID** — biar konsisten antar model class & gampang akses dari objek. Sedikit redundant tapi worth it.
2. **`isAdmin` flag di document user**, bukan custom claims Firebase Auth. Alasan: custom claims butuh Cloud Functions atau backend, kita pakai Spark plan jadi simpel aja pakai field.
3. **Counter di document user (`averageRating`, `sessionsCreated`, dll)** — denormalized counter. Pemula sering query semua review baru kalkulasi rata-rata, ini boros banget. Counter di document = 1 read selesai.
4. **`reviews` sebagai collection terpisah**, bukan subcollection `users/{id}/reviews`. Alasan: bisa query "semua review yang aku TULIS" dan "semua review yang aku TERIMA" dengan mudah. Kalau subcollection, salah satunya susah.
5. **Status sesi sebagai string enum** (`open`, `full`, dll), bukan boolean `isOpen`. Lebih extensible.
6. **`durationMinutes` default 60 menit** — biar transisi `ongoing → completed` bisa auto. Boleh diabaikan kalau host manual tandai selesai.
7. **`participantIds` max 10 item** — aman untuk simpan as array. Kalau lebih dari ini, baru pikirin subcollection.
8. **Pesan system pakai `senderId: "system"`** — workaround simpel, daripada bikin field `isSystem: bool` terpisah.
9. **`reports` dan `notifications` di-mark opsional** — kalau timeline ketat, skip dulu. Bisa di-add later tanpa break apa-apa.
10. **`restaurants` collection terpisah dari sesi** — sesi pakai lokasi custom dari peta, restaurants murni untuk admin dashboard.

Kalau ada yang nggak sreg, bilang sekarang sebelum Batch 3 (Naming Convention, Model Class Template, Service Layer Pattern).

---

## 6. Naming Convention

Konsistensi naming = code yang gampang dibaca + AI nggak bingung. Aturan ini **wajib diikuti**.

### 6.1 Field di Firestore (database)

Pakai **camelCase**. JANGAN snake_case.

✅ Benar:
```
hostName, scheduledAt, createdAt, photoUrl, foodPreferences, isAdmin
```

❌ Salah:
```
host_name, scheduled_at, created_at, photo_url, food_preferences, is_admin
```

### 6.2 Suffix & Prefix yang konsisten

| Tipe | Aturan | Contoh |
|------|--------|--------|
| ID field | suffix `Id` (kecil "d") | `hostId`, `sessionId`, `userId` |
| URL field | suffix `Url` (kecil "rl") | `photoUrl`, `coverImageUrl` |
| Timestamp field | suffix `At` | `createdAt`, `scheduledAt`, `lastLoginAt` |
| Boolean field | prefix `is` atau `has` | `isAdmin`, `isVerified`, `hasJoined` |
| Array of IDs | plural + `Ids` | `participantIds`, `readBy` (kalau array userId) |
| Counter | jelas namanya | `currentParticipants`, `totalReviews` |

❌ JANGAN: `hostID`, `host_id`, `Host`, `photo`, `created`, `date`, `admin`, `verified`

### 6.3 Dart code

| Element | Convention | Contoh |
|---------|-----------|--------|
| Class | `PascalCase` | `SessionModel`, `AuthService` |
| Variable & function | `camelCase` | `getUserById`, `currentUser` |
| File | `snake_case.dart` | `session_model.dart`, `auth_service.dart` |
| Constant | `lowerCamelCase` + `const` | `const maxParticipants = 10;` |
| Private member | prefix `_` | `_currentUser`, `_fetchData()` |

### 6.4 Konvensi project-spesifik

- **Model class** suffix `Model`: `UserModel`, `SessionModel`, `ChatMessageModel`
- **Service class** suffix `Service`: `AuthService`, `SessionService`
- **Provider class** suffix `Provider`: `AuthProvider`, `SessionProvider`
- **Screen class** suffix `Screen`: `HomeScreen`, `SessionDetailScreen`
- **Widget reusable** TIDAK pakai suffix khusus, langsung deskriptif: `SessionCard`, `RatingStars`

### 6.5 Konversi nama lama → nama spec

Kalau di prototype existing pakai nama beda, **ubah ke spec ini**. Contoh kalau di model lama ada `created_time`, ubah jadi `createdAt`.

---

## 7. Model Class Template

Setiap document Firestore harus punya **Model Class** di `lib/models/`. Model class punya 4 hal wajib:

1. Field-field sebagai `final` property
2. Constructor dengan `required` named parameters
3. `factory fromFirestore()` — konversi dari `DocumentSnapshot` ke Model
4. `toFirestore()` — konversi dari Model ke `Map<String, dynamic>` buat dikirim ke Firestore

Plus opsional:
- `copyWith()` — buat update sebagian field
- Override `toString()` — buat debugging

### 7.1 Template lengkap: `SessionModel`

Ini contoh **lengkap** yang harus jadi template untuk model class lain. Pattern ini wajib diikuti.

```dart
// lib/models/session_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String sessionId;
  final String title;
  final String description;
  
  // Host info (denormalized)
  final String hostId;
  final String hostName;
  final String hostPhotoUrl;
  
  // Location (selalu custom)
  final String locationName;
  final String locationAddress;
  final double locationLatitude;
  final double locationLongitude;
  
  // Waktu
  final DateTime scheduledAt;
  final int durationMinutes;
  
  // Peserta
  final int maxParticipants;
  final int currentParticipants;
  final List<String> participantIds;
  
  // Status & media
  final String status;
  final String coverImageUrl;
  
  // Timestamp
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  SessionModel({
    required this.sessionId,
    required this.title,
    required this.description,
    required this.hostId,
    required this.hostName,
    required this.hostPhotoUrl,
    required this.locationName,
    required this.locationAddress,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.scheduledAt,
    this.durationMinutes = 60,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.participantIds,
    this.status = 'open',
    this.coverImageUrl = '',
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  /// Konversi dari Firestore document ke SessionModel
  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final location = data['location'] as Map<String, dynamic>? ?? {};
    
    return SessionModel(
      sessionId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? '',
      hostPhotoUrl: data['hostPhotoUrl'] ?? '',
      locationName: location['name'] ?? '',
      locationAddress: location['address'] ?? '',
      locationLatitude: (location['latitude'] ?? 0.0).toDouble(),
      locationLongitude: (location['longitude'] ?? 0.0).toDouble(),
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 60,
      maxParticipants: data['maxParticipants'] ?? 2,
      currentParticipants: data['currentParticipants'] ?? 1,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      status: data['status'] ?? 'open',
      coverImageUrl: data['coverImageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Konversi ke Map untuk dikirim ke Firestore
  /// Catatan: createdAt/updatedAt pakai FieldValue.serverTimestamp() di service,
  /// JANGAN di sini.
  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'title': title,
      'description': description,
      'hostId': hostId,
      'hostName': hostName,
      'hostPhotoUrl': hostPhotoUrl,
      'location': {
        'name': locationName,
        'address': locationAddress,
        'latitude': locationLatitude,
        'longitude': locationLongitude,
      },
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'durationMinutes': durationMinutes,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'participantIds': participantIds,
      'status': status,
      'coverImageUrl': coverImageUrl,
      // createdAt, updatedAt, completedAt di-handle di service
    };
  }

  /// Buat copy dengan beberapa field di-override
  SessionModel copyWith({
    String? title,
    String? description,
    int? currentParticipants,
    List<String>? participantIds,
    String? status,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return SessionModel(
      sessionId: sessionId,
      title: title ?? this.title,
      description: description ?? this.description,
      hostId: hostId,
      hostName: hostName,
      hostPhotoUrl: hostPhotoUrl,
      locationName: locationName,
      locationAddress: locationAddress,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      participantIds: participantIds ?? this.participantIds,
      status: status ?? this.status,
      coverImageUrl: coverImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
```

### 7.2 Aturan model class

1. **Semua field `final`** — model immutable. Update lewat `copyWith()`, bukan ubah field langsung.
2. **`fromFirestore()` selalu defensive** — pakai `??` untuk default value, jangan langsung asumsi field ada.
3. **`toFirestore()` JANGAN include `createdAt`/`updatedAt`** — biar service yang set pakai `FieldValue.serverTimestamp()`.
4. **Timestamp dikonversi ke `DateTime` di model**, tapi waktu kirim balik ke Firestore pakai `Timestamp.fromDate()`. Internal Dart pakai DateTime, di Firestore pakai Timestamp.
5. **Nested object (kayak `location`) di-flatten di model** — `locationName`, `locationLatitude`, dst. Lebih gampang dipakai di UI. Konversi nested map terjadi di `fromFirestore` & `toFirestore`.
6. **Jangan tambah method bisnis di model** — model cuma data container. Logic ada di service.

### 7.3 Model class lain (yang harus dibikin/diperbarui)

Setelah `SessionModel` jadi template, model lain ngikutin pattern yang sama:

- `UserModel` — sudah ada, perlu **rewrite** sesuai schema baru
- `ChatMessageModel` — sudah ada, perlu **rewrite**
- `RestaurantModel` — sudah ada, perlu **rewrite**
- `ReviewModel` — sudah ada, perlu **rewrite**

Mapping field model lama ke model baru = task pertama temen-temen yang handle masing-masing modul. **Kalau di model lama ada field yang nggak ada di spec, hapus.** Kalau ada di spec tapi belum ada di model lama, tambahin.

---

## 8. Service Layer Pattern

`services/` adalah satu-satunya tempat di mana code berkomunikasi dengan Firebase. **Jangan ada `FirebaseFirestore.instance.collection(...)` di luar folder ini.**

### 8.1 Aturan service class

1. **Semua method `async`** dan return `Future` atau `Stream`
2. **Semua method ada try-catch** — error di-throw ulang sebagai exception yang readable
3. **JANGAN return raw `DocumentSnapshot`** — selalu konversi ke Model class dulu
4. **Pakai `FieldValue.serverTimestamp()`** untuk semua timestamp create/update
5. **Service class adalah singleton** — akses lewat instance, bukan `new` setiap kali

### 8.2 Template lengkap: `SessionService`

```dart
// lib/services/session_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';

class SessionService {
  // Singleton instance
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _sessions => _firestore.collection('sessions');

  /// Bikin sesi baru. Return sessionId yang baru dibuat.
  Future<String> createSession({
    required String title,
    required String description,
    required String hostId,
    required String hostName,
    required String hostPhotoUrl,
    required String locationName,
    required String locationAddress,
    required double locationLatitude,
    required double locationLongitude,
    required DateTime scheduledAt,
    required int maxParticipants,
    int durationMinutes = 60,
    String coverImageUrl = '',
  }) async {
    try {
      final docRef = await _sessions.add({
        'title': title,
        'description': description,
        'hostId': hostId,
        'hostName': hostName,
        'hostPhotoUrl': hostPhotoUrl,
        'location': {
          'name': locationName,
          'address': locationAddress,
          'latitude': locationLatitude,
          'longitude': locationLongitude,
        },
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'durationMinutes': durationMinutes,
        'maxParticipants': maxParticipants,
        'currentParticipants': 1,
        'participantIds': [hostId],
        'status': 'open',
        'coverImageUrl': coverImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'completedAt': null,
      });
      
      // Update sessionId field jadi sama dengan document ID
      await docRef.update({'sessionId': docRef.id});
      
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal membuat sesi: $e');
    }
  }

  /// Ambil 1 sesi by ID
  Future<SessionModel?> getSessionById(String sessionId) async {
    try {
      final doc = await _sessions.doc(sessionId).get();
      if (!doc.exists) return null;
      return SessionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Gagal mengambil sesi: $e');
    }
  }

  /// Stream sesi aktif untuk Beranda, urut by scheduledAt
  Stream<List<SessionModel>> streamActiveSessions() {
    return _sessions
        .where('status', whereIn: ['open', 'full'])
        .orderBy('scheduledAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  /// Stream sesi yang user ikuti (host atau participant)
  Stream<List<SessionModel>> streamUserSessions(String userId) {
    return _sessions
        .where('participantIds', arrayContains: userId)
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromFirestore(doc))
            .toList());
  }

  /// User join sesi. Akan update participantIds + currentParticipants.
  /// Auto-update status ke 'full' kalau penuh.
  Future<void> joinSession({
    required String sessionId,
    required String userId,
  }) async {
    try {
      final sessionRef = _sessions.doc(sessionId);
      
      // Pakai transaction biar atomic
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(sessionRef);
        if (!snapshot.exists) {
          throw Exception('Sesi tidak ditemukan');
        }
        
        final data = snapshot.data() as Map<String, dynamic>;
        final List<String> participants = List<String>.from(data['participantIds']);
        final int current = data['currentParticipants'];
        final int max = data['maxParticipants'];
        
        if (participants.contains(userId)) {
          throw Exception('Kamu sudah bergabung di sesi ini');
        }
        if (current >= max) {
          throw Exception('Sesi sudah penuh');
        }
        
        final newCurrent = current + 1;
        transaction.update(sessionRef, {
          'participantIds': FieldValue.arrayUnion([userId]),
          'currentParticipants': newCurrent,
          'status': newCurrent >= max ? 'full' : 'open',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Gagal join sesi: $e');
    }
  }

  /// User leave sesi
  Future<void> leaveSession({
    required String sessionId,
    required String userId,
  }) async {
    try {
      await _sessions.doc(sessionId).update({
        'participantIds': FieldValue.arrayRemove([userId]),
        'currentParticipants': FieldValue.increment(-1),
        'status': 'open', // Selalu balik ke open setelah ada yang leave
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal leave sesi: $e');
    }
  }

  /// Cancel sesi (cuma host yang boleh)
  Future<void> cancelSession(String sessionId) async {
    try {
      await _sessions.doc(sessionId).update({
        'status': 'canceled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal cancel sesi: $e');
    }
  }

  /// Tandai sesi sebagai selesai
  Future<void> completeSession(String sessionId) async {
    try {
      await _sessions.doc(sessionId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal complete sesi: $e');
    }
  }
}
```

### 8.3 Pola yang harus diikuti semua service

1. **Singleton pattern** — `static final _instance` di atas, factory constructor.
2. **Private FirebaseFirestore reference** — pakai `_firestore`, jangan akses `FirebaseFirestore.instance` di setiap method.
3. **Getter untuk collection reference** — `CollectionReference get _sessions => _firestore.collection('sessions');`
4. **Method naming**: `createX`, `getXById`, `streamX`, `updateX`, `deleteX`. Konsisten.
5. **Stream vs Future**:
   - Pakai **Stream** untuk data realtime (list sesi aktif, chat messages) — UI auto-update kalau data berubah
   - Pakai **Future** untuk one-time fetch (get sesi by ID, submit review)
6. **Error handling**: try-catch + `throw Exception('Pesan error dalam Bahasa Indonesia: $e')`. Pesan-nya dalam Bahasa Indonesia karena bakal di-show ke user.
7. **Atomic operations**: pakai `transaction` atau `WriteBatch` kalau update 2+ document yang harus konsisten.

### 8.4 Daftar service yang harus dibikin

| File | Method utama |
|------|--------------|
| `auth_service.dart` | `register`, `login`, `loginWithGoogle`, `logout`, `getCurrentUser`, `authStateChanges` |
| `user_service.dart` | `createUserProfile`, `getUserById`, `updateProfile`, `streamUser` |
| `session_service.dart` | (lihat 8.2) |
| `chat_service.dart` | `sendMessage`, `streamMessages`, `markAsRead` |
| `review_service.dart` | `submitReview`, `streamReviewsForUser`, `streamReviewsForSession` |
| `restaurant_service.dart` | `createRestaurant`, `streamRestaurants`, `updateRestaurant`, `deleteRestaurant` (untuk admin) |
| `notification_service.dart` | `init`, `showLocalNotification`, `subscribeToSessionUpdates` |

### 8.5 Provider vs Service: kapan pakai yang mana

Tidak semua service perlu di-wrap provider. Aturan:

**Pakai Provider** kalau:
- State perlu di-share antar widget/screen (misal: current user, current session yang dilihat)
- UI perlu auto-rebuild saat data berubah (login status, list sesi di home)
- Ada loading/error state yang perlu di-track

**Pakai Service langsung dari widget** kalau:
- One-shot operation tanpa state global (submit review, upload foto, cancel sesi)
- Hasil cuma dipakai sementara di 1 screen (misal: dapatin URL setelah upload terus simpen di state lokal)

| Service | Wrap Provider? | Alasan |
|---------|---------------|--------|
| `auth_service` | ✅ `AuthProvider` | Auth state perlu di seluruh app |
| `user_service` | ✅ `UserProvider` | Profil user dipakai di banyak screen |
| `session_service` | ✅ `SessionProvider` | List sesi, current session, dll |
| `chat_service` | ✅ `ChatProvider` | Stream messages dipakai di chat screen |
| `review_service` | ❌ langsung dari widget | One-shot submit, baca review one-time |
| `restaurant_service` | ❌ langsung dari widget | Admin one-shot CRUD |
| `notification_service` | ❌ langsung di `main.dart` | Setup global, bukan state |

**Contoh pakai service langsung dari widget**:
```dart
// Di RatingScreen
ElevatedButton(
  onPressed: () async {
    try {
      await ReviewService().submitReview(
        sessionId: widget.sessionId,
        reviewerId: currentUserId,
        revieweeId: revieweeId,
        rating: _rating,
        comment: _commentController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review berhasil dikirim')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  },
  child: const Text('Kirim Review'),
)
```

Aturan tetap: **service tetap satu-satunya yang ngomong ke Firebase**, baik dipakai via Provider atau langsung dari widget.

---

## Keputusan kecil di Batch 3 (highlight)

1. **Model class `final` semua** — immutability. Update lewat `copyWith()`. Standar Flutter best practice.
2. **`fromFirestore()` defensive dengan `??` default** — biar nggak crash kalau ada field hilang di document lama.
3. **`location` di-flatten jadi `locationName`, `locationLatitude`, dst di model** — bukan nested object. Lebih gampang dipakai di UI. Konversi nested ↔ flat terjadi di `fromFirestore`/`toFirestore`.
4. **Service singleton pattern** — biar nggak buat instance baru tiap kali, hemat memory.
5. **Pesan error Bahasa Indonesia di throw Exception** — karena nanti di-show ke user via SnackBar.
6. **`joinSession` pakai transaction**, `leaveSession` pakai simple update. Alasan: join lebih kritis (race condition kalau 2 orang join slot terakhir bareng-bareng), leave nggak ada race condition penting.
7. **Method `streamActiveSessions()` filter status `[open, full]`** — sesi yang `canceled`/`completed`/`ongoing` nggak ditampilin di Beranda.

Kalau ada yang nggak sreg, bilang sekarang sebelum Batch 4 (Security Rules + Auth Flow + Common Patterns).

---

## 9. Security Rules (Firestore)

Security Rules adalah **lapisan keamanan utama** karena frontend kamu langsung ngomong ke database tanpa server di tengah. Kalau rules salah, database kamu bisa dibaca/diubah siapa aja.

### 9.1 Aturan dasar yang dipakai

Untuk MakanBareng, prinsip rules-nya:

1. **User harus login** untuk akses apa-apa
2. **User cuma boleh edit data dirinya sendiri** (kecuali admin)
3. **Admin punya akses penuh** ke semua collection
4. **Read user lain DILARANG** (data user privat, untuk display di UI pakai data denormalized di sesi/chat/review). **Read sesi/restoran/review PERMISIF** (data publik, semua login boleh baca).
5. **Write strict** — cuma yang berhak (owner, admin, atau yang ada di scope-nya)

### 9.2 Full Security Rules

Copy paste ini ke **Firebase Console → Firestore → Rules** persis. Klik **Publish** setelah paste.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ============================================
    // HELPER FUNCTIONS
    // ============================================
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // ============================================
    // USERS COLLECTION
    // ============================================
    // - User cuma boleh baca profil sendiri (full data termasuk email)
    // - Untuk lihat profil user lain (nama + foto), pakai data DENORMALIZED 
    //   yang sudah di-copy ke sessions/messages/reviews (lihat data model)
    // - Admin bisa baca semua
    // - User cuma boleh edit profil sendiri
    // - Admin boleh edit/delete siapa aja
    
    match /users/{userId} {
      allow read: if isOwner(userId) || isAdmin();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isAdmin();
    }
    
    // ============================================
    // SESSIONS COLLECTION
    // ============================================
    // - Semua user login bisa baca sesi (buat ditampilkan di home/map)
    // - Semua user login boleh bikin sesi
    // - Host yang boleh update/delete sesinya
    // - Tapi participant juga boleh update participantIds (buat join/leave)
    // - Admin selalu boleh
    
    match /sessions/{sessionId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() 
                    && request.resource.data.hostId == request.auth.uid;
      allow update: if isAuthenticated() && (
                      resource.data.hostId == request.auth.uid ||
                      isAdmin() ||
                      // Allow join/leave: cuma boleh ubah participantIds dan related fields
                      (request.resource.data.diff(resource.data).affectedKeys()
                        .hasOnly(['participantIds', 'currentParticipants', 'status', 'updatedAt']))
                    );
      allow delete: if isAuthenticated() && (
                      resource.data.hostId == request.auth.uid || isAdmin()
                    );
      
      // SUBCOLLECTION: messages
      // - Semua user login bisa baca pesan (asumsi: cuma peserta yg lihat chat dari UI)
      // - Sender boleh kirim, tapi senderId harus match auth
      // - Update cuma untuk markAsRead (ubah readBy)
      match /messages/{messageId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated() 
                      && request.resource.data.senderId == request.auth.uid;
        allow update: if isAuthenticated();
        allow delete: if isAdmin();
      }
    }
    
    // ============================================
    // RESTAURANTS COLLECTION
    // ============================================
    // - Semua user login bisa baca (buat eksplor tempat makan)
    // - Cuma admin yang boleh CRUD
    
    match /restaurants/{restaurantId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
    
    // ============================================
    // REVIEWS COLLECTION
    // ============================================
    // - Semua user login bisa baca
    // - User boleh bikin review tapi reviewerId harus match auth
    // - User cuma boleh review peserta sesi yang sama (dicek di service, bukan rules)
    // - Tidak boleh edit/delete (sekali submit, permanen)
    // - Admin boleh delete (moderasi)
    
    match /reviews/{reviewId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() 
                    && request.resource.data.reviewerId == request.auth.uid
                    && request.resource.data.rating >= 1 
                    && request.resource.data.rating <= 5;
      allow update: if false; // sengaja, review immutable
      allow delete: if isAdmin();
    }
    
    // ============================================
    // REPORTS COLLECTION (opsional)
    // ============================================
    // - User boleh bikin laporan (reportedBy harus match)
    // - User cuma boleh baca laporan yang dia buat
    // - Admin boleh baca semua + update status
    
    match /reports/{reportId} {
      allow read: if isAuthenticated() && (
                    resource.data.reportedBy == request.auth.uid || isAdmin()
                  );
      allow create: if isAuthenticated() 
                    && request.resource.data.reportedBy == request.auth.uid;
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
    
    // ============================================
    // NOTIFICATIONS COLLECTION (opsional)
    // ============================================
    // - User cuma boleh baca notif untuk dirinya
    // - Notif dibuat oleh sistem (sebenarnya butuh Cloud Function, tapi sementara
    //   diperbolehkan dari client untuk simplicity)
    
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() 
                  && resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() 
                    && resource.data.userId == request.auth.uid;
      allow delete: if isAuthenticated() 
                    && resource.data.userId == request.auth.uid;
    }
    
  }
}
```

### 9.3 Catatan: Firebase Storage TIDAK dipakai

Firebase Storage butuh Blaze plan (kartu kredit). Project ini **tidak menggunakan Storage**. Foto profil pakai auto-generated avatar URL (lihat Section 11.3). Jadi **tidak ada Storage Rules yang perlu di-publish**.

### 9.4 Testing Security Rules

Setelah publish rules, **test dulu** sebelum mulai coding. Firebase Console punya **Rules Playground**:

1. Buka **Firestore → Rules → Rules Playground**
2. Pilih operation (`get`, `create`, `update`, `delete`)
3. Pilih path (misal: `/users/abc123`)
4. Authenticated as: pilih user ID
5. Klik **Run**

Test minimum:
- ✅ User login bisa baca profil sendiri `/users/{ownId}`
- ❌ User login TIDAK BISA baca `/users/{otherUserId}` (kecuali admin) — ini sengaja strict
- ✅ User login bisa update `/users/{ownId}`
- ❌ User login TIDAK BISA update `/users/{otherUserId}` (kecuali admin)
- ✅ User login bisa create `/sessions/{new}` kalau hostId = uid
- ✅ User login bisa baca `/sessions/{any}` (data publik)
- ❌ User TIDAK BISA delete sesi orang lain

### 9.5 Catatan penting Security Rules

1. **Rules `allow read: if true`** atau **`allow write: if true`** = database TERBUKA UNTUK SIAPA AJA. **JANGAN PERNAH** pakai ini, walau buat development.
2. **Rules nggak validate isi data** sepenuhnya — itu tugas service layer + form validation. Rules cuma jagain "siapa boleh apa". Misal validation `rating 1-5` di rules buat extra safety, tapi UI tetap harus validate juga.
3. **`request.resource.data`** = data yang lagi mau ditulis. **`resource.data`** = data yang udah ada di Firestore (sebelum ditulis).
4. **Function `isAdmin()` butuh extra read** ke document user. Pelan dikit, tapi worth it karena admin actions jarang.
5. **Kalau dapat error `permission-denied`** di app, cek rules ini dulu sebelum nyalahin code. 90% error permission-denied karena rules belum cocok dengan apa yang code coba kerjain.

---

## 10. Authentication Flow

Auth adalah pondasi semua fitur. Salah implementasi di sini = ribet di mana-mana.

### 10.1 Alur Registrasi

```
1. User isi form: email, password, name
2. Frontend validasi: email format, password ≥ 6 char, name tidak kosong
3. Panggil AuthService.register(email, password, name)
4. AuthService:
   a. Buat akun di Firebase Auth
   b. Update displayName di Firebase Auth (opsional)
   c. PENTING: Buat document di Firestore: users/{newUid}
      dengan default values (lihat 5.3)
5. Setelah sukses: redirect ke Home (atau Onboarding kalau ada)
```

**Code pattern di `auth_service.dart`**:

```dart
Future<UserCredential> register({
  required String email,
  required String password,
  required String name,
}) async {
  try {
    // Step 1: Buat akun di Firebase Auth
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    
    // Step 2: Update display name
    await credential.user!.updateDisplayName(name);
    
    // Step 3: Buat profil di Firestore (PENTING, sering dilupakan)
    await UserService().createUserProfile(
      uid: credential.user!.uid,
      name: name,
      email: email,
    );
    
    return credential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      throw Exception('Email sudah terdaftar');
    } else if (e.code == 'weak-password') {
      throw Exception('Password terlalu lemah (minimal 6 karakter)');
    } else if (e.code == 'invalid-email') {
      throw Exception('Format email tidak valid');
    }
    throw Exception('Gagal mendaftar: ${e.message}');
  }
}
```

### 10.2 Alur Login

```
1. User isi email + password (atau klik Login with Google)
2. Frontend validasi format
3. Panggil AuthService.login() atau AuthService.loginWithGoogle()
4. Kalau sukses: 
   a. Update users/{uid}.lastLoginAt
   b. Untuk Google login pertama kali: bikin profil Firestore juga
   c. Redirect ke Home
5. Kalau gagal: tampilkan error
```

**Auth state listener di `main.dart`**:

```dart
// main.dart
MaterialApp(
  home: StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasData) {
        return const HomeScreen();
      }
      return const LoginScreen();
    },
  ),
);
```

Pattern ini bikin app **auto-redirect** saat login/logout, tanpa perlu manual Navigator.

### 10.3 Alur Logout

```
1. Panggil AuthService.logout() → FirebaseAuth.instance.signOut()
2. authStateChanges() trigger otomatis
3. StreamBuilder di main.dart re-render → LoginScreen
```

### 10.4 Hal yang sering dilupakan

❗ **Setelah register, WAJIB bikin document `users/{uid}` di Firestore.** Banyak yang lupa step ini, ujungnya: user bisa login tapi profilnya kosong, semua query ke users/{uid} gagal.

❗ **Untuk Google Sign-In pertama kali**, juga harus cek apakah `users/{uid}` udah ada. Kalau belum, bikin dulu pakai data dari Google account (`displayName`, `email`, `photoURL`).

❗ **`FirebaseAuth.instance.currentUser`** bisa **null** walaupun di screen yang seharusnya udah login. Selalu cek dulu sebelum akses property-nya.

---

## 11. Common Patterns / Code Snippets

Pola yang sering dipakai. AI akan niru pola ini, jadi pastikan benar.

### 11.1 List data realtime dengan StreamBuilder

Pakai ini untuk list sesi, chat messages, atau apapun yang harus auto-update.

```dart
StreamBuilder<List<SessionModel>>(
  stream: SessionService().streamActiveSessions(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    final sessions = snapshot.data ?? [];
    if (sessions.isEmpty) {
      return const Center(child: Text('Belum ada sesi aktif'));
    }
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) => SessionCard(session: sessions[index]),
    );
  },
)
```

### 11.2 One-time fetch dengan FutureBuilder

Pakai ini untuk data yang nggak perlu realtime (detail sesi, profil user).

```dart
FutureBuilder<SessionModel?>(
  future: SessionService().getSessionById(sessionId),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || snapshot.data == null) {
      return const Center(child: Text('Sesi tidak ditemukan'));
    }
    return SessionDetailWidget(session: snapshot.data!);
  },
)
```

### 11.3 Foto profil tanpa Firebase Storage

Karena Firebase Storage butuh Blaze plan, kita pakai alternatif gratis:

```dart
// Helper function untuk generate avatar URL
String getAvatarUrl(String name) {
  final encoded = Uri.encodeComponent(name);
  return 'https://ui-avatars.com/api/?name=$encoded&background=random&size=200';
}

// Saat register email/password — set photoUrl otomatis
await UserService().createUserProfile(
  uid: credential.user!.uid,
  name: name,
  email: email,
  photoUrl: getAvatarUrl(name),  // auto-generated avatar
);

// Saat Google Sign-In — pakai foto dari Google account
final googleUser = await GoogleSignIn().signIn();
final photoUrl = googleUser?.photoUrl ?? getAvatarUrl(googleUser?.displayName ?? 'User');
```

**Aturan**: field `photoUrl` di Firestore SELALU berisi URL valid (bukan kosong). Kalau user belum punya foto, isi dengan auto-generated avatar URL.

### 11.4 Show error/success dengan SnackBar

```dart
// Helper umum
void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    ),
  );
}

// Pemakaian dalam try-catch
try {
  await SessionService().joinSession(sessionId: id, userId: uid);
  if (context.mounted) {
    showSnackBar(context, 'Berhasil bergabung ke sesi!');
  }
} catch (e) {
  if (context.mounted) {
    showSnackBar(context, e.toString(), isError: true);
  }
}
```

### 11.5 Navigate antar screen

```dart
// Push (buka screen baru, bisa back)
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: id)),
);

// Replace (ganti screen, nggak bisa back)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const HomeScreen()),
);

// Pop sampai root
Navigator.popUntil(context, (route) => route.isFirst);

// Pop dengan return value
Navigator.pop(context, true);
```

### 11.6 Pakai Provider di widget

```dart
// Read (one-time, nggak rebuild)
final auth = context.read<AuthProvider>();
auth.logout();

// Watch (rebuild kalau berubah)
final user = context.watch<UserProvider>().currentUser;
return Text(user?.name ?? 'Loading...');

// Selector (rebuild cuma kalau field tertentu berubah, lebih efisien)
Selector<UserProvider, String>(
  selector: (_, provider) => provider.currentUser?.name ?? '',
  builder: (_, name, __) => Text(name),
)
```

### 11.7 Local Notification dasar (untuk Opsi A)

Pakai package `flutter_local_notifications`. Setup di `main.dart`, panggil saat ada perubahan Firestore.

```dart
// Di notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final _plugin = FlutterLocalNotificationsPlugin();
  
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }
  
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'makanbareng_channel',
      'MakanBareng Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
```

Pakai dengan Firestore listener (streaming document):

```dart
// Tambah method ini di SessionService dulu:
Stream<SessionModel?> streamSessionById(String sessionId) {
  return _sessions.doc(sessionId).snapshots().map((doc) {
    if (!doc.exists) return null;
    return SessionModel.fromFirestore(doc);
  });
}

// Lalu di Provider/widget yang relevan:
int previousCount = 0;
SessionService().streamSessionById(mySessionId).listen((session) {
  if (session != null && session.currentParticipants > previousCount) {
    NotificationService().showNotification(
      title: 'Ada yang bergabung!',
      body: 'Seseorang baru saja bergabung ke sesi "${session.title}"',
    );
  }
  if (session != null) {
    previousCount = session.currentParticipants;
  }
});
```

**Penting**: `.asStream()` pada `Future` cuma emit 1 kali. Untuk realtime updates, harus pakai `.snapshots()` dari Firestore document — itulah yang bikin listener jalan terus saat ada perubahan.

**Catatan**: ini cara sederhana. Bisa di-upgrade ke FCM nanti kalau tim setuju Blaze plan.

---

## Keputusan kecil di Batch 4 (highlight)

1. **Rules `users` strict** — cuma owner atau admin yang boleh baca document user. Untuk nampilin nama/foto user lain di UI, **selalu pakai data denormalized** yang sudah di-copy ke sessions/messages/reviews. Ini konsekuensi nyata dari denormalisasi yang kita pilih di Section 5: makanya `hostName`, `senderName`, `reviewerName`, dll di-copy ke document lain. **Pelajaran**: jangan ada code yang query `users/{otherUserId}` dari widget biasa — akan dapet permission-denied. Kalau perlu fetch data user lain (misal di halaman profil orang), itu boleh karena user akses profil sendiri saja. Untuk profil orang lain, tampilkan dari data denormalized.
2. **Rules `sessions` update kompleks**: host boleh update apa aja, participant boleh update **cuma** `participantIds` + `currentParticipants` + `status` + `updatedAt`. Pakai `affectedKeys().hasOnly()` — pattern Firestore standar untuk partial update permission.
3. **Reviews immutable** — `allow update: if false`. Sekali submit, nggak bisa diedit. Bikin sistem rating lebih dipercaya.
4. **Rating validation di Rules** (`rating >= 1 && rating <= 5`) — extra safety layer di luar form validation.
5. **`isAdmin()` function** baca document users. Sedikit boros read, tapi cuma trigger pas admin action. Worth.
6. **Auth flow pakai `StreamBuilder<User?>` di main.dart** — pattern standar Flutter+Firebase. Auto-redirect saat login/logout.
7. **Profile creation di Firestore SETELAH register Auth** — wajib, sering dilupakan. Aku tegasin di "Hal yang sering dilupakan".
8. **`context.mounted` check** sebelum show SnackBar — biar nggak error "Looking up a deactivated widget's ancestor".

Kalau ada yang nggak sreg, bilang sekarang sebelum Batch 5 — batch terakhir (DO's/DON'Ts, Firebase Project Info, Cara Pakai Dokumen).

---

## 12. DO's and DON'Ts

Ringkasan aturan keras yang harus diikuti AI maupun manusia. **Section paling penting buat di-paste ke AI**.

### DO ✅

✅ **Selalu pakai Model class** untuk merepresentasikan data Firestore. Jangan akses `doc.data()['field']` langsung di widget.

✅ **Semua Firebase call lewat `services/`**. Provider boleh wrap service, widget boleh panggil service langsung untuk one-shot operation. Tapi **jangan ada `FirebaseFirestore.instance` di luar `services/`**.

✅ **Pakai `FieldValue.serverTimestamp()`** untuk semua `createdAt`/`updatedAt`. JANGAN `DateTime.now()`.

✅ **Wrap semua Firebase call dengan try-catch.** Throw `Exception('Pesan Bahasa Indonesia: $e')` biar bisa langsung di-show ke user via SnackBar.

✅ **Pakai `StreamBuilder` untuk data realtime** (chat, list sesi aktif). Pakai `FutureBuilder` untuk one-time fetch.

✅ **Loading state pakai `CircularProgressIndicator`.** Empty state kasih text yang clear (misal "Belum ada sesi aktif"). Error state kasih pesan + tombol retry kalau memungkinkan.

✅ **Selalu cek `context.mounted`** sebelum show SnackBar atau Navigator setelah async operation.

✅ **Ambil userId dari `FirebaseAuth.instance.currentUser?.uid`** atau `AuthProvider`. JANGAN hardcode atau passing manual.

✅ **Pakai `FieldValue.arrayUnion()`/`arrayRemove()`** untuk update array. JANGAN baca array, modify, terus write balik — race condition.

✅ **Pakai Firestore Transaction** untuk operasi yang involve 2+ document atau yang harus atomic (join sesi, submit review).

✅ **Denormalisasi konsisten**: tiap simpan `xxxId`, simpan juga `xxxName` dan `xxxPhotoUrl` kalau bakal ditampilkan.

✅ **Untuk akses data user lain (yang BUKAN diri sendiri)**, pakai data denormalized yang sudah ada di sessions/messages/reviews. JANGAN query `users/{otherUserId}` — akan kena permission-denied.

✅ **Update field `updatedAt`** setiap kali update document.

✅ **Validasi input di form** sebelum panggil service. Service kerjanya cuma operasi, bukan validasi UI.

### DON'T ❌

❌ **JANGAN hardcode userId, email, atau data user lain.** Selalu ambil dari Auth atau Firestore.

❌ **JANGAN simpan password atau data sensitif** di Firestore. Firebase Auth handle password sendiri.

❌ **JANGAN pakai `DateTime.now()` untuk timestamp Firestore.** Pakai `FieldValue.serverTimestamp()`. Alasan: jam HP user bisa salah.

❌ **JANGAN bikin field baru tanpa update dokumen ini.** Update spec dulu, baru implementasi.

❌ **JANGAN ubah Security Rules tanpa konfirmasi Deon.** Salah rules = data bocor atau app rusak.

❌ **JANGAN install package baru tanpa konfirmasi.** Cek `pubspec.yaml` dulu, mungkin sudah ada package serupa.

❌ **JANGAN bikin fitur yang nggak ada di section "IN SCOPE".** Lihat Section 3.

❌ **JANGAN panggil `FirebaseFirestore.instance` di widget atau provider.** Selalu lewat service.

❌ **JANGAN return raw `DocumentSnapshot` dari service.** Konversi ke Model dulu.

❌ **JANGAN pakai `allow read: if true`** atau `allow write: if true` di Security Rules. Walau "buat development", bisa lupa di-revert.

❌ **JANGAN bikin folder baru di `lib/`** kecuali ada di Section 4. Kalau butuh, tanya Deon.

❌ **JANGAN pakai snake_case untuk field Firestore atau Dart variable.** camelCase only.

❌ **JANGAN ubah struktur folder `services/`, `models/`, `providers/`** tanpa diskusi.

❌ **JANGAN edit field document orang lain** (kecuali admin). Rules akan reject, tapi code kamu yang error.

❌ **JANGAN pakai `setState` di provider.** Pakai `notifyListeners()`.

❌ **JANGAN bikin Cloud Functions atau pakai Firebase Admin SDK di mobile app.** Itu cuma untuk web admin dashboard atau Blaze plan.

❌ **JANGAN pakai Google Maps API.** Kita pakai `flutter_map` + OpenStreetMap.

❌ **JANGAN query `users/{otherUserId}` untuk data orang lain.** Pakai data denormalized.

---

## 13. Firebase Project Info

**TODO: isi setelah Firebase project dibuat oleh Deon.**

```
Project Name        : Makan Bareng
Project ID          : makan-bareng
Region              : asia-southeast2 (Jakarta)
Plan                : Spark (Free)

Firebase Console    : https://console.firebase.google.com/u/0/project/makan-bareng
Hosting URL (admin) : https://makan-bareng.web.app (setup nanti)

Akses Console (member dengan permission Editor):
- Deon (Backend Lead)         — deon@email.com
- Saladin Setyo H             — saladin@email.com
- Muhammad Ihsan P            — ihsan@email.com  (butuh akses untuk web admin)
- Naemu Enggar M              — (opsional)
- Revandi Akbar               — (opsional)

Akun Admin Pertama (untuk testing web admin):
- Email             : admin@makanbareng.local (atau email Ihsan)
- Set isAdmin: true secara manual di Firestore Console:
  users/{uid} → Edit → tambah field isAdmin (boolean) = true

File konfigurasi yang HARUS di-commit ke Git:
- lib/firebase_options.dart    (hasil `flutterfire configure`)
- android/app/google-services.json
- firestore.rules              (Security Rules)
- storage.rules                (Storage Rules)

JANGAN commit:
- .env atau file dengan API key sensitif
- Service account JSON
```

### 13.1 Setup awal Firebase (cuma Deon yang kerjain)

```
1. Buat project di https://console.firebase.google.com
   - Nama: makan-bareng-apb-2026
   - Disable Google Analytics (opsional, biar simpel)

2. Enable services yang dibutuhkan:
   - Authentication → Sign-in method → Email/Password ENABLED, Google ENABLED
   - Firestore Database → Create database → Production mode → asia-southeast2
   - Storage → **SKIP, butuh Blaze plan. Tidak dipakai.**
   - Hosting → (setup nanti pas mau deploy admin web)

3. Setup Flutter:
   - Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
   - Login Firebase: `firebase login`
   - Configure: `flutterfire configure --project=makan-bareng`
   - Tambah dependency. Jalankan command ini di terminal (jangan tulis `^latest`):
     ```
     flutter pub add firebase_core firebase_auth cloud_firestore
     flutter pub add google_sign_in
     flutter pub add flutter_local_notifications
     ```
   - Command di atas otomatis nambahin versi terbaru ke `pubspec.yaml` dengan format `^X.Y.Z`.
   - **JANGAN install `firebase_storage`** — tidak dipakai di project ini.

4. Initialize di main.dart:
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

5. Publish Security Rules (lihat Section 9.2 dan 9.3).

6. Add member ke Firebase Console: Settings → Users and permissions → Add member.
```

---

## 14. Cara Pakai Dokumen Ini (untuk Tim)

Section ini ditujukan untuk **temen-temen kamu yang akan vibe-coding pakai AI**.

### 14.1 Sebelum mulai coding apa pun

1. **Buka file ini, baca Section 1-3 dulu** (Project Overview, Tech Stack, Fitur & Scope). Wajib paham scope-nya supaya nggak coding fitur yang nggak diminta.
2. **Pin file ini di Discord/WA grup kelompok** biar gampang diakses.
3. **Konfirmasi sama Deon** kalau ada bagian yang nggak ngerti atau menurut kamu salah.

### 14.2 Setiap sesi vibe-coding dengan AI (Claude, Cursor, Copilot, dll)

**Step 1**: Buka chat baru dengan AI. Attach atau paste seluruh isi `MAKAN_BARENG_SPEC.md` ini.

**Step 2**: Kasih instruksi pembuka berikut ke AI (copy-paste persis):

```
Ini adalah dokumen spesifikasi project MakanBareng yang harus kamu ikuti SECARA KETAT.

Aturan main:
1. Baca dan pahami SELURUH dokumen sebelum coding apa pun.
2. Ikuti semua aturan di Section 6 (Naming), Section 7 (Model), Section 8 (Service), Section 12 (DO's/DON'Ts).
3. JANGAN bikin asumsi di luar dokumen ini. Kalau ada hal yang tidak jelas atau tidak tercakup, KATAKAN ke aku dan tanya, JANGAN improvise.
4. JANGAN bikin fitur yang nggak ada di Section 3 "IN SCOPE".
5. JANGAN install package baru tanpa konfirmasi.
6. JANGAN ubah Security Rules, struktur folder, atau data model tanpa konfirmasi.
7. Setiap kali kamu nulis code, sebutkan section mana yang relevan (misal: "Mengikuti pola Section 8.2 untuk service").

Sekarang, tugas pertama aku: [JELASKAN TUGAS KAMU DI SINI]
```

**Step 3**: Saat AI ngasih kode, **verifikasi**:
- Apakah file ditaruh di folder yang benar (Section 4)?
- Apakah naming-nya ikutin Section 6?
- Apakah struktur model class match Section 7.1?
- Apakah service-nya pakai pattern Section 8?
- Ada `FirebaseFirestore.instance` di luar `services/`? **TOLAK kalau ada.**

**Step 4**: Kalau AI minta install package baru → **STOP**. Tanya Deon dulu.

**Step 5**: Kalau AI mau bikin fitur tambahan yang menurutnya "biar lebih bagus" → **STOP**. Cek IN SCOPE di Section 3. Kalau nggak ada, tolak.

**Step 6**: Setelah kode jadi, suruh AI **self-verify**:
```
Sekarang, verifikasi kode yang barusan kamu buat:
- Apakah mengikuti naming convention Section 6?
- Apakah Firebase call ada di services/?
- Apakah pakai FieldValue.serverTimestamp() untuk timestamp?
- Apakah ada try-catch dengan error message Bahasa Indonesia?
Kalau ada yang nggak sesuai, perbaiki sekarang.
```

### 14.3 Workflow per anggota tim

**Saladin (Firebase + Auth)**:
1. Setup awal Firebase (cuma sekali) — kerjain bareng Deon
2. Implement `auth_service.dart` ikutin pattern Section 8 dan 10
3. Rewrite `auth_provider.dart` jadi wrap `AuthService`
4. Update LoginScreen & RegisterScreen biar pakai provider baru
5. Test: register → cek Firestore `users/{newUid}` ke-create otomatis ✅

**Made (Home + Map + Search + Session Service)**:
1. Implement **seluruh** `session_service.dart` (semua method: create, read, stream, join, leave, cancel, complete — lihat Section 8.2 template lengkap)
2. Update `session_provider.dart` jadi wrap `SessionService` dengan stream
3. Ganti `MockData.sessions` di HomeScreen dengan StreamBuilder dari provider
4. Implement logic search (filter by title contain) di provider
5. Implement filter (jarak dari user current location, by waktu)
6. Update peta: marker dari list sesi (gunakan `flutter_map` yang sudah ada)
7. **Penting**: Karena Naemu butuh `createSession`, `joinSession`, `leaveSession` dari service ini, **prioritaskan menyelesaikan session_service.dart di awal minggu** biar Naemu bisa langsung pakai tanpa nunggu.

**Naemu (Chat + Riwayat + Notif, consumer dari SessionService)**:
1. **Tunggu** `session_service.dart` dari Made siap (atau coordinate Made implement method yang Naemu butuhin duluan)
2. **Pakai** (bukan edit) method dari `session_service.dart`: `createSession`, `joinSession`, `leaveSession`, `cancelSession`, `completeSession` dari widget/screen kamu
3. Implement `chat_service.dart` dengan Stream (ini wilayah Naemu sepenuhnya)
4. Update `chat_provider.dart`
5. Ganti chat dummy dengan StreamBuilder dari `chat_service`
6. Implement Riwayat: panggil `SessionService().streamUserSessions(currentUserId)` dari screen kamu
7. Update `screens/session/create_session_screen.dart` biar pakai `SessionService().createSession()` (kamu boleh edit screen-nya, JANGAN edit service-nya)
8. Implement `notification_service.dart` (local notification — ini wilayah Naemu sepenuhnya)

**Ihsan (Profil + Admin)**:
1. Implement `user_service.dart` (CRUD profil)
2. Update `user_provider.dart`
3. Halaman edit profil: pakai `user_service.updateProfile()` (foto pakai auto-generated avatar URL, bukan upload — lihat Section 11.3)
4. **Admin dashboard** (Flutter Web): 
   - Setup route `/admin` di main.dart, guard dengan check `isAdmin`
   - Halaman: list users, list sessions, CRUD restaurants
   - Pakai `restaurant_service.dart` untuk CRUD tempat makan
5. Build untuk web: `flutter build web`

**Revandi (Rating + Testing)**:
1. Implement `review_service.dart`
2. Update RatingScreen biar submit ke Firestore via `ReviewService` (langsung, tanpa provider)
3. Implement Firestore Transaction untuk update `users/{revieweeId}.averageRating` + `totalReviews` saat submit review
4. Tulis unit test untuk service (minimal: auth_service, session_service, review_service)
5. Dokumentasi teknis: README.md update, alur sistem

### 14.4 Versioning dokumen ini

Kalau ada perubahan signifikan, update di bagian atas dokumen:
- Naikkan versi (1.0 → 1.1 → 1.2 ...)
- Update tanggal
- Tulis ringkas perubahan di bawah ini:

```
## Changelog
- v1.0 (18 Mei 2026): Initial spec
```

### 14.5 Kalau ada masalah / pertanyaan

1. Cek dulu di dokumen ini, di Section yang relevan
2. Cari di error log Firebase Console (Authentication, Firestore, Storage)
3. Tanya AI dengan attach dokumen ini
4. Tanya Deon (Backend Lead)
5. Tanya dosen kalau memang requirement-nya yang nggak jelas

---

## 15. Git Workflow & Anti Merge Conflict

Section ini buat **menghindari merge conflict** yang sering bikin tugas kelompok berantakan. Aturan di sini **wajib diikuti**, jauh lebih penting daripada banyak orang sadari.

### 15.1 Prinsip utama

**Konflik terjadi kalau 2 orang edit baris yang sama di file yang sama.** Jadi strategi pencegahannya:

1. **Pisahkan file per orang** — file structure di Section 4 udah didesain biar tiap orang punya "wilayah" sendiri
2. **Branch per fitur** — jangan langsung push ke `main`
3. **Pull sebelum push** — selalu, tanpa kecuali
4. **Commit kecil & sering** — bukan 1 commit gede di akhir hari
5. **Komunikasi sebelum sentuh "shared file"** — ada beberapa file yang semua orang harus sentuh, ini perlu diatur

### 15.2 Pembagian "wilayah" file per orang

Setiap orang punya file-file yang **eksklusif** mereka edit. Anggota lain JANGAN sentuh file ini kecuali atas izin pemiliknya.

| Anggota | File yang HANYA dia edit |
|---------|--------------------------|
| **Saladin** | `services/auth_service.dart`, `providers/auth_provider.dart`, `screens/auth/*` |
| **Made** | `services/session_service.dart` (SELURUH method), `providers/session_provider.dart`, `screens/home/*`, `widgets/session_card.dart`, `widgets/map_*.dart` |
| **Naemu** | `services/chat_service.dart`, `providers/chat_provider.dart`, `services/notification_service.dart`, `screens/session/create_session_screen.dart`, `screens/chat/*`, `screens/history/*` |
| **Ihsan** | `services/user_service.dart`, `services/restaurant_service.dart`, `providers/user_provider.dart`, `screens/profile/*`, `screens/admin/*` |
| **Revandi** | `services/review_service.dart`, `screens/rating/*`, folder `test/*` |
| **Deon** | file dokumentasi (`*.md`), Security Rules, `core/*` |

**Catatan penting**: Naemu pakai `session_service.dart` (panggil method dari widget/screen-nya) tapi **tidak edit file service-nya**. Kalau Naemu butuh method baru di session_service yang belum ada, request ke Made via WA — Made yang implement, bukan Naemu tambahin sendiri.

### 15.3 Shared Files — yang semua orang BISA edit (HATI-HATI)

Beberapa file akan disentuh banyak orang. Untuk ini, **aturan khusus**:

| File | Aturan |
|------|--------|
| `main.dart` | Cuma Deon yang edit di awal (setup Firebase init + provider tree). Setelah itu, **siapa pun yang mau tambah Provider/route harus bilang di grup WA dulu**. |
| `pubspec.yaml` | **Siapapun yang mau install package WAJIB bilang dulu di grup**. Setelah disetujui Deon, baru push. Konflik pubspec sering banget dan susah resolve. |
| `models/*.dart` | Owner per model: `user_model.dart` (Saladin), `session_model.dart` (Made), `chat_message_model.dart` (Naemu), `restaurant_model.dart` (Ihsan), `review_model.dart` (Revandi). Yang lain JANGAN edit, tapi **boleh request perubahan via WA**. |
| `core/theme/*` | Cuma Ihsan (UI/UX) yang edit. Yang lain pakai aja, jangan modif. |
| `firebase_options.dart` | **JANGAN MANUAL EDIT** — auto-generated. Cuma Deon yang regenerate kalau perlu. |
| `firestore.rules`, `storage.rules` | Cuma Deon. |

### 15.4 Branch Strategy

**JANGAN langsung push ke `main`.** Pakai branch per fitur:

```
main                  ← branch utama, selalu "siap demo"
├── feat/firebase-setup       (Deon — setup awal)
├── feat/auth                 (Saladin)
├── feat/home-and-map         (Made)
├── feat/sessions             (Naemu)
├── feat/chat                 (Naemu)
├── feat/profile              (Ihsan)
├── feat/admin-dashboard      (Ihsan)
├── feat/rating               (Revandi)
└── fix/<description>         (siapa aja, buat bug fix)
```

**Naming branch**: `feat/<deskripsi-pendek>` untuk fitur baru, `fix/<deskripsi-pendek>` untuk bug fix. Pakai dash, bukan underscore atau spasi.

### 15.5 Step-by-step workflow harian

**Setiap hari sebelum mulai coding:**

```bash
# 1. Pindah ke main
git checkout main

# 2. Pull update terbaru
git pull origin main

# 3. Pindah ke branch fitur kamu (atau buat baru kalau belum ada)
git checkout feat/<your-feature>
# atau buat baru:
git checkout -b feat/<your-feature>

# 4. Merge update dari main ke branch kamu (penting!)
git merge main
# Resolve konflik kalau ada (harusnya minimal kalau file kamu eksklusif)
```

**Saat coding:**

- Commit setiap selesai 1 logical unit (1 method, 1 widget, 1 fix). Jangan tunggu 1 jam baru commit.
- Commit message yang clear: 
  - ✅ `feat: add joinSession method in SessionService`
  - ✅ `fix: handle null user in profile screen`
  - ❌ `update`, `fix bug`, `wip`

**Sebelum push (akhir sesi coding):**

```bash
# 1. Pull main lagi (mungkin ada update terbaru dari temen lain)
git checkout main
git pull origin main

# 2. Balik ke branch kamu, merge main lagi
git checkout feat/<your-feature>
git merge main
# Resolve konflik kalau ada

# 3. Push branch kamu
git push origin feat/<your-feature>
```

**Saat fitur kamu selesai dan siap masuk main:**

1. Push branch terakhir kalinya
2. Buka **GitHub → Pull Request → New Pull Request**
3. Base: `main`, compare: `feat/<your-feature>`
4. Tulis deskripsi singkat: apa yang berubah, file mana yang disentuh
5. Tag Deon di PR untuk review
6. Setelah Deon approve, klik **Merge Pull Request**
7. Delete branch lama (`Delete branch` di GitHub setelah merge)

### 15.6 Aturan khusus untuk vibe-coding dengan AI

AI suka **regenerate seluruh file** walau cuma diminta tambah 1 method. Ini bikin konflik tinggi padahal niatnya kecil. Cara hindarinnya:

**JANGAN suruh AI**: "Tulis ulang `session_service.dart` dengan tambahan method X"

**LEBIH BAIK**: "Tambahkan method X ke `session_service.dart`. Tunjukkan **hanya method baru yang ditambahkan**, jangan tulis ulang method lain. Aku akan paste-in sendiri ke file existing."

Kalau terlanjur AI nulis ulang seluruh file:
1. Bandingkan baris-baris yang ada perubahan signifikan saja
2. Copy **cuma bagian yang baru**, bukan paste full file
3. Atau, kalau memang harus paste full, **review dulu seluruh file** biar tau apa yang berubah

### 15.7 Kalau terjadi konflik

Konflik di Git muncul dengan tanda:

```
<<<<<<< HEAD
kode kamu (yang ada di branch kamu sekarang)
=======
kode dari branch lain
>>>>>>> feat/something
```

**Cara handle:**

1. **JANGAN PANIK.** Ini bukan bug, ini tinggal pilih versi mana yang dipakai.
2. Buka file yang konflik di VS Code — bakal ada UI yang ngasih tombol "Accept Current Change", "Accept Incoming Change", "Accept Both".
3. **Pikir**: kode mana yang harusnya dipakai? Atau gabungan keduanya?
4. Hapus marker `<<<<<<<`, `=======`, `>>>>>>>` setelah resolve.
5. `git add <file>` → `git commit -m "merge: resolve conflict in <file>"`
6. Kalau bingung, **tanya pemilik file** lewat WA. Jangan asal merge.

### 15.8 Setup Repository di GitHub (sekali aja)

Deon (atau yang punya akses owner repo) lakukan setup sekali:

1. **Settings → Branches → Branch protection rules** → add rule untuk `main`:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (minimal 1)
   - ✅ Require linear history (opsional, biar history rapi)
2. **Settings → Collaborators** → add semua anggota tim dengan akses **Write**

Ini bikin **nggak ada yang bisa push langsung ke `main`**. Semua harus lewat PR. Disipliner banget tapi nyelametin.

### 15.9 Aturan emergency

Kalau situasi udah chaos (banyak konflik, branch berantakan):

1. **JANGAN force push ke main.** Ini bisa hapus kerjaan orang.
2. **Backup branch lokal** sebelum operasi besar: `git branch backup-<tanggal>`
3. **Tanya Deon** sebelum lakukan operasi destructive (`git reset --hard`, `git push --force`).
4. **Kalau bener-bener stuck**, bikin branch baru dari kondisi terakhir yang aman, copy-paste file yang udah kamu kerjain, push branch baru. Lebih aman daripada coba "fix" branch yang rusak.

### 15.10 Ringkasan: Do's and Don'ts Git

**DO ✅**
- ✅ `git pull` sebelum mulai coding tiap hari
- ✅ Commit kecil & sering (tiap selesai 1 method/widget)
- ✅ Push branch kamu setiap hari (biar ada backup di cloud)
- ✅ Konfirmasi di grup sebelum edit shared file
- ✅ Buat PR untuk merge ke `main`, biar di-review

**DON'T ❌**
- ❌ Push langsung ke `main`
- ❌ Edit file yang bukan "wilayah" kamu tanpa izin pemiliknya
- ❌ Install package tanpa konfirmasi
- ❌ Force push (`git push --force`) tanpa diskusi
- ❌ Suruh AI regenerate seluruh file kalau cuma butuh tambah 1 method
- ❌ Commit dengan message "update" atau "fix" tanpa deskripsi
- ❌ Biarkan branch tidak di-sync selama berhari-hari (makin lama, makin susah merge)

### 15.11 Panduan AI Agent untuk Git/GitHub Operations

Section ini ditulis **khusus untuk AI agent** (Claude, Cursor, Copilot, dll) yang melakukan operasi Git atas nama anggota tim. Anggota tim cukup bilang ke AI:

> "Aku mau push perubahan ini ke GitHub. Ikutin Section 15.11 di MAKAN_BARENG_SPEC.md."

AI yang baca section ini WAJIB ikutin protokol di bawah persis.

---

#### 🤖 PROTOKOL AI UNTUK GIT OPERATIONS

**ATURAN UTAMA**:
1. **JANGAN PERNAH push langsung ke `main`.** Branch `main` di-protect.
2. **JANGAN PERNAH pakai `git push --force` atau `git reset --hard`** kecuali user secara eksplisit memintanya dan mengonfirmasi 2x.
3. **JANGAN PERNAH delete branch lain** atau modify history yang sudah di-push.
4. **SELALU pull sebelum push.**
5. **SELALU verify branch sekarang sebelum commit.** Pastikan user nggak accidentally di branch yang salah.
6. **SELALU tampilkan command yang akan dijalankan** ke user sebelum eksekusi (di terminal). User boleh konfirmasi atau batalkan.

---

#### Alur Standard: Push perubahan baru

Saat user bilang "push perubahan ini" atau "commit dan push", AI HARUS ikutin langkah berikut **secara urut**:

**Step 1: Cek status repo saat ini**

```bash
git status
git branch --show-current
```

Analisa output:
- Branch sekarang apa? Kalau `main` → **STOP**, kasih warning ke user (lihat penanganan di bawah).
- Ada perubahan apa? Tampilkan list file yang berubah ke user.

**Step 2: Verifikasi branch yang benar**

Cocokkan dengan tabel "wilayah file" di Section 15.2. Contoh:
- Kalau user edit `lib/services/auth_service.dart` → harusnya di branch `feat/auth` (Saladin)
- Kalau user edit `lib/screens/rating/*` → harusnya di branch `feat/rating` (Revandi)

**Kalau branch sekarang adalah `main`**:
```
⚠️ WARNING: Kamu sekarang di branch `main`. Branch ini di-protect dan tidak boleh menerima commit langsung.

Aku akan bantu pindah ke branch fitur yang sesuai. Berdasarkan file yang kamu edit, branch yang sesuai adalah `feat/<X>`.

Apakah:
(a) Buat branch baru `feat/<X>` dari kondisi sekarang? (recommended)
(b) Branch `feat/<X>` sudah ada, pindah ke sana?
(c) Batalkan, aku mau pindah manual.
```

Tunggu user pilih sebelum lanjut.

**Step 3: Pull update terbaru dari main**

Sebelum commit, sync dengan main biar nggak konflik di PR:

```bash
# Save current changes dulu (kalau ada uncommitted)
git stash push -m "wip-before-pull-$(date +%s)"

# Pull main
git checkout main
git pull origin main

# Kembali ke branch fitur
git checkout <feature-branch>
git merge main

# Restore changes
git stash pop
```

**Kalau ada konflik saat merge main**:
```
⚠️ Ada konflik saat merge main ke branch ini. File yang konflik:
- <list file>

Aku BISA bantu resolve, tapi kamu yang putusin akhirnya. Apakah:
(a) Kasih aku liat konflik-nya, aku saran resolusi
(b) Kamu resolve manual dulu, baru aku lanjut commit
(c) Batalkan operasi, kamu konsultasi sama owner file dulu (lihat Section 15.2)
```

**STOP, tunggu user.** Jangan resolve sepihak.

**Step 4: Stage & commit dengan message yang baik**

```bash
git add <specific files>  # JANGAN pakai `git add .` kecuali user minta eksplisit
git commit -m "<type>: <deskripsi singkat>"
```

**Format commit message** (ikutin Conventional Commits):
- `feat: tambah method joinSession di SessionService`
- `fix: handle null user di profile screen`
- `refactor: rename hostId jadi sesuai naming convention`
- `docs: update README dengan setup Firebase`
- `test: tambah unit test untuk ReviewService`
- `chore: update dependency firebase_auth`

**JANGAN**:
- ❌ `commit -m "update"`
- ❌ `commit -m "wip"`
- ❌ `commit -m "fix bug"` tanpa deskripsi bug-nya

**Kalau ada banyak perubahan** dari berbagai jenis, sarankan ke user: **pisah jadi multiple commits**, biar history bersih.

**Step 5: Push ke remote**

```bash
git push origin <feature-branch>
```

**JANGAN pakai `-u` flag** kecuali ini push pertama untuk branch baru. Kalau push pertama, pakai:
```bash
git push -u origin <feature-branch>
```

**Step 6: Konfirmasi ke user**

Setelah berhasil, kasih ringkasan:
```
✅ Berhasil push ke branch `feat/<X>`.

Yang baru saja di-push:
- <commit 1 message>
- <commit 2 message>

File yang berubah:
- <list>

Next step:
- Kalau fitur kamu udah selesai, buka GitHub → New Pull Request dari `feat/<X>` ke `main`
- Tag Deon di PR untuk review
- Jangan merge sendiri, tunggu approval

Mau aku bantu buatkan PR description? [Y/N]
```

---

#### Skenario Edge Case yang Harus AI Tangani

**Skenario A: User minta push ke main langsung**

```
❌ Tidak bisa. Branch `main` di-protect (lihat Section 15.8 dan 15.4).

Semua perubahan harus lewat branch fitur dan Pull Request. Ini aturan tim, bukan aturan aku.

Mau aku:
(a) Buat branch baru dari perubahan ini, terus push ke sana?
(b) Tampilkan langkah PR ke kamu?
```

**JANGAN turuti permintaan push ke main**, walau user bilang "aku owner repo".

**Skenario B: User minta force push**

```
⚠️ `git push --force` itu destructive. Bisa hapus kerjaan orang lain di branch yang sama.

Sebelum aku eksekusi, klarifikasi:
1. Kenapa butuh force push? Apa yang mau dibenerin?
2. Apakah branch ini cuma kamu yang pakai, atau ada orang lain juga?
3. Sudah konfirmasi sama Deon? (lihat Section 15.9)

Kalau jawabannya "ya, sudah" untuk semua, ketik "FORCE PUSH KONFIRM" untuk eksekusi.
```

**Skenario C: User minta install package baru**

Sebelum push code yang ada package baru:
```
⚠️ Kamu menambah package baru di pubspec.yaml:
- <list package>

Per Section 12 dan 15.3, install package WAJIB konfirmasi ke Deon dulu.

Apakah:
(a) Sudah konfirmasi ke Deon? Kalau ya, ketik "PACKAGE DISETUJUI"
(b) Belum, aku akan stop di sini. Tanya Deon di grup dulu.
(c) Sebenernya nggak perlu package itu, aku bisa cari cara lain.
```

**Skenario D: User edit file yang BUKAN wilayahnya**

Cek Section 15.2. Kalau user edit file orang lain:
```
⚠️ Berdasarkan Section 15.2, file `<path>` adalah wilayah `<owner-name>`, bukan kamu.

Edit file orang lain bisa bikin konflik dan masalah koordinasi.

Apakah:
(a) Sudah konfirmasi ke <owner-name>? Kalau ya, ketik "WILAYAH DIIZINKAN"
(b) Belum, batalkan dulu. Tanya owner di grup.
(c) Sebenernya cukup edit di file aku sendiri, bukan di file ini.
```

**Skenario E: Banyak file berubah (>10 files)**

```
⚠️ Ada <N> file yang berubah dalam commit ini. Itu banyak.

Saran: pisah jadi beberapa commit kecil per fitur/aspek, biar history rapi dan PR gampang di-review.

Aku bisa bantu group file-nya berdasarkan konteks. Mau?
```

**Skenario F: AI sebelumnya regenerate seluruh file**

Kalau AI menemukan diff yang sangat besar untuk 1 file (misal: `auth_service.dart` berubah 200+ baris padahal user cuma minta tambah 1 method):

```
⚠️ File `<path>` punya perubahan signifikan (<N> baris). Sepertinya AI sebelumnya (atau aku) tulis ulang seluruh file.

Per Section 15.6, lebih baik AI cuma kasih method baru, bukan rewrite full file. Sekarang kondisinya udah terlanjur.

Sebelum push, aku saran:
(a) Review diff bareng aku — aku tunjukin mana yang benar-benar berubah secara fungsional vs yang cuma reformat
(b) Revert file ini ke versi sebelumnya, baru tambah method baru secara minimal
(c) Push aja, kamu udah review semua perubahan

Mana yang kamu mau?
```

---

#### Pull Request: Cara minta AI bantu buat PR

Setelah branch di-push, user bisa minta AI bantu buat PR description. AI ikutin template ini:

```markdown
## Apa yang berubah

<deskripsi singkat 1-2 kalimat: fitur apa, behavior apa>

## File yang disentuh

- `<path/to/file>` — <alasan>
- `<path/to/file>` — <alasan>

## Ngikuti Section apa di Spec

- Section <X>: <deskripsi>
- Section <X>: <deskripsi>

## Cara test

1. <langkah test 1>
2. <langkah test 2>

## Checklist

- [ ] Mengikuti naming convention Section 6
- [ ] Firebase calls cuma di `services/` (Section 8)
- [ ] Pakai `FieldValue.serverTimestamp()` untuk timestamp
- [ ] Ada try-catch dengan error message Bahasa Indonesia
- [ ] Tidak install package baru tanpa konfirmasi
- [ ] Tidak edit file di luar wilayah saya (Section 15.2)

## Catatan untuk reviewer (Deon)

<hal yang perlu diperhatikan, kalau ada>
```

User tinggal copy-paste ini ke GitHub saat buka PR.

---

#### Quick Reference: Command yang Sering Dipakai

Untuk AI yang nggak hafal command Git, berikut yang paling sering dipakai dalam project ini:

| Tujuan | Command |
|--------|---------|
| Cek status | `git status` |
| Cek branch sekarang | `git branch --show-current` |
| List semua branch | `git branch -a` |
| Pindah branch | `git checkout <branch>` |
| Buat branch baru | `git checkout -b <branch>` |
| Pull main | `git checkout main && git pull origin main` |
| Sync branch dengan main | `git merge main` (saat di branch fitur) |
| Stage spesifik | `git add <file1> <file2>` |
| Stage semua (hati-hati) | `git add .` |
| Commit | `git commit -m "<type>: <message>"` |
| Push pertama kali | `git push -u origin <branch>` |
| Push selanjutnya | `git push origin <branch>` |
| Lihat diff | `git diff` |
| Lihat history | `git log --oneline -10` |
| Stash perubahan | `git stash push -m "<note>"` |
| Restore stash | `git stash pop` |

**Command yang JANGAN dipakai tanpa konfirmasi user 2x**:
- `git push --force` / `git push -f`
- `git reset --hard`
- `git rebase` (kompleks, gampang error)
- `git branch -D <branch>` (delete branch force)
- `git clean -fd` (hapus untracked files)

---

#### Prompt Template untuk Anggota Tim

Anggota tim bisa pakai prompt ini saat mau push code via AI:

```
Aku mau push perubahan ke GitHub. Ikutin Section 15.11 di MAKAN_BARENG_SPEC.md.

Konteks:
- Aku [nama anggota]
- File yang berubah: [list file]
- Tujuan: [deskripsi singkat fitur/fix]

Tolong:
1. Cek status repo dan branch
2. Verifikasi branch yang benar
3. Pull main dulu
4. Commit dengan message yang sesuai
5. Push ke remote
6. Kasih ringkasan setelah selesai

Jangan eksekusi command apapun tanpa kasih lihat ke aku dulu.
```

---



---

## Penutup

Dokumen ini bukan final-final amat — kalau ada hal yang ternyata salah atau perlu diubah saat implementasi, **update dokumen ini dulu** sebelum implementasi. Ini supaya tim selalu sync.

Target: dalam 2 minggu, aplikasi end-to-end dengan backend asli (bukan mock), siap demo, fitur lengkap sesuai IN SCOPE.

**Semangat tim MakanBareng! 🍜**

---

## Changelog

- v1.0 (18 Mei 2026): Initial spec — semua section 1-14 ditulis oleh Deon.
- v1.1 (18 Mei 2026): Tambah Section 15 (Git Workflow & Anti Merge Conflict).
- v1.2 (18 Mei 2026): Tambah Section 15.11 — Panduan AI Agent untuk Git/GitHub Operations.
- v1.3 (18 Mei 2026): Bug fixes hasil audit ulang. Fixes:
  - Konsistensi `foodPreferences` (semua tempat sekarang free text)
  - Update prinsip Security Rules 9.1 sesuai keputusan strict
  - Update test minimum 9.4 sesuai rules yang sebenarnya
  - Fix bug teknis di Section 11.7: ganti `Future.asStream()` (cuma 1 emit) jadi `Stream.snapshots()` dari Firestore (proper realtime listener). Tambah method `streamSessionById` ke SessionService.
  - Fix layout Penutup yang hilang heading-nya
  - Fix konflik wilayah `session_service.dart`: SELURUH method jadi tanggung jawab Made, Naemu hanya consumer (panggil dari widget/screen, tidak edit service-nya)
- v1.4 (18 Mei 2026): Hapus Firebase Storage (butuh Blaze plan). Foto profil pakai auto-generated avatar URL + Google photo URL. Hapus `storage_service.dart`. Update Section 2, 4, 5, 8, 9, 11, 13, 14, 15. Update project info dengan data real (project ID: `makan-bareng`).