import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/chat_message_model.dart';
import '../../models/session_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/avatar_widget.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatefulWidget {
  final SessionModel session;

  const ChatRoomScreen({super.key, required this.session});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  /// Chat read-only jika sesi dibatalkan, atau sudah melewati 7 hari
  /// setelah sesi diselesaikan.
  bool get _isChatReadOnly {
    final s = widget.session;
    if (s.status == 'canceled') return true;
    final completedAt = s.completedAt;
    if (completedAt == null) return false;
    return completedAt.add(const Duration(days: 7)).isBefore(DateTime.now());
  }

  bool get _isChatExpired {
    final completedAt = widget.session.completedAt;
    if (completedAt == null) return false;
    return completedAt.add(const Duration(days: 7)).isBefore(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // User mungkin udah balik sebelum frame berikutnya — context jadi stale.
      if (!mounted) return;
      final chatProvider = context.read<ChatProvider>();
      final auth = context.read<AuthProvider>();
      final currentUserId = auth.currentUser?.uid ?? '';
      if (currentUserId.isNotEmpty) {
        chatProvider.markAllAsRead(
          sessionId: widget.session.sessionId,
          userId: currentUserId,
        );
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Kirim pesan via ChatProvider (Widget -> Provider -> Service).
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    _messageController.clear();

    try {
      await context.read<ChatProvider>().sendMessage(
        sessionId: widget.session.sessionId,
        senderId: currentUser.uid,
        senderName: currentUser.name,
        senderPhotoUrl: currentUser.photoUrl,
        text: text,
      );
      // Stream auto-update, scroll ke bawah
      Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Tampilkan bottom sheet info sesi (peserta, waktu, lokasi).
  /// Data diambil dari widget.session yang sudah di-pass dari layar sebelumnya.
  void _showSessionInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SessionInfoSheet(session: widget.session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restaurant_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session.title,
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.session.currentParticipants} peserta',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 22),
            onPressed: _showSessionInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner chat kadaluarsa / dibatalkan
          if (_isChatReadOnly)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: _isChatExpired
                  ? AppColors.textTertiary.withValues(alpha: 0.15)
                  : AppColors.error.withValues(alpha: 0.12),
              child: Row(
                children: [
                  Icon(
                    _isChatExpired
                        ? Icons.lock_clock_outlined
                        : Icons.cancel_outlined,
                    size: 16,
                    color: _isChatExpired
                        ? AppColors.textTertiary
                        : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isChatExpired
                          ? 'Masa chat telah berakhir (lebih dari 7 hari). Pesan tidak bisa dikirim.'
                          : 'Sesi ini dibatalkan. Pesan tidak bisa dikirim.',
                      style: AppTextStyles.caption.copyWith(
                        color: _isChatExpired
                            ? AppColors.textTertiary
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Messages — StreamBuilder untuk realtime (Section 11.1)
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: chatProvider.streamMessages(widget.session.sessionId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final messages = snapshot.data ?? [];
                final hasUnreadMessages = currentUserId.isNotEmpty &&
                    messages.any((message) =>
                        message.senderId != currentUserId &&
                        !message.readBy.contains(currentUserId));
                if (hasUnreadMessages) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    context.read<ChatProvider>().markAllAsRead(
                          sessionId: widget.session.sessionId,
                          userId: currentUserId,
                        );
                  });
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: AppColors.textTertiary
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Mulai percakapan!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll saat pesan baru masuk
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    final isSystem = message.type == 'system';
                    final showAvatar = index == 0 ||
                        messages[index - 1].senderId !=
                            message.senderId;
                    final timeFormat = DateFormat('HH:mm');

                    // Pesan system ditampilkan di tengah
                    if (isSystem) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message.text,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        top: showAvatar ? 12 : 2,
                        bottom: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe && showAvatar)
                            AvatarWidget(
                              name: message.senderName,
                              size: 28,
                            )
                          else if (!isMe)
                            const SizedBox(width: 28),
                          if (!isMe) const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (!isMe && showAvatar)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      message.senderName,
                                      style: AppTextStyles.caption
                                          .copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppColors.primary
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          const Radius.circular(16),
                                      topRight:
                                          const Radius.circular(16),
                                      bottomLeft: Radius.circular(
                                          isMe ? 16 : 4),
                                      bottomRight: Radius.circular(
                                          isMe ? 4 : 16),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        message.text,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                          color: isMe
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        timeFormat
                                            .format(message.sentAt),
                                        style: AppTextStyles.caption
                                            .copyWith(
                                          color: isMe
                                              ? Colors.white70
                                              : AppColors.textTertiary,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input area — hidden saat chat read-only
          if (!_isChatReadOnly)
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              border: Border(
                top: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.textTertiary),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet yang menampilkan info lengkap sesi: judul, status, deskripsi,
/// lokasi, waktu, host, dan list peserta. Tinggi fixed ~70% layar.
class _SessionInfoSheet extends StatelessWidget {
  final SessionModel session;

  const _SessionInfoSheet({required this.session});

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.success;
      case 'ongoing':
        return AppColors.info;
      case 'completed':
        return AppColors.textTertiary;
      case 'canceled':
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.lock_open_rounded;
      case 'ongoing':
        return Icons.restaurant_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'canceled':
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _statusText(String status) {
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
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final statusColor = _statusColor(session.status);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header row: title + close button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
            child: Row(
              children: [
                Text(
                  'Info Sesi',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.5),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title sesi
                  Text(
                    session.title,
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(session.status),
                          size: 13,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _statusText(session.status),
                          style: AppTextStyles.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Deskripsi (kalau ada)
                  if (session.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      session.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // === Section: Lokasi ===
                  _SectionLabel(text: 'Lokasi'),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.restaurant_menu_rounded,
                    text: session.locationName,
                    isPrimary: true,
                  ),
                  if (session.locationAddress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.location_on_rounded,
                      text: session.locationAddress,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // === Section: Waktu ===
                  _SectionLabel(text: 'Waktu'),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    text: dateFormat.format(session.scheduledAt),
                    isPrimary: true,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    text: timeFormat.format(session.scheduledAt),
                  ),

                  const SizedBox(height: 24),

                  // === Section: Host ===
                  _SectionLabel(text: 'Host'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      AvatarWidget(
                        name: session.hostName,
                        photoUrl: session.hostPhotoUrl.isEmpty
                            ? null
                            : session.hostPhotoUrl,
                        size: 40,
                        showBorder: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.hostName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pembuat sesi',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // === Section: Peserta ===
                  Row(
                    children: [
                      _SectionLabel(text: 'Peserta'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${session.currentParticipants}/${session.maxParticipants}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...session.participantIds.map((id) {
                    final user = userProvider.getUserById(id);
                    final isHost = id == session.hostId;
                    final name = user?.name ?? 'Peserta';
                    final photoUrl = user?.photoUrl ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          AvatarWidget(
                            name: name,
                            photoUrl: photoUrl.isEmpty ? null : photoUrl,
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isHost)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Host',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isPrimary;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isPrimary ? AppColors.primary : AppColors.textTertiary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isPrimary
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isPrimary ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
