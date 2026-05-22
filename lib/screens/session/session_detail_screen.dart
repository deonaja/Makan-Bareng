import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/session_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';
import '../chat/chat_room_screen.dart';
import '../rating/rating_screen.dart';
import 'package:intl/intl.dart';

class SessionDetailScreen extends StatelessWidget {
  final SessionModel session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final userProvider = context.watch<UserProvider>();
    final currentUserId = auth.currentUser?.id ?? '';

    final latestSession =
        sessionProvider.getSessionById(session.sessionId) ?? session;

    final isParticipant = latestSession.participantIds.contains(currentUserId);
    final isCreator = latestSession.hostId == currentUserId;
    final isCompleted = latestSession.status == 'completed';
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Map header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: AppColors.surface.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latestSession.locationLatitude, latestSession.locationLongitude),
                      initialZoom: 16.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
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
                            point: LatLng(latestSession.locationLatitude, latestSession.locationLongitude),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(latestSession.status)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(latestSession.status),
                          style: AppTextStyles.labelMedium.copyWith(
                            color:
                                _getStatusColor(latestSession.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(latestSession.title,
                      style: AppTextStyles.heading2),
                  const SizedBox(height: 8),

                  // Creator info
                  Row(
                    children: [
                      AvatarWidget(
                          name: latestSession.hostName, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'oleh ${latestSession.hostName}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info cards
                  _InfoRow(
                    icon: Icons.restaurant_rounded,
                    label: 'Tempat Makan',
                    value: latestSession.locationName,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on_rounded,
                    label: 'Alamat',
                    value: latestSession.locationAddress,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Waktu',
                    value:
                        '${dateFormat.format(latestSession.scheduledAt)} • ${timeFormat.format(latestSession.scheduledAt)}',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.people_rounded,
                    label: 'Peserta',
                    value:
                        '${latestSession.currentParticipants}/${latestSession.maxParticipants} orang',
                  ),

                  if (latestSession.description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Deskripsi', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    Text(
                      latestSession.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Participants
                  Text('Peserta', style: AppTextStyles.heading4),
                  const SizedBox(height: 12),
                  ...latestSession.participantIds.map((userId) {
                    final user = userProvider.getUserById(userId);
                    final isSessionCreator =
                        userId == latestSession.hostId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSessionCreator
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          AvatarWidget(
                            name: user?.name ?? 'Unknown',
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Unknown',
                                  style: AppTextStyles.labelLarge,
                                ),
                                if (user != null)
                                  Row(
                                    children: [
                                      Icon(Icons.star_rounded,
                                          size: 14,
                                          color: AppColors.accent),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.rating.toStringAsFixed(1),
                                        style: AppTextStyles.caption
                                            .copyWith(
                                          color: AppColors.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          if (isSessionCreator)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Host',
                                style:
                                    AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  // Available seats indicator
                  if (latestSession.availableSeats > 0 &&
                      latestSession.status == 'open') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_seat_rounded,
                              size: 16,
                              color: AppColors.textTertiary),
                          const SizedBox(width: 8),
                          Text(
                            '${latestSession.availableSeats} kursi tersedia',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action buttons
                  if (isParticipant && !isCompleted) ...[
                    CustomButton(
                      text: 'Buka Chat Grup 💬',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ChatRoomScreen(session: latestSession),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (!isCreator)
                      CustomButton(
                        text: 'Keluar dari Sesi',
                        isOutlined: true,
                        onPressed: () {
                          sessionProvider.leaveSession(
                            sessionId: latestSession.sessionId,
                            userId: currentUserId,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    if (isCreator) ...[
                      CustomButton(
                        text: 'Selesaikan Sesi ✅',
                        isOutlined: true,
                        backgroundColor: AppColors.success,
                        textColor: AppColors.success,
                        onPressed: () {
                          sessionProvider.completeSession(latestSession.sessionId);
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Batalkan Sesi',
                        isOutlined: true,
                        backgroundColor: AppColors.error,
                        textColor: AppColors.error,
                        onPressed: () {
                          sessionProvider.cancelSession(latestSession.sessionId);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ] else if (!isParticipant &&
                      !latestSession.isFull &&
                      latestSession.status == 'open') ...[
                    CustomButton(
                      text: 'Gabung Sesi 🙌',
                      onPressed: () {
                        sessionProvider.joinSession(
                            sessionId: latestSession.sessionId,
                            userId: currentUserId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Berhasil bergabung! 🎉'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ] else if (isCompleted && isParticipant) ...[
                    CustomButton(
                      text: 'Beri Rating Peserta ⭐',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                RatingScreen(session: latestSession),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.success;
      case 'full':
        return AppColors.warning;
      case 'ongoing':
        return AppColors.info;
      case 'completed':
        return AppColors.accent;
      case 'canceled':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'open':
        return 'Terbuka';
      case 'full':
        return 'Penuh';
      case 'ongoing':
        return 'Berlangsung';
      case 'completed':
        return 'Selesai';
      case 'canceled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
