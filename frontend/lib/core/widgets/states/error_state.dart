import 'package:flutter/material.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A reusable error state widget that can be customized for different use cases.
class ErrorState extends StatelessWidget {
  final String? message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final IconData? icon;
  final bool showActionButton;

  const ErrorState({
    super.key,
    this.message,
    this.actionLabel,
    this.onActionPressed,
    this.icon,
    this.showActionButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          SizedBox(
            width: 250,
            child: Text(
              message ?? locale.translate('something_went_wrong'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showActionButton && onActionPressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: Icon(Icons.refresh),
              label: Text(actionLabel ?? locale.translate('refresh')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
