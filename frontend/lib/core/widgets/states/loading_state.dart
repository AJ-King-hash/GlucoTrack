import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable loading state widget that can be customized for different use cases.
class LoadingState extends StatelessWidget {
  final String? message;
  final Widget? indicator;
  final double? size;
  final Color? color;

  const LoadingState({
    super.key,
    this.message,
    this.indicator,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator ??
              SizedBox(
                width: size ?? 24.r,
                height: size ?? 24.r,
                child: CircularProgressIndicator(
                  color: color,
                  strokeWidth: 2.5,
                ),
              ),
          if (message != null) ...[
            SizedBox(height: 12.h),
            Text(
              message!,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
