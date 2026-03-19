import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../manager/chat_cubit.dart';
import '../manager/chat_state.dart';
import 'chat_empty_state.dart';
import 'message_bubble.dart';
import 'message_input.dart';
import 'avatar_icon.dart';

class ConversationView extends StatefulWidget {
  final int conversationId;
  const ConversationView({super.key, required this.conversationId});

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BotCubit, BotState>(
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        if (state.status == BotStatus.loading && state.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child:
                  state.messages.isEmpty
                      ? ChatEmptyState(
                        onSuggestionTap: (s) => _messageController.text = s,
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        reverse: true,
                        itemCount:
                            state.isBotTyping
                                ? state.messages.length + 1
                                : state.messages.length,
                        itemBuilder: (context, index) {
                          if (state.isBotTyping && index == 0) {
                            return _buildTypingIndicator();
                          }

                          final msgIndex =
                              state.isBotTyping
                                  ? state.messages.length - index
                                  : state.messages.length - 1 - index;
                          final message = state.messages[msgIndex];
                          return MessageBubble(
                            message: message,
                            isUser: message.senderType == 'user',
                          );
                        },
                      ),
            ),
            MessageInput(
              controller: _messageController,
              enabled: !state.isBotTyping && state.status != BotStatus.loading,
              onSend: (text) {
                context.read<BotCubit>().handleMessageSent(
                  text.trim(),
                  widget.conversationId,
                );
                _messageController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  /// Build typing indicator for bot
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AvatarIcon(isUser: false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                _buildTypingDot(),
                const SizedBox(width: 3),
                _buildTypingDot(),
                const SizedBox(width: 3),
                _buildTypingDot(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual typing dot
  Widget _buildTypingDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
    );
  }
}
