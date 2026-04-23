import 'package:equatable/equatable.dart';

enum MessageType { text, image, file }

enum MessageStatus { sent, delivered, read }

class MessageModel extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final MessageType type;
  final String? mediaUrl;
  final String? fileName;
  final int timestamp;
  final MessageStatus status;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.type = MessageType.text,
    this.mediaUrl,
    this.fileName,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, {String? messageId}) {
    return MessageModel(
      id: messageId ?? map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      mediaUrl: map['mediaUrl'],
      fileName: map['fileName'],
      timestamp: map['timestamp'] ?? 0,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'timestamp': timestamp,
      'status': status.name,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? text,
    MessageType? type,
    String? mediaUrl,
    String? fileName,
    int? timestamp,
    MessageStatus? status,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileName: fileName ?? this.fileName,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isFile => type == MessageType.file;

  @override
  List<Object?> get props => [id, chatId, senderId, text, type, mediaUrl, fileName, timestamp, status];
}
