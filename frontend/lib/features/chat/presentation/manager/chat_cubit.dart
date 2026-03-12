import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/base_usecase/base_usecase.dart';
import 'package:untitled10/features/chat/domain/entity/message_entity.dart';
import '../../domain/usecase/create_conversation_usecase.dart';
import '../../domain/usecase/delete_conversation_usecase.dart';
import '../../domain/usecase/get_allconversation_usecase.dart';
import '../../domain/usecase/get_allmessage_usecase.dart';
import '../../domain/usecase/get_conversation_usecase.dart';
import '../../domain/usecase/send_message_usecase.dart';

import 'chat_state.dart';

class BotCubit extends Cubit<BotState> {
  final CreateConversationUseCase createConversationUseCase;
  final GetConversationUseCase getConversationUseCase;
  final GetAllConversationUseCase getAllConversationsUseCase;
  final DeleteConversationUseCase deleteConversationUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetAllMessageUseCase getAllMessagesUseCase;

  BotCubit({
    required this.createConversationUseCase,
    required this.getConversationUseCase,
    required this.getAllConversationsUseCase,
    required this.deleteConversationUseCase,
    required this.sendMessageUseCase,
    required this.getAllMessagesUseCase,
  }) : super(const BotInitial());

  Future<void> createConversation(String title) async {
    emit(const BotLoading());
    final result = await createConversationUseCase((title));
    result.fold(
      (failure) => emit(BotError(failure)),
      (data) => emit(BotSuccess(data)),
    );
  }

  Future<void> getConversation(int conversationId) async {
    emit(const BotLoading());
    final result = await getConversationUseCase(conversationId);
    result.fold(
      (failure) => emit(BotError(failure)),
      (data) => emit(BotSuccess(data)),
    );
  }

  Future<void> getAllConversations() async {
    emit(const BotLoading());
    final result = await getAllConversationsUseCase(const NoParams());
    result.fold(
      (failure) => emit(BotError(failure)),
      (data) => emit(BotListSuccess(data)),
    );
  }

  Future<void> deleteConversation(int conversationId) async {
    emit(const BotLoading());
    final result = await deleteConversationUseCase(
      DeleteConversationParams(conversationId),
    );
    result.fold(
      (failure) => emit(BotError(failure)),
      (data) => emit(BotSuccess(data)),
    );
  }

  Future<void> sendMessage(MessageEntity message) async {
    emit(const BotLoading());
    final result = await sendMessageUseCase(message);
    result.fold(
      (failure) => emit(BotError(failure)),
      (data) => emit(BotSuccess(data)),
    );
  }

  /// Send a bot response message for the given conversation
  /// This is called automatically after user sends a message
  Future<void> sendBotResponse(int conversationId, String userMessage) async {
    emit(const BotLoading());

    // Create bot message with senderType = 'bot'
    final botMessage = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      conversationId: conversationId,
      content: '', // Backend will populate this with the bot's response
      createdAt: DateTime.now().toIso8601String(),
      senderType: 'bot',
    );

    final result = await sendMessageUseCase(botMessage);
    result.fold(
      (failure) => emit(BotError(failure)),
      (data) => emit(BotSuccess(data)),
    );
  }

  Future<void> getAllMessages(int conversationId) async {
    emit(const BotLoading());
    final result = await getAllMessagesUseCase(conversationId);
    result.fold(
      (failure) => emit(BotError(failure)),
      (data) => emit(BotListSuccess(data)),
    );
  }
}
