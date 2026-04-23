import 'package:chatbob/src/imports/core_imports.dart';
import 'package:chatbob/src/imports/packages_imports.dart';
import 'package:chatbob/src/data/models/chat_model.dart';
import 'package:chatbob/src/ui/auth/providers/session_provider.dart';
import 'package:chatbob/src/ui/chat/providers/chat_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initChats();
  }

  void _initChats() {
    final session = context.read<SessionProvider>();
    if (session.user != null) {
      context.read<ChatProvider>().listenToChats(session.user!.id);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final session = context.watch<SessionProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final user = session.user;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'ChatBob',
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.primary,
            fontSize: 22.sp,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: cs.onSurface),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            child: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: cs.primaryContainer,
                backgroundImage:
                    user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                    ? Icon(Icons.person,
                        size: 20.sp, color: cs.onPrimaryContainer)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: chatProvider.chats.isEmpty
          ? _buildEmptyState(cs, tt)
          : _buildChatList(chatProvider, user?.id ?? '', cs, tt),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.contacts),
        backgroundColor: cs.primary,
        child: Icon(Icons.chat_rounded, color: cs.onPrimary),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48.sp,
              color: cs.primary,
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),
          Text(
            'No conversations yet',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'Tap the button below to start chatting',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(ChatProvider chatProvider, String currentUserId,
      ColorScheme cs, TextTheme tt) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
      itemCount: chatProvider.chats.length,
      itemBuilder: (context, index) {
        final chat = chatProvider.chats[index];
        return _ChatTile(
          chat: chat,
          currentUserId: currentUserId,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.chat,
              arguments: {
                'chatId': chat.id,
                'otherUserId': chat.otherUserId(currentUserId),
                'otherUserName': chat.otherUserName(currentUserId),
                'otherUserPhoto': chat.otherUserPhoto(currentUserId),
              },
            );
          },
        );
      },
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final name = chat.otherUserName(currentUserId);
    final photo = chat.otherUserPhoto(currentUserId);
    final unread = chat.unreadFor(currentUserId);
    final lastMsg = chat.lastMessage ?? '';
    final isOtherTyping = chat.isTyping(chat.otherUserId(currentUserId));

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26.r,
              backgroundColor: cs.primaryContainer,
              backgroundImage: photo != null && photo.isNotEmpty
                  ? NetworkImage(photo)
                  : null,
              child: photo == null || photo.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: tt.titleMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: tt.titleSmall?.copyWith(
                            fontWeight:
                                unread > 0 ? FontWeight.w700 : FontWeight.w500,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.lastMessageTime != null)
                        Text(
                          _formatTime(chat.lastMessageTime!),
                          style: tt.labelSmall?.copyWith(
                            color:
                                unread > 0 ? cs.primary : cs.onSurfaceVariant,
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: isOtherTyping
                            ? Text(
                                'typing...',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.primary,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : Text(
                                lastMsg,
                                style: tt.bodySmall?.copyWith(
                                  color: unread > 0
                                      ? cs.onSurface
                                      : cs.onSurfaceVariant,
                                  fontWeight: unread > 0
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      if (unread > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
