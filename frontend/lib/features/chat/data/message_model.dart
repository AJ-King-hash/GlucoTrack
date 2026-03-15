import '../domain/entity/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.message,
    required super.createdAt,
    required super.senderType,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      message: json['message'] ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      senderType: json['sender_type'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'message': message,
      'created_at': createdAt,
      'sender_type': senderType,
    };
  }
}
