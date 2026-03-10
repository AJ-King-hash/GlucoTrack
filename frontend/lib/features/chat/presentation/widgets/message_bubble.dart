import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/time_formater.dart';
import '../../data/message_model.dart';
import 'avatar_icon.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isUser;

  const MessageBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) AvatarIcon(isUser: false),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              constraints: const BoxConstraints(maxWidth: 300),
              decoration: BoxDecoration(
                color: isUser ? Colors.green : Colors.grey.shade300,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                  bottomRight:
                      isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15.sp,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (() {
                      if (message.createdAt.isNotEmpty) {
                        try {
                          final dt = DateTime.parse(message.createdAt);
                          return TimeFormatter.format(dt);
                        } catch (_) {
                          return '';
                        }
                      }
                      return '';
                    })(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color:
                          isUser
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isUser) AvatarIcon(isUser: true),
        ],
      ),
    );
  }
}
