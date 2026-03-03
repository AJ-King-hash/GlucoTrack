import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled10/core/color/app_color.dart';

class MessageInput extends StatelessWidget {
  final Function(String) onSend;
  final bool enabled;

  MessageInput({
    super.key,
    required this.onSend,
    this.enabled = true,
  });

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppColor.backgroundNeutral,
        boxShadow: [
          BoxShadow(
            color: AppColor.backgroundNeutral,
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColor.backgroundNeutral,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: enabled
                        ? Colors.blue.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.mic,
                      size: 20,
                      color: enabled
                          ? AppColor.info
                          : Colors.grey,
                    ),

                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        enabled: enabled,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: enabled
                            ? (value) {
                          if (value.trim().isEmpty) return;
                          onSend(value.trim());
                          controller.clear();
                        }
                            : null,
                        decoration: const InputDecoration(
                          hintText: 'اكتب سؤالك الطبي هنا...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled
                    ? AppColor.positive
                    : Colors.grey.shade400,
              ),
              child: enabled
                  ? IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: AppColor.info,
                ),
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  onSend(controller.text.trim());
                  controller.clear();
                },
              )
                  : const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}