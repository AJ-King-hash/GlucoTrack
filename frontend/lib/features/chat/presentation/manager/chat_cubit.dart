import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:glucotrack/core/base_usecase/base_usecase.dart';
import 'package:glucotrack/core/utils/global_refresher.dart';
import 'package:glucotrack/core/utils/toast_utility.dart';
import 'package:glucotrack/features/chat/domain/entity/message_entity.dart';
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
  }) : super(const BotState());

  // Resets the chat UI when "New Chat" is clicked
  void resetChat() {
    emit(
      state.copyWith(
        messages: [],
        clearCurrentConversation: true,
        status: BotStatus.loaded,
      ),
    );
  }

  Future<void> handleMessageSent(String text, int conversationId) async {
    int id = conversationId;

    // 1. Creation Phase
    if (id == 0) {
      // Clear old messages immediately so the UI doesn't show "ghost" data
      emit(state.copyWith(status: BotStatus.loading, messages: []));
      final result = await createConversationUseCase(text);

      // We use a temporary variable to capture the new ID correctly
      result.fold(
        (failure) {
          ToastUtility.showError(failure.message);
          GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
          emit(state.copyWith(status: BotStatus.error, failure: failure));
        },
        (conv) {
          // Update the conversation info but KEEP messages empty for now
          ToastUtility.showSuccess("Conversation created successfully");
          GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
          emit(
            state.copyWith(
              currentConversation: conv,
              status: BotStatus.loaded,
              messages: [],
            ),
          );
        },
      );

      // Refresh the drawer list in the background
      await getAllConversations();
      return;
    }

    // 2. Prepare User Message
    final userMessage = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      conversationId: id,
      message: text,
      createdAt: DateTime.now().toIso8601String(),
      senderType: 'user',
    );

    // 3. Send & Fetch Truth
    emit(state.copyWith(isBotTyping: true));

    final sendResult = await sendMessageUseCase(userMessage);

    await sendResult.fold(
      (failure) async {
        ToastUtility.showError(failure.message);
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(state.copyWith(status: BotStatus.error, failure: failure));
      },
      (userMessage) async {
        // 3. Send Bot Reponse
        final botMessage = MessageEntity(
          id: DateTime.now().millisecondsSinceEpoch,
          conversationId: id,
          message: text,
          createdAt: DateTime.now().toIso8601String(),
          senderType: 'bot',
        );

        final result = await sendMessageUseCase(botMessage);
        result.fold(
          (failure) {
            ToastUtility.showError(failure.message);
            GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
            emit(state.copyWith(isBotTyping: false, status: BotStatus.error));
          },
          (botResponse) async {
            final refreshResult = await getAllMessagesUseCase(id);
            refreshResult.fold(
              (failure) => emit(state.copyWith(isBotTyping: false)),
              (messages) {
                // ENSURE we only update if we are still on the same conversation
                if (state.currentConversation?.id == id) {
                  emit(
                    state.copyWith(
                      messages: messages,
                      isBotTyping: false,
                      status: BotStatus.loaded,
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Future<void> getAllConversations() async {
    final result = await getAllConversationsUseCase(const NoParams());
    result.fold(
      (failure) =>
          emit(state.copyWith(status: BotStatus.error, failure: failure)),
      (data) =>
          emit(state.copyWith(conversations: data, status: BotStatus.loaded)),
    );
  }

  Future<void> loadConversation(int id) async {
    emit(state.copyWith(status: BotStatus.loading));

    final convResult = await getConversationUseCase(id);
    final msgResult = await getAllMessagesUseCase(id);

    convResult.fold(
      (f) => emit(state.copyWith(status: BotStatus.error, failure: f)),
      (conv) {
        msgResult.fold(
          (f) => emit(state.copyWith(status: BotStatus.error, failure: f)),
          (msgs) => emit(
            state.copyWith(
              currentConversation: conv,
              messages: msgs,
              status: BotStatus.loaded,
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteConversation(int conversationId) async {
    // 1. Emit loading but keep existing data to prevent UI flicker
    emit(state.copyWith(status: BotStatus.loading));

    final result = await deleteConversationUseCase(
      DeleteConversationParams(conversationId),
    );

    result.fold(
      (failure) {
        ToastUtility.showError(failure.message);
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        emit(state.copyWith(status: BotStatus.error, failure: failure));
      },
      (success) {
        ToastUtility.showSuccess("Conversation deleted successfully");
        GetIt.I<GlobalRefresher>().triggerGlobalRefresh();
        // 2. Filter out the deleted conversation from the local list
        final updatedConversations =
            state.conversations
                .where((conv) => conv.id != conversationId)
                .toList();

        // 3. If the user deleted the current active conversation, reset the chat view
        if (state.currentConversation?.id == conversationId) {
          emit(
            state.copyWith(
              conversations: updatedConversations,
              clearCurrentConversation: true,
              messages: [],
              status: BotStatus.loaded,
            ),
          );
        } else {
          emit(
            state.copyWith(
              conversations: updatedConversations,
              status: BotStatus.loaded,
            ),
          );
        }
      },
    );
  }
}
