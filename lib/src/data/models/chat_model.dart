import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  final String id;
  final Map<String, bool> participants;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String? lastMessage;
  final int? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final Map<String, bool> typing;
  final int createdAt;

  const ChatModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    this.participantPhotos = const {},
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCount = const {},
    this.typing = const {},
    required this.createdAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, {String? chatId}) {
    return ChatModel(
      id: chatId ?? map['id'] ?? '',
      participants: _parseStringBoolMap(map['participants']),
      participantNames: _parseStringStringMap(map['participantNames']),
      participantPhotos: _parseStringNullableStringMap(map['participantPhotos']),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'],
      lastMessageSenderId: map['lastMessageSenderId'],
      unreadCount: _parseStringIntMap(map['unreadCount']),
      typing: _parseStringBoolMap(map['typing']),
      createdAt: map['createdAt'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'typing': typing,
      'createdAt': createdAt,
    };
  }

  /// Get the other participant's ID (for 1-on-1 chats)
  String otherUserId(String currentUserId) {
    return participants.keys.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Get the other participant's name
  String otherUserName(String currentUserId) {
    final otherId = otherUserId(currentUserId);
    return participantNames[otherId] ?? 'Unknown';
  }

  /// Get the other participant's photo URL
  String? otherUserPhoto(String currentUserId) {
    final otherId = otherUserId(currentUserId);
    return participantPhotos[otherId];
  }

  /// Get unread count for a specific user
  int unreadFor(String userId) {
    return unreadCount[userId] ?? 0;
  }

  /// Check if a specific user is typing
  bool isTyping(String userId) {
    return typing[userId] ?? false;
  }

  ChatModel copyWith({
    String? id,
    Map<String, bool>? participants,
    Map<String, String>? participantNames,
    Map<String, String?>? participantPhotos,
    String? lastMessage,
    int? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    Map<String, bool>? typing,
    int? createdAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      participantNames: participantNames ?? this.participantNames,
      participantPhotos: participantPhotos ?? this.participantPhotos,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      typing: typing ?? this.typing,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── Parsing helpers ──

  static Map<String, bool> _parseStringBoolMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v == true));
    }
    return {};
  }

  static Map<String, String> _parseStringStringMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
    }
    return {};
  }

  static Map<String, String?> _parseStringNullableStringMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v?.toString()));
    }
    return {};
  }

  static Map<String, int> _parseStringIntMap(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0));
    }
    return {};
  }

  @override
  List<Object?> get props => [id, participants, lastMessage, lastMessageTime, createdAt];
}
