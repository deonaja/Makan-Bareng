# MakanBareng — Panduan Tim (Cara Pakai SPEC)

> **Dari**: Deon
> **Untuk**: Tim MakanBareng (Saladin, Made, Naemu, Ihsan, Revandi)
> **Estimasi baca**: 10 menit
> **Tanggal**: 18 Mei 2026

---

## Halo tim 👋

Aku udah bikin dokumen besar namanya **MAKAN_BARENG_SPEC.md** — isinya semua aturan teknis buat ngerjain backend project kita.

Dokumen itu panjang banget (2500+ baris) — kalian **nggak harus baca semuanya**. Yang penting kalian **tau cara pakainya**, karena nanti AI yang akan baca detailnya buat kalian.

Tujuan dokumen ini (yang sedang kalian baca sekarang): kasih tau **gambaran besar** + **cara pakai SPEC** dalam 10 menit.

---

## TL;DR — yang harus kalian tau dalam 30 detik

1. **Backend kita pakai Firebase** (gratis, no kartu kredit). Aku yang setup, kalian tinggal pakai.
2. **Aku udah bikin SPEC** yang ngedefinisiin SEMUA aturan teknis. Kalian nggak perlu mikir desain database, naming, dll — udah ada di SPEC.
3. **Cara kerja kalian: vibe-coding pakai AI** (Claude, Cursor, dll) yang sebelumnya **kalian kasih SPEC dulu**. AI yang patuh SPEC akan jadi rekan kerja yang bisa diandalkan.
4. **Tiap orang punya wilayah file sendiri** biar nggak konflik. Sentuh file orang lain = harus izin.
5. **Push ke GitHub via branch + PR**, JANGAN langsung ke `main`. `main` di-protect.
6. **Kalau ada yang nggak ngerti, tanya aku di grup**. Jangan diem-diem improvise.

---

## Kondisi project sekarang

**Frontend**: UI udah bagus (kerja kalian). Tapi datanya masih dummy / MockData yang cuma jalan di RAM HP. Restart app = data hilang.

**Backend**: BELUM ADA. 0%. Ini yang kita garap 2 minggu ke depan.

**Target**: Migrasi semua dari dummy ke Firebase. App jalan beneran end-to-end. Data tersimpan di cloud. Login real, chat real, dll.

---

## Yang berubah dari kondisi sekarang ke target

| Sekarang (mock) | Nanti (Firebase) |
|----------|----------|
| Login cocokin email di list dummy | Login real lewat Firebase Auth |
| Data sesi disimpan di Provider (RAM) | Data sesi di Cloud Firestore |
| Chat hilang kalau app di-restart | Chat tersimpan permanen di Firestore |
| Foto profil hardcoded | Upload foto ke Firebase Storage |
| Web admin dashboard: nggak ada | Web admin di codebase Flutter yang sama |
| Notifikasi: nggak ada | Local notification kalau ada yang join sesi |

---

## Tugas masing-masing

Aku udah breakdown tugas di **SPEC Section 14.3** lebih detail. Ringkasnya:

| Anggota | Fokus utama |
|---------|-------------|
| **Saladin** | Migrasi Auth dari mock ke Firebase Auth. Login/Register beneran jalan. |
| **Made** | Implementasi `session_service.dart` (CRUD sesi). Ganti MockData di Home dengan Firestore real. Search & Filter functional. |
| **Naemu** | Chat realtime via Firestore. Riwayat sesi. Local notification saat ada yang join. (PAKAI session_service dari Made, jangan edit) |
| **Ihsan** | Edit profil ke Firestore. Upload foto. **Web admin dashboard** (Flutter Web). |
| **Revandi** | Rating ke Firestore + transaction update rating user. Unit testing. Dokumentasi teknis. |
| **Deon (aku)** | Setup Firebase, security rules, koordinasi, review PR, jaga konsistensi. |

---

## Cara kerja sehari-hari

### 1. Pertama kali setup di laptop kalian

```bash
git clone <repo-url>
cd makan_bareng
flutter pub get
```

**Sebelum coding apa-apa**, baca **Section 1-3** dari SPEC dulu (overview, tech stack, scope). Sekitar 5 menit baca.

### 2. Setiap mulai coding di hari baru

```bash
# Pindah ke main, pull update terbaru
git checkout main
git pull origin main

# Pindah ke branch fitur kamu (atau bikin baru kalau belum ada)
git checkout feat/<your-feature>
# atau bikin baru:
git checkout -b feat/<your-feature>

# Merge update dari main
git merge main
```

Branch fitur kamu sesuaikan dengan tugas:
- Saladin: `feat/auth`
- Made: `feat/home-and-session-service`
- Naemu: `feat/chat`, `feat/notifications`, dst
- Ihsan: `feat/profile`, `feat/admin-dashboard`
- Revandi: `feat/rating`, `feat/testing`

### 3. Saat vibe-coding dengan AI

