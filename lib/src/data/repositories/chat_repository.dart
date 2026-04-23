import 'package:chatbob/src/data/models/chat_model.dart';
import 'package:chatbob/src/data/models/message_model.dart';
import 'package:chatbob/src/data/models/user_model.dart';
import 'package:chatbob/src/utils/utils.dart';

abstract class ChatRepository {
  /// Create or get existing 1-on-1 chat between two users.
  FutureEither<ChatModel> getOrCreateChat({
    required AppUser currentUser,
    required AppUser otherUser,
  });

  /// Send a message in a chat.
  FutureEither<void> sendMessage(MessageModel message);

  /// Stream messages for a specific chat (real-time).
  Stream<List<MessageModel>> streamMessages(String chatId);

  /// Stream the chat list for a user (real-time).
  Stream<List<ChatModel>> streamUserChats(String userId);

  /// Mark all messages as read in a chat for a user.
  FutureEither<void> markAsRead({required String chatId, required String userId});

  /// Set typing indicator for a user in a chat.
  FutureEither<void> setTyping({required String chatId, required String userId, required bool isTyping});

  /// Stream typing status of the other user.
  Stream<bool> streamTypingStatus({required String chatId, required String userId});

  /// Delete a message.
  FutureEither<void> deleteMessage({required String chatId, required String messageId});
}
