import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/core/injection_container.dart';
import 'package:untitled10/features/chat/domain/entity/message_entity.dart';
import 'package:untitled10/features/chat/domain/entity/conversation_entity.dart';
import 'package:untitled10/features/chat/presentation/widgets/chat_empty_state.dart';

import '../manager/chat_cubit.dart';
import '../manager/chat_state.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  // Track current conversation ID
  int _currentConversationId = 0;
  bool _isNewConversation = true;

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSuggestionTap(String suggestion) {
    _messageController.text = suggestion;
  }

  /// Fetch bot response after user sends a message
  void _fetchBotResponse() {
    // Wait a short delay then fetch bot response
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_currentConversationId > 0) {
        context.read<BotCubit>().sendBotResponse(
          _currentConversationId,
          _messageController.text,
        );
        // Refresh messages to show bot response
        context.read<BotCubit>().getAllMessages(_currentConversationId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BotCubit>()..getAllConversations(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.backgroundNeutral,
          resizeToAvoidBottomInset: true,
          drawer: ChatDrawer(
            onNewChat: () {
              // Create new conversation
              _isNewConversation = true;
              _currentConversationId = 0;
              // Clear current messages
              context.read<BotCubit>().getAllConversations();
            },
            onConversationSelected: (conversationId) {
              // Load selected conversation
              _isNewConversation = false;
              _currentConversationId = conversationId;
              context.read<BotCubit>().getAllMessages(_currentConversationId);
            },
          ),
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: BlocListener<BotCubit, BotState>(
              listenWhen:
                  (prev, curr) => curr is BotSuccess || curr is BotListSuccess,
              listener: (context, state) {
                _scrollToBottom();

                // If conversation was just created, get its ID
                if (state is BotSuccess &&
                    state.data is ConversationEntity &&
                    _isNewConversation) {
                  final conversation = state.data as ConversationEntity;
                  _currentConversationId = conversation.id;
                  _isNewConversation = false;
                  // Load messages for this conversation
                  context.read<BotCubit>().getAllMessages(
                    _currentConversationId,
                  );
                }
              },
              child: Column(
                children: [
                  // 1. Messages Area
                  Expanded(
                    child: BlocBuilder<BotCubit, BotState>(
                      builder: (context, state) {
                        if (state is BotLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is BotError) {
                          return _buildErrorState(context, state);
                        }

                        if (state is BotListSuccess<MessageEntity>) {
                          final messages = state.data;

                          if (messages.isEmpty) {
                            return ChatEmptyState(
                              onSuggestionTap: _handleSuggestionTap,
                            );
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                            reverse:
                                true, // Latest messages appear at the bottom
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              // Flip the index to show newest at bottom
                              final message =
                                  messages[messages.length - 1 - index];
                              return MessageBubble(
                                message: message,
                                isUser: message.senderType == 'user',
                              );
                            },
                          );
                        }

                        // Default empty state
                        return ChatEmptyState(
                          onSuggestionTap: _handleSuggestionTap,
                        );
                      },
                    ),
                  ),

                  // 2. Input Area
                  BlocBuilder<BotCubit, BotState>(
                    builder: (context, state) {
                      final bool isBotTyping = state is BotLoading;
                      return MessageInput(
                        controller: _messageController,
                        enabled: !isBotTyping,
                        onSend: (text) async {
                          if (text.trim().isEmpty) return;

                          // Create new conversation if this is a new chat
                          if (_isNewConversation) {
                            final cubit = context.read<BotCubit>();
                            await cubit.createConversation(text);
                            // Wait for the conversation ID to be set by the BlocListener
                            // before sending the message
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                          }

                          final message = MessageEntity(
                            id: DateTime.now().millisecondsSinceEpoch,
                            conversationId: _currentConversationId,
                            content: text,
                            createdAt: DateTime.now().toIso8601String(),
                            senderType: 'user',
                          );

                          context.read<BotCubit>().sendMessage(message);

                          // After sending user message, trigger bot response
                          // The bot response will be fetched after the user message is created
                          _fetchBotResponse();

                          _messageController.clear();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// App Bar with Health Assistant Avatar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return AppBar(
      backgroundColor: AppColor.backgroundNeutral,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          SizedBox(
            width: 40.w,
            height: 40.h,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 18.r, // Use .r for radius to maintain aspect ratio
                  backgroundColor: AppColor.info.withOpacity(0.1),
                  child: Icon(
                    Icons.medical_services_outlined,
                    size: 18.sp,
                    color: AppColor.info,
                  ),
                ),
                Positioned(
                  bottom: 2.h,
                  right: 2.w,
                  child: Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: AppColor.positive,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              locale.translate('subt'),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textNeutral,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Error State with Retry Logic
  Widget _buildErrorState(BuildContext context, BotError state) {
    final locale = context.read<LocaleCubit>();

    String errorMsg = state.failure.message;
    if (errorMsg.contains('connection')) {
      errorMsg = 'Check your internet connection and try again.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(errorMsg, textAlign: TextAlign.center),
          ),
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: () => context.read<BotCubit>().getAllConversations(),
            icon: const Icon(Icons.refresh),
            label: Text(
              locale.translate('try_again'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
