import 'package:flutter/material.dart';
import '../color/app_color.dart';

class AppButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool loading;
  final double? height;
  final double? fontSize;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.loading = false,
    this.height,
    this.fontSize,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = loading || onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDisabled
                  ? (backgroundColor ?? AppColor.positive).withValues(
                    alpha: 0.5,
                  )
                  : backgroundColor ?? AppColor.positive,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isDisabled ? null : onPressed,
        child:
            loading
                ? CircularProgressIndicator(color: Colors.white)
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color:
                          isDisabled
                              ? iconColor.withValues(alpha: 0.5)
                              : iconColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize ?? 16,
                        color:
                            isDisabled
                                ? (textColor ?? Colors.white).withValues(
                                  alpha: 0.5,
                                )
                                : textColor ?? Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
