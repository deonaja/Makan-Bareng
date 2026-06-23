import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../models/restaurant_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final MapController _mapController = MapController();

  int _maxParticipants = 4;
  int _joinDeadlineMinutes = 30;
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));

  // Daftar 9 resto preset — diambil dari MockData
  static List<RestaurantModel> get _restaurants => MockData.restaurants;
  int _selectedRestoIndex = 0;

  RestaurantModel get _selectedResto => _restaurants[_selectedRestoIndex];

  // Tempat makan custom (input nama + link Google Maps)
  bool _useCustomLocation = false;
  final _customNameController = TextEditingController();
  final _customMapsLinkController = TextEditingController();
  LatLng? _customCoord;

  // Titik yang ditampilkan di peta (custom kalau aktif, kalau tidak resto preset)
  LatLng get _activeLocation => _useCustomLocation && _customCoord != null
      ? _customCoord!
      : _selectedResto.location;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customNameController.dispose();
    _customMapsLinkController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _startTime.isAfter(now) ? _startTime : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final selected =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => _startTime = selected);
  }

  /// Ekstrak koordinat dari input lokasi. Mengembalikan koordinat + flag
  /// `approximate`. Mendukung:
  /// - Koordinat mentah "lat,lng" (PRESISI — paling dianjurkan)
  /// - URL Maps lengkap: @lat,lng | !3d!4d | q= | ll= (PRESISI)
  /// - Short link maps.app.goo.gl → hanya dapat `center` thumbnail
  ///   (PERKIRAAN — Google tak mengekspos pin presisi tanpa Places API).
  Future<({LatLng coord, bool approximate})?> _parseLatLngFromMapsUrl(
      String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    LatLng? valid(double? lat, double? lng) {
      // Tolak angka di luar rentang valid — hindari salah tangkap angka lain
      // (zoom, heading, dsb) yang bikin marker loncat ngawur.
      if (lat != null &&
          lng != null &&
          lat >= -90 &&
          lat <= 90 &&
          lng >= -180 &&
          lng <= 180) {
        return LatLng(lat, lng);
      }
      return null;
    }

    // 0. Koordinat mentah "lat,lng" / "lat, lng" — sumber paling presisi.
    final raw =
        RegExp(r'^\s*(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)\s*$').firstMatch(trimmed);
    if (raw != null) {
      final c =
          valid(double.tryParse(raw.group(1)!), double.tryParse(raw.group(2)!));
      if (c != null) return (coord: c, approximate: false);
    }

    // Titik PRESISI dari URL lengkap. !3d!4d/q=/ll= = titik eksplisit;
    // @ = viewport (cukup presisi untuk maksud user yang menyalin URL).
    LatLng? precise(String source) {
      final patterns = <RegExp>[
        RegExp(r'!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)'),
        RegExp(r'[?&]q=(-?\d+\.\d+),(-?\d+\.\d+)'),
        RegExp(r'[?&]ll=(-?\d+\.\d+),(-?\d+\.\d+)'),
        RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)'),
      ];
      for (final p in patterns) {
        final m = p.firstMatch(source);
        if (m != null) {
          final c =
              valid(double.tryParse(m.group(1)!), double.tryParse(m.group(2)!));
          if (c != null) return c;
        }
      }
      return null;
    }

    // Titik PERKIRAAN dari parameter `center` thumbnail (kasus short link).
    LatLng? approxCenter(String source) {
      final m =
          RegExp(r'center=(-?\d+\.\d+)(?:%2C|,)(-?\d+\.\d+)').firstMatch(source);
      if (m == null) return null;
      return valid(double.tryParse(m.group(1)!), double.tryParse(m.group(2)!));
    }

    // 1. Presisi langsung dari input URL.
    final directPrecise = precise(trimmed);
    if (directPrecise != null) {
      return (coord: directPrecise, approximate: false);
    }

    // 2. Resolve link Maps (http) untuk cari koordinat di redirect/body.
    final lower = trimmed.toLowerCase();
    final isMapsLink = lower.startsWith('http') &&
        (lower.contains('goo.gl') ||
            lower.contains('g.co/kgs') ||
            (lower.contains('google.') && lower.contains('map')));
    if (!isMapsLink) return null;

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      try {
        final request = await client.getUrl(Uri.parse(trimmed));
        request.followRedirects = true;
        request.maxRedirects = 10;
        // UA browser — tanpa ini Google bisa membalas halaman berbeda.
        request.headers.set(
          HttpHeaders.userAgentHeader,
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0 Safari/537.36',
        );
        final response =
            await request.close().timeout(const Duration(seconds: 15));

        // URL final setelah redirect kadang sudah memuat koordinat presisi.
        final finalUrl = response.redirects.isNotEmpty
            ? response.redirects.last.location.toString()
            : trimmed;
        final fromUrl = precise(finalUrl);
        if (fromUrl != null) {
          await response.drain();
          return (coord: fromUrl, approximate: false);
        }

        // Baca body. Short link biasanya cuma punya `center` (perkiraan).
        final body = await response
            .transform(const Utf8Decoder(allowMalformed: true))
            .join()
            .timeout(const Duration(seconds: 15));
        final bodyPrecise = precise(body);
        if (bodyPrecise != null) return (coord: bodyPrecise, approximate: false);
        final center = approxCenter(body);
        if (center != null) return (coord: center, approximate: true);
        return null;
      } finally {
        client.close(force: true);
      }
    } catch (_) {
      return null;
    }
  }

  bool _isFetchingLocation = false;

  Future<void> _fetchCustomLocation() async {
    if (_isFetchingLocation) return; // cegah tap ganda saat resolve link
    final link = _customMapsLinkController.text.trim();
    if (link.isEmpty) {
      _showSnackBar(
          'Masukkan link Google Maps atau koordinat dulu', AppColors.error);
      return;
    }

    setState(() => _isFetchingLocation = true);
    try {
      final result = await _parseLatLngFromMapsUrl(link);
      if (!mounted) return;

      if (result != null) {
        setState(() {
          _customCoord = result.coord;
          _useCustomLocation = true;
        });
        _mapController.move(result.coord, 17.0);
        if (result.approximate) {
          _showSnackBar(
            'Lokasi PERKIRAAN dari short link (bisa meleset). Ketuk/geser '
            'peta untuk titik yang presisi.',
            AppColors.warning,
          );
        } else {
          _showSnackBar('Lokasi berhasil diambil', AppColors.success);
        }
      } else {
        _showSnackBar(
          'Gagal membaca lokasi. Tempel koordinat (lat,lng), link lengkap '
          'Google Maps, atau ketuk peta langsung.',
          AppColors.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_startTime.isAfter(DateTime.now())) {
      _showSnackBar('Waktu mulai harus setelah waktu sekarang', AppColors.error);
      return;
    }

    final auth = context.read<AuthProvider>();
    final sessionProvider = context.read<SessionProvider>();
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      _showSnackBar('Kamu harus login dulu', AppColors.error);
      return;
    }

    final String locationName;
    final String locationAddress;
    final double locationLatitude;
    final double locationLongitude;

    if (_useCustomLocation) {
      final customName = _customNameController.text.trim();
      if (customName.isEmpty) {
        _showSnackBar('Nama tempat tidak boleh kosong', AppColors.error);
        return;
      }
      final coord = _customCoord;
      if (coord == null) {
        _showSnackBar(
          'Ambil lokasi dari link dulu sebelum membuat sesi',
          AppColors.error,
        );
        return;
      }
      locationName = customName;
      locationAddress = customName.isNotEmpty ? customName : 'Lokasi pilihan host';
      locationLatitude = coord.latitude;
      locationLongitude = coord.longitude;
    } else {
      final resto = _selectedResto;
      locationName = resto.name;
      locationAddress = resto.address;
      locationLatitude = resto.location.latitude;
      locationLongitude = resto.location.longitude;
    }

    final sessionId = await sessionProvider.createSession(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      hostId: currentUser.uid,
      hostName: currentUser.name,
      hostPhotoUrl: currentUser.photoUrl,
      locationName: locationName,
      locationAddress: locationAddress,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      scheduledAt: _startTime,
      maxParticipants: _maxParticipants,
      joinDeadlineMinutes: _joinDeadlineMinutes,
    );

    if (!mounted) return;

    if (sessionId != null) {
      _showSnackBar('Sesi makan berhasil dibuat', AppColors.success);
      Navigator.pop(context);
    } else {
      _showSnackBar(
        sessionProvider.error ?? 'Gagal membuat sesi',
        AppColors.error,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final sessionProvider = context.watch<SessionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Sesi Makan'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Judul ──────────────────────────────────────────────
              CustomTextField(
                controller: _titleController,
                labelText: 'Judul Sesi',
                hintText: 'Contoh: Makan Siang Bareng',
                prefixIcon: Icons.title_rounded,
                maxLength: 100,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),

              // ── Deskripsi ──────────────────────────────────────────
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Deskripsi',
                hintText: 'Ceritakan tentang sesi makan ini...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 24),

              // ── Pilih Tempat Makan ─────────────────────────────────
              Text('Rekomendasi Tempat Makan', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),

              SizedBox(
                height: 108,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _restaurants.length,
                  itemBuilder: (context, index) {
                    final resto = _restaurants[index];
                    final isSelected = _selectedRestoIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRestoIndex = index;
                          _useCustomLocation = false;
                        });
                        // Gerakkan peta ke lokasi resto yang dipilih
                        _mapController.move(resto.location, 16.0);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 160,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.restaurant_rounded,
                                  size: 14,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    resto.name,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              resto.category,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textTertiary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              resto.priceRange,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.accent,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Info resto terpilih
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedResto.address,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Tempat makan custom ────────────────────────────────
              Text('Atau masukkan tempat lain', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _customNameController,
                labelText: 'Nama Tempat',
                hintText: 'Contoh: Warung Bu Tini',
                prefixIcon: Icons.storefront_outlined,
                maxLength: 100,
                onChanged: (_) {
                  if (!_useCustomLocation) {
                    setState(() => _useCustomLocation = true);
                  }
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _customMapsLinkController,
                labelText: 'Link Google Maps / Koordinat',
                hintText: 'Tempel link, atau koordinat: -6.97,107.63',
                prefixIcon: Icons.link_rounded,
                maxLength: 500,
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Ambil Lokasi',
                icon: Icons.my_location_rounded,
                isLoading: _isFetchingLocation,
                onPressed: () => _fetchCustomLocation(),
              ),
              const SizedBox(height: 12),

              // Petunjuk: peta sekarang interaktif, bisa di-tap untuk titik presisi
              Row(
                children: [
                  Icon(Icons.touch_app_rounded,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ketuk peta untuk menaruh/menggeser titik lokasi presisi',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Peta preview interaktif (tap untuk set titik) ──────
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _activeLocation,
                    initialZoom: 16.0,
                    // Geser & zoom aktif; rotate dimatikan biar peta tetap
                    // menghadap utara. Tap = taruh/geser titik lokasi.
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (_, point) {
                      setState(() {
                        _customCoord = point;
                        _useCustomLocation = true;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _activeLocation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Waktu & Peserta ────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Waktu Mulai
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Waktu Mulai', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dateFormat.format(_startTime),
                                        style: AppTextStyles.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Jam ${timeFormat.format(_startTime)}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Maks Peserta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Maks Peserta', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_rounded, size: 18),
                                onPressed: _maxParticipants > 2
                                    ? () => setState(() => _maxParticipants--)
                                    : null,
                                color: AppColors.primary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Text('$_maxParticipants',
                                  style: AppTextStyles.heading4),
                              IconButton(
                                icon: const Icon(Icons.add_rounded, size: 18),
                                onPressed: _maxParticipants < 10
                                    ? () => setState(() => _maxParticipants++)
                                    : null,
                                color: AppColors.primary,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Batas Join (deadline) ──────────────────────────────
              Text('Batas Join (menit sebelum mulai)',
                  style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      onPressed: _joinDeadlineMinutes > 5
                          ? () => setState(() => _joinDeadlineMinutes -= 5)
                          : null,
                      color: AppColors.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text('$_joinDeadlineMinutes mnt',
                        style: AppTextStyles.heading4),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      onPressed: _joinDeadlineMinutes < 180
                          ? () => setState(() => _joinDeadlineMinutes += 5)
                          : null,
                      color: AppColors.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Tombol Buat ────────────────────────────────────────
              CustomButton(
                text: 'Buat Sesi Makan',
                icon: Icons.restaurant_rounded,
                isLoading: sessionProvider.isLoading,
                onPressed: () => _createSession(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
