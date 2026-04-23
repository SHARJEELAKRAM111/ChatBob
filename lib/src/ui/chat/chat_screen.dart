import 'package:chatbob/src/imports/core_imports.dart';
import 'package:chatbob/src/imports/packages_imports.dart';
import 'package:chatbob/src/data/models/message_model.dart';
import 'package:chatbob/src/ui/auth/providers/session_provider.dart';
import 'package:chatbob/src/ui/chat/providers/chat_provider.dart';
import 'package:chatbob/src/ui/chat/widgets/message_bubble.dart';
import 'package:chatbob/src/ui/chat/widgets/chat_input_bar.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late String _currentUserId;
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<SessionProvider>().user?.id ?? '';
    _chatProvider = context.read<ChatProvider>();
    
    // Open chat: start listening to messages
    _chatProvider.openChat(
      chatId: widget.chatId,
      currentUserId: _currentUserId,
      otherUserId: widget.otherUserId,
    );
  }

  @override
  void dispose() {
    _chatProvider.closeChat(
      chatId: widget.chatId,
      currentUserId: _currentUserId,
    );
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;

    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Mark as read when viewing
    chatProvider.markAsRead(chatId: widget.chatId, userId: _currentUserId);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: cs.primaryContainer,
              backgroundImage: widget.otherUserPhoto != null && widget.otherUserPhoto!.isNotEmpty
                  ? NetworkImage(widget.otherUserPhoto!)
                  : null,
              child: widget.otherUserPhoto == null || widget.otherUserPhoto!.isEmpty
                  ? Text(
                      widget.otherUserName.isNotEmpty
                          ? widget.otherUserName[0].toUpperCase()
                          : '?',
                      style: tt.titleSmall?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (chatProvider.otherUserTyping)
                    Text(
                      'typing...',
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: cs.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyChat(cs, tt)
                : _buildMessageList(messages, cs),
          ),
          // Upload progress
          if (chatProvider.isUploading)
            LinearProgressIndicator(
              value: chatProvider.uploadProgress,
              backgroundColor: cs.surfaceContainerHighest,
              color: cs.primary,
            ),
          // Input bar
          ChatInputBar(
            chatId: widget.chatId,
            currentUserId: _currentUserId,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.waving_hand_rounded,
            size: 48.sp,
            color: cs.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            'Say hello to ${widget.otherUserName}!',
            style: tt.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<MessageModel> messages, ColorScheme cs) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == _currentUserId;
        final showDate = index == 0 ||
            !_isSameDay(
              messages[index - 1].timestamp,
              message.timestamp,
            );

        return Column(
          children: [
            if (showDate)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _formatDate(message.timestamp),
                    style: context.theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            MessageBubble(
              message: message,
              isMe: isMe,
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(int ts1, int ts2) {
    final d1 = DateTime.fromMillisecondsSinceEpoch(ts1);
    final d2 = DateTime.fromMillisecondsSinceEpoch(ts2);
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
