import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/review_model.dart';
import '../../models/session_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';

class RatingScreen extends StatefulWidget {
  final SessionModel session;

  const RatingScreen({super.key, required this.session});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final Map<String, double> _ratings = {};
  final Map<String, TextEditingController> _commentControllers = {};

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.currentUser?.uid ?? '';

    for (final userId in widget.session.participantIds) {
      if (userId != currentUserId) {
        _ratings[userId] = 4.0;
        _commentControllers[userId] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitRatings() {
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final currentUserId = auth.currentUser?.uid ?? '';

    final reviews = <ReviewModel>[];
    for (final entry in _ratings.entries) {
      reviews.add(ReviewModel(
        id: 'review_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
        fromUserId: currentUserId,
        fromUserName: auth.currentUser!.name,
        toUserId: entry.key,
        sessionId: widget.session.sessionId,
        rating: entry.value,
        comment: _commentControllers[entry.key]?.text.trim() ?? '',
        timestamp: DateTime.now(),
      ));
    }

    userProvider.addMultipleReviews(reviews);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Rating berhasil dikirim! ⭐'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.currentUser?.uid ?? '';

    final otherParticipants = widget.session.participantIds
        .where((id) => id != currentUserId)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rating Peserta'),
      ),
      body: Column(
        children: [
          // Session info
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.restaurant_rounded,
                      color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.session.title,
                          style: AppTextStyles.labelLarge),
                      Text(widget.session.locationName,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Berikan penilaian untuk peserta lain',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Participant ratings
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: otherParticipants.length,
              itemBuilder: (context, index) {
                final userId = otherParticipants[index];
                final user = userProvider.getUserById(userId);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                        children: [
                          AvatarWidget(
                            name: user?.name ?? 'Unknown',
                            size: 44,
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
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded,
                                        size: 14,
                                        color: AppColors.accent),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${user?.averageRating.toStringAsFixed(1) ?? '0.0'} avg',
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: RatingBar.builder(
                          initialRating: _ratings[userId] ?? 4.0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 36,
                          itemPadding: const EdgeInsets.symmetric(
                              horizontal: 4),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star_rounded,
                            color: AppColors.accent,
                          ),
                          unratedColor:
                              AppColors.surfaceLight,
                          onRatingUpdate: (rating) {
                            setState(() {
                              _ratings[userId] = rating;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          _ratings[userId]?.toStringAsFixed(1) ?? '4.0',
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _commentControllers[userId],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Komentar singkat (opsional)',
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Submit button
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            child: CustomButton(
              text: 'Kirim Rating ⭐',
              onPressed: _submitRatings,
            ),
          ),
        ],
      ),
    );
  }
}
