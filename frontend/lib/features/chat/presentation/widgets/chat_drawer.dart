import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/core/localization/locale_cubit.dart';
import 'package:glucotrack/features/chat/presentation/manager/chat_cubit.dart';
import 'package:glucotrack/features/chat/presentation/manager/chat_state.dart';
import 'package:glucotrack/features/chat/presentation/widgets/section_item.dart';
import 'archived_chat_item.dart';

class ChatDrawer extends StatefulWidget {
  final VoidCallback? onNewChat;
  final Function(int conversationId)? onConversationSelected;

  const ChatDrawer({super.key, this.onNewChat, this.onConversationSelected});

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  @override
  void initState() {
    super.initState();
    // Fetch conversations when drawer is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BotCubit>().getAllConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. New Chat Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close drawer [cite: 125]
                  widget.onNewChat?.call();
                },
                icon: const Icon(Icons.add),
                label: Text(locale.translate('new_chat')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),

            SectionTitle(title: locale.translate("recent_chats")),

            // 2. Dynamic Conversation List
            Expanded(
              child: BlocBuilder<BotCubit, BotState>(
                builder: (context, state) {
                  // Handle Loading State
                  if (state.status == BotStatus.loading &&
                      state.conversations.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Handle Error State
                  if (state.status == BotStatus.error &&
                      state.failure != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.failure!.message}'),
                          TextButton(
                            onPressed:
                                () =>
                                    context
                                        .read<BotCubit>()
                                        .getAllConversations(),
                            child: Text(locale.translate('try_again')),
                          ),
                        ],
                      ),
                    );
                  }

                  // Handle Empty List
                  if (state.conversations.isEmpty) {
                    return const Center(child: Text('No conversations yet'));
                  }

                  // Build Conversation List
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = state.conversations[index];

                      return ArchivedChatItem(
                        key: ValueKey(conversation.id),
                        title:
                            conversation.title.isNotEmpty
                                ? conversation.title
                                : 'Chat ${conversation.id}',
                        onTap: () {
                          Navigator.pop(context);
                          widget.onConversationSelected?.call(conversation.id);
                        },
                        onDelete: () {
                          // Note: Consider adding a confirmation dialog here
                          context.read<BotCubit>().deleteConversation(
                            conversation.id,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
