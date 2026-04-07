import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glucotrack/core/color/app_color.dart';
import 'package:glucotrack/core/localization/locale_cubit.dart';

class ChatEmptyState extends StatelessWidget {
  final Function(String)? onSuggestionTap;

  const ChatEmptyState({super.key, this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColor.positive.withValues(alpha: 0.15),
                    AppColor.positive.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.medical_services_outlined,
                size: 44.sp,
                color: AppColor.info,
              ),
            ),

            SizedBox(height: 22.h),
            Text(
              locale.translate('tit'),
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              locale.translate('subt'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            SizedBox(height: 24.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: [
                _suggestionChip(locale.translate('sug_type1'), onSuggestionTap),
                _suggestionChip(locale.translate('sug_low'), onSuggestionTap),
                _suggestionChip(locale.translate('sug_moni'), onSuggestionTap),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String text, Function(String)? onTap) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap(text) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.positive.withValues(alpha: 0.2)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColor.positive,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
