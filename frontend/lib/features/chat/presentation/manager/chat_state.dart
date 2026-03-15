import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entity/conversation_entity.dart';
import '../../domain/entity/message_entity.dart';

enum BotStatus { initial, loading, loaded, error }

class BotState extends Equatable {
  final List<ConversationEntity> conversations;
  final List<MessageEntity> messages;
  final ConversationEntity? currentConversation;
  final BotStatus status;
  final bool isBotTyping;
  final Failure? failure;

  const BotState({
    this.conversations = const [],
    this.messages = const [],
    this.currentConversation,
    this.status = BotStatus.initial,
    this.isBotTyping = false,
    this.failure,
  });

  BotState copyWith({
    List<ConversationEntity>? conversations,
    List<MessageEntity>? messages,
    ConversationEntity? currentConversation,
    BotStatus? status,
    bool? isBotTyping,
    Failure? failure,
    bool clearCurrentConversation = false,
  }) {
    return BotState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      currentConversation:
          clearCurrentConversation
              ? null
              : (currentConversation ?? this.currentConversation),
      status: status ?? this.status,
      isBotTyping: isBotTyping ?? this.isBotTyping,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    conversations,
    messages,
    currentConversation,
    status,
    isBotTyping,
    failure,
  ];
}
