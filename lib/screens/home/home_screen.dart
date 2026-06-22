import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../session/session_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  static const LatLng _telUCenter = LatLng(-6.9732, 107.6310);
  LatLng _userLocation = _telUCenter;
  bool _showSessionList = false;
  bool _isLocating = false;

  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SessionProvider>().listenActiveSessions();
      _startLocationTracking();
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Mulai tracking lokasi real-time.
  /// - Ambil posisi awal → langsung pindahkan peta
  /// - Subscribe ke stream posisi → update dot biru saat user bergerak
  Future<void> _startLocationTracking() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationSnackBar(
            'GPS tidak aktif. Aktifkan lokasi di pengaturan perangkat.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationSnackBar('Izin lokasi ditolak. Peta menggunakan lokasi default.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showLocationSnackBar(
            'Izin lokasi diblokir. Buka Pengaturan > Izin Aplikasi untuk mengaktifkan.');
        return;
      }

      if (!mounted) return;
      setState(() => _isLocating = true);

      // Posisi awal — langsung pindahkan kamera
      final initial = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!mounted) return;
      final initialLatLng = LatLng(initial.latitude, initial.longitude);
      setState(() {
        _userLocation = initialLatLng;
        _isLocating = false;
      });
      context.read<SessionProvider>()
          .setUserLocation(initial.latitude, initial.longitude);
      _mapController.move(_userLocation, 15.0);

      // Stream posisi — update dot biru saat user bergerak (min 15 m)
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
        ),
      ).listen(
        (pos) {
          if (!mounted) return;
          final updated = LatLng(pos.latitude, pos.longitude);
          setState(() => _userLocation = updated);
          context.read<SessionProvider>()
              .setUserLocation(pos.latitude, pos.longitude);
        },
        onError: (_) {},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLocating = false);
      // Pada emulator, GPS biasanya tidak tersedia — tampilkan info
      if (e.toString().contains('timeout') || e.toString().contains('TimeLimit')) {
        _showLocationSnackBar(
            'Gagal mendapatkan lokasi (timeout). Pastikan GPS aktif atau coba di perangkat nyata.');
      }
      // Error lain: silent fallback ke Tel-U
    }
  }

  void _showLocationSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.location_off_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showFilterSheet() {
    final provider = context.read<SessionProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Urutkan Sesi', style: AppTextStyles.heading4),
            const SizedBox(height: 16),
            _FilterOption(
              label: 'Waktu Terdekat',
              icon: Icons.access_time_rounded,
              selected: provider.sortBy == 'waktu',
              onTap: () {
                provider.setSortBy('waktu');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
            _FilterOption(
              label: 'Jarak Terdekat',
              icon: Icons.near_me_rounded,
              selected: provider.sortBy == 'jarak',
              onTap: () {
                provider.setSortBy('jarak');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    final sessions = sessionProvider.filteredSessions
        .where((s) => s.scheduledAt
            .add(Duration(minutes: s.durationMinutes))
            .isAfter(DateTime.now()))
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 15.0,
              minZoom: 10,
              maxZoom: 18,
              onTap: (tapPosition, point) {
                setState(() => _showSessionList = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.makanbareng.app',
              ),
              // Session markers (filtered)
              MarkerLayer(
                markers: sessions.map((session) {
                  return Marker(
                    point: LatLng(session.locationLatitude, session.locationLongitude),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SessionDetailScreen(session: session),
                          ),
                        );
                      },
                      child: _SessionMarker(session: session),
                    ),
                  );
                }).toList(),
              ),
              // User location marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation,
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.info.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.textTertiary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyMedium,
                      onChanged: (q) =>
                          context.read<SessionProvider>().setSearchQuery(q),
                      decoration: InputDecoration(
                        hintText: 'Cari sesi makan di sekitarmu...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        suffixIcon: sessionProvider.searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  context
                                      .read<SessionProvider>()
                                      .setSearchQuery('');
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.textTertiary,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: sessionProvider.sortBy == 'jarak'
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tombol "My Location" — di kanan, di atas info bar / panel
          Positioned(
            right: 16,
            bottom: _showSessionList ? 348 : 108,
            child: _MapButton(
              icon: _isLocating
                  ? Icons.location_searching_rounded
                  : Icons.my_location_rounded,
              onTap: () {
                if (_isLocating) return;
                _mapController.move(_userLocation, 15.0);
                if (_userLocation == _telUCenter) _startLocationTracking();
              },
            ),
          ),

          // Panel sesi bawah — slide up/down
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: _showSessionList ? 0 : -320,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle + header row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drag handle kecil di atas teks
                              Center(
                                child: Container(
                                  width: 36,
                                  height: 3,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Text(
                                sessionProvider.searchQuery.isNotEmpty
                                    ? 'Hasil Pencarian'
                                    : 'Sesi Makan Aktif',
                                style: AppTextStyles.heading4,
                              ),
                            ],
                          ),
                        ),
                        // Badge count + tombol tutup
                        Row(
                          children: [
                            if (sessions.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${sessions.length}',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 26),
                              color: AppColors.textTertiary,
                              padding: EdgeInsets.zero,
                              onPressed: () =>
                                  setState(() => _showSessionList = false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Konten: list atau empty state
                  if (sessions.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              size: 40,
                              color: AppColors.textTertiary
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              sessionProvider.searchQuery.isNotEmpty
                                  ? 'Tidak ada sesi yang cocok'
                                  : 'Belum ada sesi aktif saat ini',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          return _SessionCard(
                            session: sessions[index],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SessionDetailScreen(
                                    session: sessions[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Info bar bawah — full width, berisi status sesi + tombol expand
          if (!_showSessionList)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: () => setState(() => _showSessionList = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.97),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Dot indikator: hijau jika ada sesi, abu jika kosong
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: sessions.isNotEmpty
                              ? AppColors.success
                              : AppColors.textTertiary,
                          shape: BoxShape.circle,
                          boxShadow: sessions.isNotEmpty
                              ? [
                                  BoxShadow(
                                    color: AppColors.success
                                        .withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sessions.isEmpty
                                  ? 'Belum ada sesi makan aktif'
                                  : '${sessions.length} sesi makan aktif',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: sessions.isEmpty
                                    ? AppColors.textTertiary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (sessions.isNotEmpty)
                              Text(
                                'Tap untuk lihat daftar',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionMarker extends StatelessWidget {
  final SessionModel session;

  const _SessionMarker({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_rounded, color: Colors.white, size: 18),
          Text(
            '${session.currentParticipants}/${session.maxParticipants}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onTap;

  const _SessionCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AvatarWidget(name: session.hostName, size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.hostName,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        timeFormat.format(session.scheduledAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: session.isFull
                        ? AppColors.error.withValues(alpha: 0.15)
                        : AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${session.currentParticipants}/${session.maxParticipants}',
                    style: AppTextStyles.caption.copyWith(
                      color: session.isFull ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              session.title,
              style: AppTextStyles.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    session.locationName,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              session.description,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
