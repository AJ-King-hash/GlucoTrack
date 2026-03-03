import 'package:flutter/material.dart';
import 'package:untitled10/features/chat/presentation/widgets/typing_indicator.dart';

class BotTypingBubble extends StatelessWidget {
  const BotTypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const TypingIndicator(),
      ),
    );
  }
}
