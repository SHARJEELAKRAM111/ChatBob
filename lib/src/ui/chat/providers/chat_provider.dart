import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chatbob/src/data/models/chat_model.dart';
import 'package:chatbob/src/data/models/message_model.dart';
import 'package:chatbob/src/data/models/user_model.dart';
import 'package:chatbob/src/data/repositories/chat_repository.dart';
import 'package:chatbob/src/data/repositories/storage_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepo;
  final StorageRepository _storageRepo;

  ChatProvider({
    required ChatRepository chatRepo,
    required StorageRepository storageRepo,
  })  : _chatRepo = chatRepo,
        _storageRepo = storageRepo;

  // ── Chat List State ──
  List<ChatModel> _chats = [];
  List<ChatModel> get chats => _chats;
  StreamSubscription<List<ChatModel>>? _chatsSub;

  // ── Messages State ──
  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;
  StreamSubscription<List<MessageModel>>? _messagesSub;

  // ── Typing State ──
  bool _otherUserTyping = false;
  bool get otherUserTyping => _otherUserTyping;
  StreamSubscription<bool>? _typingSub;

  // ── Loading State ──
  bool _isSending = false;
  bool get isSending => _isSending;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  double _uploadProgress = 0;
  double get uploadProgress => _uploadProgress;

  // ── Current Chat ──
  ChatModel? _currentChat;
  ChatModel? get currentChat => _currentChat;

  /// Start listening to the user's chat list.
  void listenToChats(String userId) {
    _chatsSub?.cancel();
    _chatsSub = _chatRepo.streamUserChats(userId).listen((chats) {
      _chats = chats;
      notifyListeners();
    });
  }

  /// Open a chat: start listening to messages and typing.
  void openChat({
    required String chatId,
    required String currentUserId,
    required String otherUserId,
  }) {
    _messagesSub?.cancel();
    _typingSub?.cancel();

    _messagesSub = _chatRepo.streamMessages(chatId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });

    _typingSub = _chatRepo
        .streamTypingStatus(chatId: chatId, userId: otherUserId)
        .listen((isTyping) {
      _otherUserTyping = isTyping;
      notifyListeners();
    });

    // Mark messages as read
    _chatRepo.markAsRead(chatId: chatId, userId: currentUserId);
  }

  /// Close current chat: stop listening to messages and typing.
  void closeChat({required String chatId, required String currentUserId}) {
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _messages = [];
    _otherUserTyping = false;
    _currentChat = null;

    // Reset typing
    _chatRepo.setTyping(chatId: chatId, userId: currentUserId, isTyping: false);
    notifyListeners();
  }

  /// Get or create a 1-on-1 chat.
  Future<ChatModel?> getOrCreateChat({
    required AppUser currentUser,
    required AppUser otherUser,
  }) async {
    final result = await _chatRepo.getOrCreateChat(
      currentUser: currentUser,
      otherUser: otherUser,
    );
    return result.fold(
      (failure) => null,
      (chat) {
        _currentChat = chat;
        notifyListeners();
        return chat;
      },
    );
  }

  /// Send a text message.
  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    _isSending = true;
    notifyListeners();

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: senderId,
      text: text.trim(),
      type: MessageType.text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _chatRepo.sendMessage(message);

    // Reset typing after sending
    _chatRepo.setTyping(chatId: chatId, userId: senderId, isTyping: false);

    _isSending = false;
    notifyListeners();
  }

  /// Send an image message.
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required File file,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    final uploadResult = await _storageRepo.uploadChatImage(
      chatId: chatId,
      file: file,
      onProgress: (progress) {
        _uploadProgress = progress;
        notifyListeners();
      },
    );

    await uploadResult.fold(
      (failure) async {
        _isUploading = false;
        notifyListeners();
      },
      (url) async {
        final message = MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          chatId: chatId,
          senderId: senderId,
          text: '',
          type: MessageType.image,
          mediaUrl: url,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );

        await _chatRepo.sendMessage(message);
        _isUploading = false;
        _uploadProgress = 0.0;
        notifyListeners();
      },
    );
  }

  /// Send a file message.
  Future<void> sendFileMessage({
    required String chatId,
    required String senderId,
    required File file,
    required String fileName,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    final uploadResult = await _storageRepo.uploadChatFile(
      chatId: chatId,
      file: file,
      fileName: fileName,
      onProgress: (progress) {
        _uploadProgress = progress;
        notifyListeners();
      },
    );

    await uploadResult.fold(
      (failure) async {
        _isUploading = false;
        notifyListeners();
      },
      (url) async {
        final message = MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          chatId: chatId,
          senderId: senderId,
          text: '',
          type: MessageType.file,
          mediaUrl: url,
          fileName: fileName,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );

        await _chatRepo.sendMessage(message);
        _isUploading = false;
        _uploadProgress = 0.0;
        notifyListeners();
      },
    );
  }

  /// Update typing indicator.
  void setTyping({required String chatId, required String userId, required bool isTyping}) {
    _chatRepo.setTyping(chatId: chatId, userId: userId, isTyping: isTyping);
  }

  /// Mark messages as read.
  void markAsRead({required String chatId, required String userId}) {
    _chatRepo.markAsRead(chatId: chatId, userId: userId);
  }

  @override
  void dispose() {
    _chatsSub?.cancel();
    _messagesSub?.cancel();
    _typingSub?.cancel();
    super.dispose();
  }
}
