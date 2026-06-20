import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/session_model.dart';
import '../../providers/session_provider.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.read<SessionProvider>();

    return StreamBuilder<List<SessionModel>>(
      stream: sessionProvider.streamAllSessions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Terjadi kesalahan: ${snapshot.error}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          );
        }

        final sessions = snapshot.data ?? [];

        if (sessions.isEmpty) {
          return Center(
            child: Text(
              'Belum ada sesi sama sekali',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          );
        }

        final timeFormat = DateFormat('dd MMM yyyy • HH:mm');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getStatusColor(session.status)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: _getStatusColor(session.status),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title,
                              style: AppTextStyles.heading4,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              session.locationName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(session.status)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.border, height: 1),
                  ),
                  Row(
                    children: [
                      Icon(Icons.person_rounded,
                          size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Host: ${session.hostName}',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          timeFormat.format(session.scheduledAt),
                          style: AppTextStyles.caption,
                        ),
                      ),
                      Icon(Icons.group_rounded,
                          size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        '${session.currentParticipants}/${session.maxParticipants}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
