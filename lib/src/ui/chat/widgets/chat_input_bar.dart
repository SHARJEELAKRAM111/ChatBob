import 'dart:io';
import 'package:chatbob/src/imports/core_imports.dart';
import 'package:chatbob/src/imports/packages_imports.dart';
import 'package:chatbob/src/ui/chat/providers/chat_provider.dart';

class ChatInputBar extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatInputBar({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }

      // Update typing indicator
      context.read<ChatProvider>().setTyping(
        chatId: widget.chatId,
        userId: widget.currentUserId,
        isTyping: hasText,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatProvider>().sendTextMessage(
      chatId: widget.chatId,
      senderId: widget.currentUserId,
      text: text,
    );

    _controller.clear();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );

    if (picked == null) return;
    if (!mounted) return;

    context.read<ChatProvider>().sendImageMessage(
      chatId: widget.chatId,
      senderId: widget.currentUserId,
      file: File(picked.path),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;
    if (!mounted) return;

    context.read<ChatProvider>().sendFileMessage(
      chatId: widget.chatId,
      senderId: widget.currentUserId,
      file: File(file.path!),
      fileName: file.name,
    );
  }

  void _showAttachMenu() {
    final cs = context.theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachOption(
                    icon: Icons.photo_rounded,
                    label: 'Photo',
                    color: cs.primary,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                  _AttachOption(
                    icon: Icons.insert_drive_file_rounded,
                    label: 'File',
                    color: cs.tertiary,
                    onTap: () {
                      Navigator.pop(context);
                      _pickFile();
                    },
                  ),
                  _AttachOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: cs.secondary,
                    onTap: () async {
                      Navigator.pop(context);
                      final chatProv = this.context.read<ChatProvider>();
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 70,
                        maxWidth: 1024,
                      );
                      if (picked == null || !mounted) return;
                      chatProv.sendImageMessage(
                        chatId: widget.chatId,
                        senderId: widget.currentUserId,
                        file: File(picked.path),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            IconButton(
              onPressed: _showAttachMenu,
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: cs.onSurfaceVariant,
                size: 26.sp,
              ),
            ),
            // Text field
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 120.h),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _hasText ? _sendMessage : null,
                icon: Icon(
                  Icons.send_rounded,
                  color: _hasText ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.4),
                  size: 26.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final cs = context.theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