**Setiap sesi baru** di AI (Claude/Cursor/dll), step pertama:

1. Attach atau paste seluruh isi `MAKAN_BARENG_SPEC.md` ke AI
2. Pakai prompt opening ini (copy-paste persis):

```
Ini adalah dokumen spesifikasi project MakanBareng yang harus kamu ikuti SECARA KETAT.

Aturan main:
1. Baca dan pahami SELURUH dokumen sebelum coding apa pun.
2. Ikuti semua aturan di Section 6 (Naming), Section 7 (Model), Section 8 (Service), Section 12 (DO's/DON'Ts).
3. JANGAN bikin asumsi di luar dokumen ini. Kalau ada hal yang tidak jelas, KATAKAN ke aku dan tanya, JANGAN improvise.
4. JANGAN bikin fitur yang nggak ada di Section 3 "IN SCOPE".
5. JANGAN install package baru tanpa konfirmasi.
6. JANGAN ubah Security Rules, struktur folder, atau data model tanpa konfirmasi.
7. Setiap nulis kode, sebutkan section mana yang relevan.

Sekarang, tugas pertama aku: [JELASKAN TUGAS KAMU]
```

3. Kasih tugas spesifik kalian.

**Saat AI nulis kode, cek**:
- ✅ File ditaruh di folder yang bener?
- ✅ Naming ikutin Section 6?
- ✅ Firebase call cuma di `services/`?
- ✅ Pakai `FieldValue.serverTimestamp()`?
- ✅ Try-catch dengan error Bahasa Indonesia?

**Kalau AI ngusulin**:
- Install package baru → **STOP**, tanya aku
- Bikin fitur yang nggak ada di IN SCOPE → **STOP**, tanya aku
- Ubah struktur folder atau security rules → **STOP**, tanya aku
- Edit file yang bukan wilayah kalian → **STOP**, izin dulu sama yang punya

### 4. Saat mau push ke GitHub

Suruh AI yang ngerjain. Kasih prompt ini:

```
Aku mau push perubahan ke GitHub. Ikutin Section 15.11 di MAKAN_BARENG_SPEC.md.

Konteks:
- Aku [nama]
- File yang berubah: [list file]
- Tujuan: [deskripsi singkat]

Tolong cek status repo, verifikasi branch, pull main dulu, commit dengan message bener, push, kasih ringkasan. Jangan eksekusi command apapun tanpa kasih lihat dulu.
```

AI akan handle semua tahapannya. Kalau AI minta confirm hal aneh (force push, dll), **JANGAN approve tanpa tanya aku**.

### 5. Saat fitur kalian selesai

1. Push branch terakhir kali
2. Buka GitHub → **New Pull Request** dari branch kalian ke `main`
3. Tag aku di description: `@deonaja review please`
4. Tulis deskripsi singkat (template ada di SPEC Section 15.11 bagian "Pull Request")
5. Tunggu aku approve, baru klik **Merge**

**Jangan merge sendiri walaupun GitHub kasih tombolnya.**

---

## Wilayah file masing-masing

**Aturan paling penting biar nggak konflik**: setiap orang punya file eksklusif. Jangan edit file orang lain tanpa izin.

| Orang | File EKSKLUSIF kalian |
|-------|------------------------|
| **Saladin** | `services/auth_service.dart`, `providers/auth_provider.dart`, `screens/auth/*` |
| **Made** | `services/session_service.dart`, `providers/session_provider.dart`, `screens/home/*`, `widgets/session_card.dart`, `widgets/map_*.dart` |
| **Naemu** | `services/chat_service.dart`, `providers/chat_provider.dart`, `services/notification_service.dart`, `screens/session/create_session_screen.dart`, `screens/chat/*`, `screens/history/*` |
| **Ihsan** | `services/user_service.dart`, `services/restaurant_service.dart`, `providers/user_provider.dart`, `screens/profile/*`, `screens/admin/*` |
| **Revandi** | `services/review_service.dart`, `screens/rating/*`, folder `test/*` |
| **Deon (aku)** | `services/storage_service.dart`, dokumentasi `*.md`, security rules |

**Catatan untuk Naemu**: Kamu pakai `session_service.dart` (Made yang bikin), tapi panggilannya dari widget/screen kamu — JANGAN edit file service-nya. Kalau butuh method baru, request ke Made di grup, dia yang implement.

### Shared files (semua orang boleh sentuh, tapi HATI-HATI)

- **`main.dart`** — aku set up awalnya, kalian boleh tambah Provider atau route tapi **bilang dulu di grup**
- **`pubspec.yaml`** — install package WAJIB bilang ke aku dulu
- **`models/*.dart`** — tiap model punya owner (Saladin: user, Made: session, Naemu: chat_message, Ihsan: restaurant, Revandi: review). JANGAN edit punya orang lain.
- **`core/theme/*`** — cuma Ihsan yang edit
- **`firebase_options.dart`** — JANGAN edit manual, auto-generated

---

## Aturan main yang nggak boleh dilanggar

