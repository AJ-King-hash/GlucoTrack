import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/core/helperfile//api_service.dart';
import 'package:untitled10/features/chat/domain/entity/message_entity.dart';
import 'package:untitled10/features/chat/domain/usecase/create_conversation_usecase.dart';
import 'package:untitled10/features/chat/domain/usecase/delete_conversation_usecase.dart';
import 'package:untitled10/features/chat/domain/usecase/get_allconversation_usecase.dart';
import 'package:untitled10/features/chat/domain/usecase/get_allmessage_usecase.dart';
import 'package:untitled10/features/chat/domain/usecase/get_conversation_usecase.dart';
import 'package:untitled10/features/chat/domain/usecase/send_message_usecase.dart';
import 'package:untitled10/features/chat/presentation/widgets/chat_empty_state.dart';
import 'package:untitled10/features/chat/repo/chat_repo_impl.dart';

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
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BotCubit(
        createConversationUseCase: CreateConversationUseCase(BotRepositoryImpl(ApiService())),
        getConversationUseCase: GetConversationUseCase(BotRepositoryImpl(ApiService())),
        getAllConversationsUseCase:GetAllConversationUseCase(BotRepositoryImpl(ApiService())),
        deleteConversationUseCase: DeleteConversationUseCase(BotRepositoryImpl(ApiService())),
        sendMessageUseCase:SendMessageUseCase(BotRepositoryImpl(ApiService())),
        getAllMessagesUseCase: GetAllMessageUseCase(BotRepositoryImpl(ApiService())),
      ),
      child: Scaffold(
        backgroundColor: AppColor.backgroundNeutral,
        resizeToAvoidBottomInset: true,
        drawer: const ChatDrawer(),
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
                        backgroundColor: AppColor.info.withOpacity(0.1),
                        child: const Icon(
                            Icons.medical_services_outlined,
                            size: 18,
                            color: AppColor.info),
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
                        context.read<LocaleCubit>().translate('tit'),
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
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
            listenWhen: (previous, current) => false, // customize as needed
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
                        return Center(child: Text(state.failure.message));
                      }
                      if (state is BotListSuccess) {
                        final messages = state.data;
                        if (messages.isEmpty) {
                          return const ChatEmptyState();
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[messages.length - 1 - index];
                            return MessageBubble(
                              message: message,
                              isUser: message.role == 'user',
                            );
                          },
                        );
                      }
                      return const ChatEmptyState();
                    },
                  ),
                ),
                BlocBuilder<BotCubit, BotState>(
                  builder: (context, state) {
                    // Enable input unless loading
                    final enabled = state is! BotLoading;
                    return MessageInput(
                      enabled: enabled,
                      onSend: (text) {
                        final message = MessageEntity(
                          id: 0,
                          conversationId: 0,
                          content: text,
                          role: 'user',
                          createdAt: DateTime.now().toIso8601String(),
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