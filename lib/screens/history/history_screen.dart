import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/session_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../session/session_detail_screen.dart';

/// Screen riwayat sesi user.
/// 2 tab: "Aku Buat" (sesi yang user host) dan "Aku Ikut" (sesi yang user join sebagai participant).
///
/// Data source: SessionProvider.userSessions (sudah di-stream di MainNavigation.initState
/// via SessionService.streamUserSessions). Section 14.3 poin 6.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final uid = auth.currentUser?.uid ?? '';

    final created = sessionProvider.getCreatedByUser(uid);
    final joined = sessionProvider.getJoinedByUser(uid);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Riwayat Sesi'),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            labelStyle: AppTextStyles.labelLarge,
            unselectedLabelStyle:
                AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: 'Aku Buat (${created.length})'),
              Tab(text: 'Aku Ikut (${joined.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SessionHistoryList(
              sessions: created,
              emptyIcon: Icons.event_note_outlined,
              emptyTitle: 'Belum ada sesi yang kamu buat',
              emptySubtitle: 'Yuk buat sesi makan pertama!',
            ),
            _SessionHistoryList(
              sessions: joined,
              emptyIcon: Icons.group_outlined,
              emptyTitle: 'Belum ada sesi yang kamu ikuti',
              emptySubtitle: 'Cek Beranda untuk gabung sesi!',
            ),
          ],
        ),
      ),
    );
  }
}

/// List sesi dengan empty state. Pakai pattern Section 11.1.
class _SessionHistoryList extends StatelessWidget {
  final List<SessionModel> sessions;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  const _SessionHistoryList({
    required this.sessions,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emptyIcon,
                size: 72,
                color: AppColors.textTertiary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style:
                    AppTextStyles.heading4.copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: sessions.length,
      itemBuilder: (context, index) => _HistoryCard(session: sessions[index]),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SessionModel session;

  const _HistoryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SessionDetailScreen(session: session),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        session.title,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: session.status),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        session.locationName.isEmpty
                            ? 'Tanpa lokasi'
                            : session.locationName,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formatScheduledAt(session.scheduledAt),
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.people_outline_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${session.currentParticipants}/${session.maxParticipants}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Format ke "Sen, 19 Mei 2026 • 12:00" tanpa butuh initializeDateFormatting.
  String _formatScheduledAt(DateTime dt) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$dayName, ${dt.day} $monthName ${dt.year} • $hh:$mm';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _configFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        config.label,
        style: AppTextStyles.caption.copyWith(
          color: config.color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  _BadgeConfig _configFor(String status) {
    switch (status) {
      case 'open':
        return _BadgeConfig(label: 'Buka', color: AppColors.info);
      case 'full':
        return _BadgeConfig(label: 'Penuh', color: AppColors.warning);
      case 'ongoing':
        return _BadgeConfig(label: 'Berlangsung', color: AppColors.success);
      case 'completed':
        return _BadgeConfig(label: 'Selesai', color: AppColors.textTertiary);
      case 'canceled':
        return _BadgeConfig(label: 'Dibatalkan', color: AppColors.error);
      default:
        return _BadgeConfig(label: '—', color: AppColors.textTertiary);
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color color;

  _BadgeConfig({required this.label, required this.color});
}