Ini ringkasan dari Section 12 SPEC. Sisanya baca sendiri.

### MUST DO ✅

1. **Selalu paste SPEC ke AI** sebelum minta dia coding
2. **Selalu `git pull` sebelum mulai coding** tiap hari
3. **Commit kecil & sering** (tiap selesai 1 method/widget), bukan 1 commit gede di akhir
4. **Pakai branch fitur**, push lewat PR
5. **Pakai data denormalized** untuk display data user lain (nama, foto) — jangan query users collection
6. **Validasi input di form** sebelum panggil service

### MUST NOT DO ❌

1. **JANGAN push langsung ke `main`** — udah ku-protect, kalian gak bakal bisa anyway
2. **JANGAN install package tanpa nanya aku**
3. **JANGAN bikin fitur di luar IN SCOPE** (Section 3 SPEC)
4. **JANGAN edit file di luar wilayah kalian** tanpa izin pemiliknya
5. **JANGAN panggil `FirebaseFirestore.instance` di widget atau provider** — selalu lewat services/
6. **JANGAN suruh AI rewrite seluruh file** kalau cuma minta tambah 1 method (bilang: "kasih method baru aja, jangan tulis ulang file")
7. **JANGAN pakai `DateTime.now()` untuk timestamp Firestore** — pakai `FieldValue.serverTimestamp()`
8. **JANGAN ubah Security Rules tanpa konfirmasi aku**

---

## Apa yang aku kerjain di awal (sebelum kalian mulai)

Hari 1-2 (sebelum tugas resmi mulai), aku ngerjain ini sendiri:
1. Setup Firebase project (no kartu kredit)
2. Enable Auth (email + Google), Firestore, Storage
3. Publish Security Rules
4. Setup `flutterfire configure` di local repo
5. Push setup awal ke branch `feat/firebase-setup`
6. Merge ke `main`
7. **Share `firebase_options.dart`** lewat GitHub
8. **Invite kalian** ke Firebase Console biar bisa liat logs/data

Sebelum kalian mulai garap fitur kalian, **tunggu setup ini selesai dulu**. Aku akan kabari di grup.

---

## FAQ

**Q: Aku belum ngerti Git/branch/PR sama sekali, gimana?**
A: Pakai AI buat handle Git operations (Section 15.11 SPEC). Atau install **GitHub Desktop** — UI-nya gampang, tinggal klik. Tanya aku kalau stuck.

**Q: Kalau aku salah edit file orang lain gimana?**
A: Stop, bilang di grup. Kalau belum di-push, di-revert (`git restore <file>`). Kalau udah di-push tapi belum di-merge, kita resolve bareng.

**Q: AI ngotot ngasih solusi yang beda dari SPEC, ngikut yang mana?**
A: SPEC. Selalu. AI bisa salah / outdated. SPEC yang sudah disepakati tim.

**Q: Aku nemu bug di SPEC, gimana?**
A: Bilang aku di grup, kasih konteksnya. Kalau valid, aku update SPEC, naikkan versi, kabari semua.

**Q: Bisa nggak aku pakai package X yang aku familiar?**
A: Tanya dulu. Beberapa hal aku tolak (Google Maps, FCM Cloud Functions) karena alasan teknis/biaya. Tapi banyak yang OK.

**Q: Aku harus baca SPEC 2500 baris? Aku malas.**
A: Nggak. Yang harus kalian baca:
- **Section 1** (overview) — 1 menit
- **Section 3** (IN SCOPE / OUT OF SCOPE) — 2 menit
- **Section 12** (DO/DON'T) — 5 menit
- **Section 14.3** (tugas kalian) — 1 menit
- **Section 15.2** (wilayah file) — 1 menit

Total 10 menit. Sisanya AI yang baca buat kalian.

**Q: Timeline-nya gimana?**
A: 2 minggu mulai sekarang. Minggu 1 fokus implementasi, Minggu 2 integrasi + bug fix + demo prep.

---

## Penutup

Tim, jujur ini tugas yang menantang. UI kalian udah bagus banget (terutama yang OP banget make AI itu hehe), sekarang kita tinggal kasih nyawa real ke backend.

Yang penting:
1. **Patuhin SPEC**. AI yang kalian pakai jadi banyak lebih reliable kalau dia tau aturan main.
2. **Jangan ragu nanya** di grup. Mendingan tanya 10x daripada ngerjain salah arah 2 hari.
3. **Push sering, jangan tunggu sempurna**. Branch fitur kalian = sandbox aman, push apapun di sana.
4. **Hormati wilayah masing-masing**. Ini bukan birokrasi, ini cara biar 5 orang bisa kerja paralel.

Aku standby di grup. Kalau ada yang ganjel atau bingung soal SPEC, langsung tag aku. Selama 2 minggu ke depan, **aku jadi reviewer + helpdesk** kalian.

Gas tim, kita selesain ini dengan rapi 🍜🚀

— Deon
