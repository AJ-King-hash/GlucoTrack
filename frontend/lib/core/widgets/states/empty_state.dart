import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A reusable empty state widget that can be customized for different use cases.
class EmptyState extends StatelessWidget {
  final String? lottieAsset;
  final String? messageKey;
  final String? customMessage;
  final double? lottieHeight;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;

  const EmptyState({
    Key? key,
    this.lottieAsset,
    this.messageKey,
    this.customMessage,
    this.lottieHeight,
    this.icon,
    this.iconSize,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottieAsset != null && lottieAsset!.isNotEmpty)
            Lottie.asset(lottieAsset!, height: lottieHeight ?? 150.h)
          else if (icon != null)
            Icon(
              icon,
              size: iconSize ?? 80,
              color: iconColor ?? Colors.grey[300],
            )
          else
            Icon(Icons.auto_graph_outlined, size: 80, color: Colors.grey[300]),

          const SizedBox(height: 16),
          Text(
            customMessage ??
                (messageKey != null && messageKey!.isNotEmpty
                    ? locale.translate(messageKey!)
                    : locale.translate('notfound')),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
