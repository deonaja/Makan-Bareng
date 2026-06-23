import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/chat_message_model.dart';
import '../../models/session_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/preferences_service.dart';
import 'chat_room_screen.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  Set<String> _hiddenChatIds = {};
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _currentTabIndex = 0;
  late final TabController _tabController;

  static const _activeStatuses = {'open', 'full', 'ongoing'};
  static const _archivedStatuses = {'completed', 'canceled'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_tabController.index != _currentTabIndex) {
          setState(() => _currentTabIndex = _tabController.index);
        }
      });
    _loadHiddenChats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHiddenChats() async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;
    final ids = await PreferencesService().getHiddenChatIds(uid);
    if (mounted) setState(() => _hiddenChatIds = ids);
  }

  Future<void> _hideChatSession(String sessionId) async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;
    await PreferencesService().hideChatSession(uid, sessionId);
    if (mounted) {
      setState(() => _hiddenChatIds = {..._hiddenChatIds, sessionId});
    }
  }

  Future<void> _hideAllArchived(List<SessionModel> archivedSessions) async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;
    final ids = archivedSessions.map((s) => s.sessionId).toList();
    await PreferencesService().hideMultipleChatSessions(uid, ids);
    if (mounted) {
      setState(() => _hiddenChatIds = {..._hiddenChatIds, ...ids});
    }
  }

  bool _isExpired(SessionModel session) {
    if (session.completedAt == null) return false;
    return session.completedAt!.add(const Duration(days: 7)).isBefore(DateTime.now());
  }

  List<SessionModel> _filterSessions(List<SessionModel> sessions, Set<String> statuses) {
    final query = _searchController.text.toLowerCase();
    return sessions.where((s) {
      if (!statuses.contains(s.status)) return false;
      if (_hiddenChatIds.contains(s.sessionId)) return false;
      if (query.isEmpty) return true;
      return s.title.toLowerCase().contains(query) ||
          s.locationName.toLowerCase().contains(query);
    }).toList();
  }

  void _showHideBottomSheet(BuildContext context, String sessionId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hapus Chat',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chat akan dihapus dari daftarmu',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _hideChatSession(sessionId);
                    },
                    child: Text('Hapus', style: AppTextStyles.buttonSmall),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Batal',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
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

  PreferredSizeWidget _buildAppBar(
      List<SessionModel> archivedSessions, String currentUserId) {
    if (_isSearching) {
      return AppBar(
        backgroundColor: AppColors.backgroundLight,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Cari chat...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            border: InputBorder.none,
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Arsip'),
          ],
        ),
      );
    }

    return AppBar(
      title: const Text('Chat'),
      automaticallyImplyLeading: false,
      actions: [
        if (_currentTabIndex == 1 && archivedSessions.isNotEmpty)
          TextButton(
            onPressed: () => _hideAllArchived(archivedSessions),
            child: Text(
              'Hapus Semua Arsip',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => setState(() => _isSearching = true),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Aktif'),
          Tab(text: 'Arsip'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
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
            message,
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gabung sesi makan untuk mulai chat',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(
    List<SessionModel> sessions,
    String currentUserId, {
    bool isArchived = false,
  }) {
    if (sessions.isEmpty) {
      return _buildEmptyState(
        isArchived ? 'Tidak ada arsip' : 'Belum ada chat',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final expired = isArchived && _isExpired(session);

        return _ChatTileStream(
          key: ValueKey(session.sessionId),
          sessionId: session.sessionId,
          sessionTitle: session.title,
          restaurantName: session.locationName,
          participantCount: session.currentParticipants,
          currentUserId: currentUserId,
          isArchived: isArchived,
          isExpired: expired,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(session: session),
              ),
            );
          },
          onLongPress: () => _showHideBottomSheet(context, session.sessionId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final currentUserId = auth.currentUser?.uid ?? '';

    final userSessions = sessionProvider.userSessions;

    final activeSessions = _filterSessions(userSessions, _activeStatuses);
    final archivedSessions = _filterSessions(userSessions, _archivedStatuses);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(archivedSessions, currentUserId),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(activeSessions, currentUserId, isArchived: false),
          _buildChatList(archivedSessions, currentUserId, isArchived: true),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ChatTileStream
// ---------------------------------------------------------------------------

class _ChatTileStream extends StatelessWidget {
  final String sessionId;
  final String sessionTitle;
  final String restaurantName;
  final int participantCount;
  final String currentUserId;
  final bool isArchived;
  final bool isExpired;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ChatTileStream({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
    required this.restaurantName,
    required this.participantCount,
    required this.currentUserId,
    required this.isArchived,
    required this.isExpired,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();

    return StreamBuilder<ChatMessageModel?>(
      stream: chatProvider.streamLastMessage(sessionId),
      builder: (context, lastMsgSnapshot) {
        return StreamBuilder<int>(
          stream: chatProvider.streamUnreadCount(sessionId, currentUserId),
          builder: (context, unreadSnapshot) {
            final lastMessage = lastMsgSnapshot.data;
            final unreadCount = unreadSnapshot.data ?? 0;
            final timeFormat = DateFormat('HH:mm');

            return _ChatTile(
              sessionTitle: sessionTitle,
              restaurantName: restaurantName,
              lastMessage: lastMessage?.text ?? 'Belum ada pesan',
              lastMessageSender: lastMessage != null &&
                      lastMessage.type != 'system'
                  ? lastMessage.senderName
                  : '',
              lastMessageTime: lastMessage != null
                  ? timeFormat.format(lastMessage.sentAt)
                  : '',
              unreadCount: unreadCount,
              participantCount: participantCount,
              isArchived: isArchived,
              isExpired: isExpired,
              onTap: onTap,
              onLongPress: onLongPress,
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _ChatTile
// ---------------------------------------------------------------------------

class _ChatTile extends StatelessWidget {
  final String sessionTitle;
  final String restaurantName;
  final String lastMessage;
  final String lastMessageSender;
  final String lastMessageTime;
  final int unreadCount;
  final int participantCount;
  final bool isArchived;
  final bool isExpired;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ChatTile({
    required this.sessionTitle,
    required this.restaurantName,
    required this.lastMessage,
    required this.lastMessageSender,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.participantCount,
    required this.isArchived,
    required this.isExpired,
    required this.onTap,
    required this.onLongPress,
  });

  Widget _buildStatusChip() {
    if (!isArchived) return const SizedBox.shrink();
    if (isExpired) {
      return Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Text(
          'Kadaluarsa',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Arsip',
        style: AppTextStyles.labelSmall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimmed = isExpired;

    return Opacity(
      opacity: dimmed ? 0.55 : 1.0,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // Group avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: isArchived
                      ? const LinearGradient(
                          colors: [AppColors.surfaceLight, AppColors.surface],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isArchived
                      ? null
                      : [
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
                    Icon(
                      Icons.restaurant_rounded,
                      color: isArchived
                          ? AppColors.textTertiary
                          : Colors.white,
                      size: 20,
                    ),
                    Text(
                      '$participantCount',
                      style: TextStyle(
                        color: isArchived
                            ? AppColors.textTertiary
                            : Colors.white,
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
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  sessionTitle,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    fontWeight: unreadCount > 0
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isArchived
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildStatusChip(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lastMessageTime,
                          style: AppTextStyles.caption.copyWith(
                            color: unreadCount > 0 && !isArchived
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
                              color: unreadCount > 0 && !isArchived
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0 && !isArchived)
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
      ),
    );
  }
}
