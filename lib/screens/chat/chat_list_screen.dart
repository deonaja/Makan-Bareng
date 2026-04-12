import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/session_provider.dart';
import 'chat_room_screen.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final currentUserId = auth.currentUser?.id ?? '';

    // Get sessions where user is participant
    final userSessions = sessionProvider.getSessionsByUser(currentUserId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chat'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: userSessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 72,
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada chat',
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gabung sesi makan untuk mulai chat!',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: userSessions.length,
              itemBuilder: (context, index) {
                final session = userSessions[index];
                final lastMessage =
                    chatProvider.getLastMessage(session.id);
                final unreadCount =
                    chatProvider.getUnreadCount(session.id, currentUserId);
                final timeFormat = DateFormat('HH:mm');

                return _ChatTile(
                  sessionTitle: session.title,
                  restaurantName: session.restaurantName,
                  lastMessage: lastMessage?.message ?? 'Belum ada pesan',
                  lastMessageSender: lastMessage?.senderName ?? '',
                  lastMessageTime: lastMessage != null
                      ? timeFormat.format(lastMessage.timestamp)
                      : '',
                  unreadCount: unreadCount,
                  participantCount: session.currentParticipants,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(session: session),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String sessionTitle;
  final String restaurantName;
  final String lastMessage;
  final String lastMessageSender;
  final String lastMessageTime;
  final int unreadCount;
  final int participantCount;
  final VoidCallback onTap;

  const _ChatTile({
    required this.sessionTitle,
    required this.restaurantName,
    required this.lastMessage,
    required this.lastMessageSender,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.participantCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Group avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_rounded,
                      color: Colors.white, size: 20),
                  Text(
                    '$participantCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          sessionTitle,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        lastMessageTime,
                        style: AppTextStyles.caption.copyWith(
                          color: unreadCount > 0
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    restaurantName,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessageSender.isNotEmpty
                              ? '$lastMessageSender: $lastMessage'
                              : lastMessage,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
