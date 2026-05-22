import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../session/session_detail_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(-6.9732, 107.6310); // Tel-U
  bool _showSessionList = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionProvider>().listenActiveSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    final activeSessions = sessionProvider.activeSessions;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 15.0,
              minZoom: 10,
              maxZoom: 18,
              onTap: (_, _) {
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
              // Session markers
              MarkerLayer(
                markers: activeSessions.map((session) {
                  return Marker(
                    point: LatLng(session.locationLatitude, session.locationLongitude),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                SessionDetailScreen(session: session),
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
                    point: _defaultCenter,
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
                      style: AppTextStyles.bodyMedium,
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
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // My location button
          Positioned(
            right: 16,
            bottom: _showSessionList ? 340 : 100,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    _mapController.move(_defaultCenter, 15.0);
                  },
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: _showSessionList
                      ? Icons.expand_more_rounded
                      : Icons.expand_less_rounded,
                  onTap: () {
                    setState(() => _showSessionList = !_showSessionList);
                  },
                ),
              ],
            ),
          ),

          // Bottom session list
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: _showSessionList ? 0 : -250,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sesi Makan Terdekat',
                          style: AppTextStyles.heading4,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${activeSessions.length} aktif',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: activeSessions.length,
                      itemBuilder: (context, index) {
                        return _SessionCard(
                          session: activeSessions[index],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SessionDetailScreen(
                                  session: activeSessions[index],
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

          // Quick info bar (when session list is hidden)
          if (!_showSessionList)
            Positioned(
              left: 16,
              right: 76,
              bottom: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() => _showSessionList = true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${activeSessions.length} sesi makan aktif di sekitarmu',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_upward_rounded,
                        color: AppColors.primary,
                        size: 18,
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
                      color: session.isFull
                          ? AppColors.error
                          : AppColors.success,
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
                Icon(Icons.location_on_rounded,
                    size: 14, color: AppColors.primary),
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
