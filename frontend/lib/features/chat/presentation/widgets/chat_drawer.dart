import 'package:flutter/material.dart';
import 'package:untitled10/features/chat/presentation/widgets/section_item.dart';
import 'archived_chat_item.dart';


class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

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
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('New Chat'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),

            const SectionTitle(title: 'Archived Chats'),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return ArchivedChatItem(
                    title: 'Archived Chat ${index + 1}',
                    onDelete: () {},
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
