import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';

class ChatEmptyState extends StatelessWidget {
  final Function(String)? onSuggestionTap;

  const ChatEmptyState({super.key, this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
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
                context.read<LocaleCubit>().translate('tit'),
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text(
                context.read<LocaleCubit>().translate('subt'),
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
                  _suggestionChip(
                    context.read<LocaleCubit>().translate('sug_type1'),
                    onSuggestionTap,
                  ),
                  _suggestionChip(
                    context.read<LocaleCubit>().translate('sug_low'),
                    onSuggestionTap,
                  ),
                  _suggestionChip(
                    context.read<LocaleCubit>().translate('sug_moni'),
                    onSuggestionTap,
                  ),
                ],
              ),
            ],
          ),
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
