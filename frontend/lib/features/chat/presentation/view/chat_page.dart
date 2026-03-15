import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/injection_container.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/features/chat/presentation/manager/chat_state.dart';

import '../manager/chat_cubit.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/conversation_view.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BotCubit>()..getAllConversations(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocBuilder<BotCubit, BotState>(
          builder: (context, state) {
            final activeId = state.currentConversation?.id ?? 0;

            return Scaffold(
              backgroundColor: AppColor.backgroundNeutral,
              resizeToAvoidBottomInset: true,
              drawer: ChatDrawer(
                onNewChat: () {
                  context.read<BotCubit>().resetChat();
                },
                onConversationSelected: (id) {
                  context.read<BotCubit>().loadConversation(id);
                },
              ),
              appBar: _buildAppBar(context),
              body: SafeArea(child: ConversationView(conversationId: activeId)),
            );
          },
        ),
      ),
    );
  }

  /// App Bar with Modern Stylings and Status Indicators
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final locale = context.read<LocaleCubit>();
    String defaultTitleText = locale.translate("chat_title");

    return AppBar(
      backgroundColor: AppColor.backgroundNeutral.withOpacity(0.9),
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      // A subtle bottom border for a clean separation from the chat list
      shape: Border(
        bottom: BorderSide(
          color: AppColor.textNeutral.withOpacity(0.05),
          width: 1,
        ),
      ),
      title: BlocBuilder<BotCubit, BotState>(
        builder: (context, state) {
          String displayTitle = defaultTitleText;
          bool hasActiveConv = state.currentConversation != null;

          if (hasActiveConv && state.currentConversation!.title.isNotEmpty) {
            displayTitle = state.currentConversation!.title;
          }

          return Row(
            children: [
              SizedBox(width: 8.w), // Adjust for drawer icon spacing
              // Avatar with a slightly larger, cleaner design
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.info.withOpacity(0.1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome, // Modern AI/Assistant icon
                      size: 20.sp,
                      color: AppColor.info,
                    ),
                    // Animated-style online indicator
                    Positioned(
                      bottom: 2.h,
                      right: 2.w,
                      child: Container(
                        width: 11.w,
                        height: 11.h,
                        decoration: BoxDecoration(
                          color: AppColor.positive,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.positive.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Multi-line title for status context
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textNeutral,
                        letterSpacing: -0.5,
                      ),
                    ),
                    // Subtitle status indicator
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
