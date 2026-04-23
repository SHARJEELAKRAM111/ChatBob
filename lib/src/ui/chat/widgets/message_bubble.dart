import 'package:chatbob/src/imports/core_imports.dart';
import 'package:chatbob/src/imports/packages_imports.dart';
import 'package:chatbob/src/data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2.h,
          bottom: 2.h,
          left: isMe ? 60.w : 0,
          right: isMe ? 0 : 60.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
            bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Content based on message type
            if (message.isImage && message.mediaUrl != null)
              _buildImageContent(cs),

            if (message.isFile) _buildFileContent(cs, tt),

            if (message.isText || (message.text.isNotEmpty && !message.isText))
              Text(
                message.text,
                style: tt.bodyMedium?.copyWith(
                  color: isMe ? cs.onPrimary : cs.onSurface,
                ),
              ),

            SizedBox(height: 4.h),

            // Timestamp
            Text(
              _formatTime(message.timestamp),
              style: tt.labelSmall?.copyWith(
                color: isMe
                    ? cs.onPrimary.withValues(alpha: 0.7)
                    : cs.onSurfaceVariant,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(ColorScheme cs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: GestureDetector(
        onTap: () {
          // Full-screen image viewer
        },
        child: CachedNetworkImage(
          imageUrl: message.mediaUrl!,
          width: 200.w,
          height: 200.h,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 200.w,
            height: 200.h,
            color: cs.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            width: 200.w,
            height: 200.h,
            color: cs.errorContainer,
            child: Icon(Icons.broken_image, color: cs.error),
          ),
        ),
      ),
    );
  }

  Widget _buildFileContent(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isMe
            ? cs.onPrimary.withValues(alpha: 0.15)
            : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file_rounded,
            color: isMe ? cs.onPrimary : cs.primary,
            size: 24.sp,
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              message.fileName ?? 'File',
              style: tt.bodySmall?.copyWith(
                color: isMe ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
