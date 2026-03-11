import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/core/injection_container.dart';
import 'package:untitled10/features/chat/domain/entity/message_entity.dart';
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleNewChat() {
    // Clear the current conversation and start fresh
    context.read<BotCubit>().getAllConversations();
  }

  void _handleSuggestionTap(String suggestion) {
    // Set the suggestion text in the message input
    _messageController.text = suggestion;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BotCubit>()..getAllConversations(),
      child: Scaffold(
        backgroundColor: AppColor.backgroundNeutral,
        resizeToAvoidBottomInset: true,
        drawer: ChatDrawer(onNewChat: _handleNewChat),
        appBar: AppBar(
          backgroundColor: AppColor.backgroundNeutral,
          elevation: 0,
          titleSpacing: 0,
          title: BlocBuilder<BotCubit, BotState>(
            buildWhen: (previous, current) => false, // customize as needed
            builder: (context, state) {
              // You may need to cast state to your custom state to access isBotTyping, messages, etc.
              return Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColor.info.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          size: 18,
                          color: AppColor.info,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 10.w,
                          height: 10.h,
                          decoration: const BoxDecoration(
                            color: AppColor.positive,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.read<LocaleCubit>().translate('chat_title'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        body: SafeArea(
          child: BlocListener<BotCubit, BotState>(
            listenWhen:
                (previous, current) =>
                    previous is! BotSuccess && current is BotSuccess ||
                    previous is! BotListSuccess && current is BotListSuccess,
            listener: (context, state) {
              _scrollToBottom();
            },
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<BotCubit, BotState>(
                    builder: (context, state) {
                      // Example: show loading, error, or messages
                      if (state is BotLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is BotError) {
                        // Show user-friendly error message
                        String errorMsg = state.failure.message;

                        // Provide specific feedback based on error type
                        if (errorMsg.contains('connection') ||
                            errorMsg.contains('timeout')) {
                          errorMsg =
                              'Unable to connect. Please check your internet connection.';
                        } else if (errorMsg.contains('500') ||
                            errorMsg.contains('server')) {
                          errorMsg =
                              'Server busy. Please try again in a moment.';
                        } else if (errorMsg.contains('401') ||
                            errorMsg.contains('unauthorized')) {
                          errorMsg = 'Session expired. Please login again.';
                        }

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMsg,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () {
                                  context
                                      .read<BotCubit>()
                                      .getAllConversations();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      if (state is BotListSuccess) {
                        final messages = state.data;
                        if (messages.isEmpty) {
                          return ChatEmptyState(
                            onSuggestionTap: _handleSuggestionTap,
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                messages[messages.length - 1 - index];
                            return MessageBubble(
                              message: message,
                              isUser: message.role == 'user',
                            );
                          },
                        );
                      }
                      return ChatEmptyState(
                        onSuggestionTap: _handleSuggestionTap,
                      );
                    },
                  ),
                ),
                BlocBuilder<BotCubit, BotState>(
                  builder: (context, state) {
                    // Enable input unless loading
                    final enabled = state is! BotLoading;
                    return MessageInput(
                      controller: _messageController,
                      enabled: enabled,
                      onSend: (text) {
                        final message = MessageEntity(
                          id: 0,
                          conversationId: 0,
                          content: text,
                          role: 'user',
                          createdAt: DateTime.now().toIso8601String(),
                          senderType: 'user',
                        );
                        context.read<BotCubit>().sendMessage(message);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
