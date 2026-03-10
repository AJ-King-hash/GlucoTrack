import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/features/chat/presentation/manager/chat_cubit.dart';
import 'package:untitled10/features/chat/presentation/manager/chat_state.dart';
import 'package:untitled10/features/chat/presentation/widgets/section_item.dart';
import 'archived_chat_item.dart';

class ChatDrawer extends StatefulWidget {
  final VoidCallback? onNewChat;

  const ChatDrawer({super.key, this.onNewChat});

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  @override
  void initState() {
    super.initState();
    // Fetch conversations when drawer opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BotCubit>().getAllConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create new chat
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Close drawer first
                  Navigator.pop(context);
                  // Trigger new chat callback
                  widget.onNewChat?.call();
                },
                icon: const Icon(Icons.add),
                label: const Text('New Chat'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),

            const SectionTitle(title: 'Recent Chats'),

            Expanded(
              child: BlocBuilder<BotCubit, BotState>(
                builder: (context, state) {
                  if (state is BotLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is BotError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.failure.message}'),
                          TextButton(
                            onPressed: () {
                              context.read<BotCubit>().getAllConversations();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is BotListSuccess) {
                    final conversations = state.data;
                    if (conversations.isEmpty) {
                      return const Center(child: Text('No conversations yet'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return ArchivedChatItem(
                          title:
                              conversation.title.isNotEmpty
                                  ? conversation.title
                                  : 'Chat ${conversation.id}',
                          onDelete: () {
                            context.read<BotCubit>().deleteConversation(
                              conversation.id,
                            );
                          },
                        );
                      },
                    );
                  }

                  // Initial state - show loading
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
