import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final int id;
  final int conversationId;
  final String content;
  final String role;
  final String createdAt;
  final String senderType;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.role,
    required this.createdAt,
    required this.senderType,
  });

  @override
  List<Object?> get props => [
    id,
    conversationId,
    content,
    role,
    createdAt,
    senderType,
  ];
}
