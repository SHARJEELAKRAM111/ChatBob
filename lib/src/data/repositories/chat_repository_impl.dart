import 'dart:async';
import 'package:chatbob/src/data/models/chat_model.dart';
import 'package:chatbob/src/data/models/message_model.dart';
import 'package:chatbob/src/data/models/user_model.dart';
import 'package:chatbob/src/data/repositories/chat_repository.dart';
import 'package:chatbob/src/services/realtime_db_service.dart';
import 'package:chatbob/src/utils/utils.dart';

class ChatRepositoryImpl implements ChatRepository {
  final RealtimeDbService _db = RealtimeDbService.instance;

  /// Generate a consistent chat ID for two users (alphabetical order).
  String _generateChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  @override
  FutureEither<ChatModel> getOrCreateChat({
    required AppUser currentUser,
    required AppUser otherUser,
  }) async {
    return runTask(() async {
      final chatId = _generateChatId(currentUser.id, otherUser.id);

      // Helper: get display name (never empty)
      String displayName(AppUser u) =>
          (u.name != null && u.name!.isNotEmpty) ? u.name! : u.email;

      // Check if chat already exists
      final snapshot = await _db.read('chats/$chatId');
      if (snapshot.exists && snapshot.value != null) {
        // Refresh participant names & photos with latest data
        await _db.update('chats/$chatId', {
          'participantNames/${currentUser.id}': displayName(currentUser),
          'participantNames/${otherUser.id}': displayName(otherUser),
          'participantPhotos/${currentUser.id}': currentUser.photoUrl,
          'participantPhotos/${otherUser.id}': otherUser.photoUrl,
        });

        final data = Map<String, dynamic>.from(snapshot.value as Map);
        // Return with refreshed names
        data['participantNames'] = {
          currentUser.id: displayName(currentUser),
          otherUser.id: displayName(otherUser),
        };
        return ChatModel.fromMap(data, chatId: chatId);
      }

      // Create new chat
      final now = DateTime.now().millisecondsSinceEpoch;
      final chat = ChatModel(
        id: chatId,
        participants: {
          currentUser.id: true,
          otherUser.id: true,
        },
        participantNames: {
          currentUser.id: displayName(currentUser),
          otherUser.id: displayName(otherUser),
        },
        participantPhotos: {
          currentUser.id: currentUser.photoUrl,
          otherUser.id: otherUser.photoUrl,
        },
        unreadCount: {
          currentUser.id: 0,
          otherUser.id: 0,
        },
        typing: {
          currentUser.id: false,
          otherUser.id: false,
        },
        createdAt: now,
      );

      await _db.write('chats/$chatId', chat.toMap());

      // Add chat reference to both users' chat lists
      await _db.write('userChats/${currentUser.id}/$chatId', true);
      await _db.write('userChats/${otherUser.id}/$chatId', true);

      return chat;
    });
  }

  @override
  FutureEither<void> sendMessage(MessageModel message) async {
    return runTask(() async {
      final chatId = message.chatId;

      // Write message
      await _db.write('messages/$chatId/${message.id}', message.toMap());

      // Update chat metadata
      await _db.update('chats/$chatId', {
        'lastMessage': message.isText ? message.text : (message.isImage ? '📷 Photo' : '📎 File'),
        'lastMessageTime': message.timestamp,
        'lastMessageSenderId': message.senderId,
      });

      // Increment unread count for participants other than sender
      final chatSnapshot = await _db.read('chats/$chatId/participants');
      if (chatSnapshot.exists && chatSnapshot.value != null) {
        final participants = Map<String, dynamic>.from(chatSnapshot.value as Map);
        for (final participantId in participants.keys) {
          if (participantId != message.senderId) {
            final countSnapshot = await _db.read('chats/$chatId/unreadCount/$participantId');
            final currentCount = (countSnapshot.value as int?) ?? 0;
            await _db.write('chats/$chatId/unreadCount/$participantId', currentCount + 1);
          }
        }
      }
    });
  }

  @override
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _db.stream('messages/$chatId').map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <MessageModel>[];
      }

      final messagesMap = Map<String, dynamic>.from(event.snapshot.value as Map);
      final messages = <MessageModel>[];

      for (final entry in messagesMap.entries) {
        final data = Map<String, dynamic>.from(entry.value as Map);
        messages.add(MessageModel.fromMap(data, messageId: entry.key));
      }

      // Sort by timestamp ascending
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  @override
  Stream<List<ChatModel>> streamUserChats(String userId) {
    // Listen to the user's chat index
    return _db.stream('userChats/$userId').asyncMap((event) async {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <ChatModel>[];
      }

      final chatIds = Map<String, dynamic>.from(event.snapshot.value as Map);
      final chats = <ChatModel>[];

      for (final chatId in chatIds.keys) {
        final chatSnapshot = await _db.read('chats/$chatId');
        if (chatSnapshot.exists && chatSnapshot.value != null) {
          final data = Map<String, dynamic>.from(chatSnapshot.value as Map);
          chats.add(ChatModel.fromMap(data, chatId: chatId));
        }
      }

      // Sort by last message time (most recent first)
      chats.sort((a, b) {
        final aTime = a.lastMessageTime ?? a.createdAt;
        final bTime = b.lastMessageTime ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

      return chats;
    });
  }

  @override
  FutureEither<void> markAsRead({required String chatId, required String userId}) async {
    return runTask(() async {
      await _db.write('chats/$chatId/unreadCount/$userId', 0);
    });
  }

  @override
  FutureEither<void> setTyping({required String chatId, required String userId, required bool isTyping}) async {
    return runTask(() async {
      await _db.write('chats/$chatId/typing/$userId', isTyping);
    });
  }

  @override
  Stream<bool> streamTypingStatus({required String chatId, required String userId}) {
    return _db.stream('chats/$chatId/typing/$userId').map((event) {
      return event.snapshot.value == true;
    });
  }

  @override
  FutureEither<void> deleteMessage({required String chatId, required String messageId}) async {
    return runTask(() async {
      await _db.delete('messages/$chatId/$messageId');
    });
  }
}
