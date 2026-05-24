// lib/screens/rating/rating_screen.dart
// Owner: Revandi
// Ref: SPEC Section 8.5 — review_service dipakai langsung dari widget (no Provider)
//      SPEC Section 14.3 — Update RatingScreen biar submit ke Firestore via ReviewService

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/session_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/review_service.dart';
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
  final Map<String, bool> _alreadyReviewed = {}; // track siapa yang sudah di-review
  bool _isSubmitting = false;
  bool _isCheckingStatus = true;

  // Ref: SPEC Section 8.5 — pakai service langsung, bukan lewat provider
  final ReviewService _reviewService = ReviewService();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.currentUser?.uid ?? '';

    for (final userId in widget.session.participantIds) {
      if (userId != currentUserId) {
        _ratings[userId] = 4.0;
        _commentControllers[userId] = TextEditingController();
        _alreadyReviewed[userId] = false;
      }
    }

    _checkExistingReviews(currentUserId);
  }

  /// Cek review yang sudah pernah dikirim agar tidak double rating.
  Future<void> _checkExistingReviews(String currentUserId) async {
    for (final userId in _alreadyReviewed.keys) {
      try {
        final reviewed = await _reviewService.hasReviewed(
          reviewerId: currentUserId,
          revieweeId: userId,
          sessionId: widget.session.sessionId,
        );
        if (mounted) {
          setState(() {
            _alreadyReviewed[userId] = reviewed;
          });
        }
      } catch (_) {
        // Kalau gagal cek, asumsikan belum direview — akan di-handle saat submit
      }
    }
    if (mounted) {
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Submit semua rating ke Firestore via ReviewService.
  /// Ref: SPEC Section 8.5 contoh pakai service langsung dari widget.
  Future<void> _submitRatings() async {
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    // Pastikan ada setidaknya satu peserta yang belum direview
    final pendingReviews = _alreadyReviewed.entries
        .where((e) => !e.value)
        .map((e) => e.key)
        .toList();

    if (pendingReviews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua peserta sudah kamu beri rating sebelumnya'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
      return;
    }

    setState(() => _isSubmitting = true);

    int berhasil = 0;
    final List<String> gagal = [];

    for (final revieweeId in pendingReviews) {
      final revieweeUser = userProvider.getUserById(revieweeId);
      try {
        await _reviewService.submitReview(
          sessionId: widget.session.sessionId,
          sessionTitle: widget.session.title,
          reviewerId: currentUser.uid,
          reviewerName: currentUser.name,
          reviewerPhotoUrl: currentUser.photoUrl,
          revieweeId: revieweeId,
          revieweeName: revieweeUser?.name ?? 'Pengguna',
          rating: _ratings[revieweeId] ?? 4.0,
          comment: _commentControllers[revieweeId]?.text.trim() ?? '',
        );
        berhasil++;
      } catch (e) {
        gagal.add(revieweeUser?.name ?? revieweeId);
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (gagal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rating berhasil dikirim! ⭐ ($berhasil peserta)'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      // Sebagian berhasil, sebagian gagal — tunjukkan detail
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$berhasil rating terkirim. Gagal untuk: ${gagal.join(', ')}',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
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
      body: _isCheckingStatus
          ? const Center(child: CircularProgressIndicator())
          : Column(
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

          // Participant rating cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: otherParticipants.length,
              itemBuilder: (context, index) {
                final userId = otherParticipants[index];
                final user = userProvider.getUserById(userId);
                final sudahDireview = _alreadyReviewed[userId] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: sudahDireview
                        ? AppColors.surface.withValues(alpha: 0.5)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: sudahDireview
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.border,
                    ),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Unknown',
                                  style: AppTextStyles.labelLarge,
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star_rounded,
                                        size: 14, color: AppColors.accent),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${user?.averageRating.toStringAsFixed(1) ?? '0.0'} avg',
                                      style: AppTextStyles.caption
                                          .copyWith(color: AppColors.accent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Badge "Sudah direview"
                          if (sudahDireview)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.success.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                '✓ Sudah',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Tampilkan form rating hanya kalau belum direview
                      if (!sudahDireview) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: RatingBar.builder(
                            initialRating: _ratings[userId] ?? 4.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 36,
                            itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star_rounded,
                              color: AppColors.accent,
                            ),
                            unratedColor: AppColors.surfaceLight,
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
                            style: AppTextStyles.heading4
                                .copyWith(color: AppColors.accent),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentControllers[userId],
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textPrimary),
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Komentar singkat (opsional)',
                            hintStyle: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textTertiary),
                            filled: true,
                            fillColor: AppColors.backgroundLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: AppColors.primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Text(
                          'Kamu sudah memberikan rating untuk peserta ini.',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Submit button dengan loading state
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            child: CustomButton(
              text: 'Kirim Rating ⭐',
              isLoading: _isSubmitting,
              onPressed: () { _submitRatings(); },
            ),
          ),
        ],
      ),
    );
  }
}