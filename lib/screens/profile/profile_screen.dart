import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../auth/login_screen.dart';
import '../session/session_detail_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final user = auth.currentUser;

    if (user == null) return const SizedBox();

    final createdSessions = sessionProvider.getCreatedByUser(user.uid);
    final joinedSessions = sessionProvider.getJoinedByUser(user.uid);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            title: Text('Profile', style: AppTextStyles.heading3),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded, size: 22),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Avatar & basic info
                  AvatarWidget(
                    name: user.name,
                    size: 88,
                    showBorder: true,
                  ),
                  const SizedBox(height: 16),
                  Text(user.name, style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      user.bio,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Rating
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            color: AppColors.accent, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          user.averageRating.toStringAsFixed(1),
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'rating',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      _StatCard(
                        value: '${user.sessionsCreated + user.sessionsJoined}',
                        label: 'Total Sesi',
                        icon: Icons.restaurant_rounded,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        value: '${user.sessionsCreated}',
                        label: 'Dibuat',
                        icon: Icons.add_circle_outline_rounded,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        value: '${user.sessionsJoined}',
                        label: 'Diikuti',
                        icon: Icons.group_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Food preferences
                  if (user.foodPreferences.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preferensi Makanan',
                              style: AppTextStyles.labelLarge),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: user.foodPreferences.map((pref) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  pref,
                                  style:
                                      AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Menu items
                  _MenuItem(
                    icon: Icons.edit_rounded,
                    title: 'Edit Profile',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.history_rounded,
                    title: 'Riwayat Sesi',
                    subtitle:
                        '${createdSessions.length + joinedSessions.length} sesi',
                    onTap: () {
                      _showSessionHistory(
                          context, createdSessions, joinedSessions);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifikasi',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.map_outlined,
                    title: 'Perbaiki Lokasi Sesi',
                    subtitle: 'Perbaiki sesi lama yang lokasinya salah di peta',
                    onTap: () => _runLocationMigration(context, user.uid),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    isDestructive: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: Text('Keluar?',
                              style: AppTextStyles.heading4),
                          content: Text(
                            'Apakah kamu yakin ingin keluar dari MakanBareng?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                'Batal',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                auth.logout();
                                Navigator.of(context)
                                    .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: Text(
                                'Keluar',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'MakanBareng v1.0.0',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runLocationMigration(BuildContext context, String uid) async {
    // Konfirmasi dulu
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Perbaiki Lokasi?', style: AppTextStyles.heading4),
        content: Text(
          'Sesi yang kamu buat dengan lokasi salah (titik di danau) '
          'akan diperbaiki ke lokasi resto yang sesuai.\n\n'
          'Proses ini hanya memengaruhi sesi milikmu.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Perbaiki',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final sessionProvider = context.read<SessionProvider>();
    final result = await sessionProvider.migrateDefaultLocations(
      hostId: uid,
      restaurants: MockData.restaurants,
    );

    if (!context.mounted) return;

    final fixed = result['fixed'] ?? 0;
    final skipped = result['skipped'] ?? 0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fixed > 0
              ? '✅ $fixed sesi berhasil diperbaiki, $skipped sudah benar'
              : 'Semua sesi lokasinya sudah benar ($skipped sesi)',
        ),
        backgroundColor: fixed > 0 ? AppColors.success : AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSessionHistory(BuildContext context, List createdSessions,
      List joinedSessions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
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
                    padding: const EdgeInsets.all(20),
                    child: Text('Riwayat Sesi',
                        style: AppTextStyles.heading3),
                  ),
                  TabBar(
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textTertiary,
                    tabs: [
                      Tab(text: 'Dibuat (${createdSessions.length})'),
                      Tab(text: 'Diikuti (${joinedSessions.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSessionList(
                            context, createdSessions, scrollController),
                        _buildSessionList(
                            context, joinedSessions, scrollController),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSessionList(BuildContext context, List sessions,
      ScrollController scrollController) {
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          'Belum ada sesi',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    final timeFormat = DateFormat('dd MMM • HH:mm');

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SessionDetailScreen(session: session),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getStatusColor(session.status)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: _getStatusColor(session.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${session.locationName} • ${timeFormat.format(session.scheduledAt)}',
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
                    color: _getStatusColor(session.status)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(session.status),
                    style: AppTextStyles.caption.copyWith(
                      color: _getStatusColor(session.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.heading3),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isDestructive
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDestructive
                              ? AppColors.error
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(subtitle!, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
