import 'package:flutter/material.dart';
import 'package:glucotrack/core/color/app_color.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final bool enabled;
  final TextEditingController? controller;

  const MessageInput({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.controller,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

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
                    color:
                        widget.enabled
                            ? Colors.blue.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: widget.enabled,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted:
                            widget.enabled
                                ? (value) {
                                  if (value.trim().isEmpty) return;
                                  widget.onSend(value.trim());
                                  _controller.clear();
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
                color:
                    widget.enabled ? AppColor.positive : Colors.grey.shade400,
              ),
              child:
                  widget.enabled
                      ? IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: AppColor.info,
                        ),
                        onPressed: () {
                          if (_controller.text.trim().isEmpty) return;
                          widget.onSend(_controller.text.trim());
                          _controller.clear();
                        },
                      )
                      : const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
