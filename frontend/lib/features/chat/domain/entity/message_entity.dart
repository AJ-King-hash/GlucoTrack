import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final int id;
  final int conversationId;
  final String message;
  final String createdAt;
  final String senderType;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.message,
    required this.createdAt,
    required this.senderType,
  });

  @override
  List<Object?> get props => [
    id,
    conversationId,
    message,
    createdAt,
    senderType,
  ];
}
