import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/color/app_color.dart';
import '../../../../core/localization/locale_cubit.dart';

class MedicalHeaderCard extends StatelessWidget {
  const MedicalHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColor.backgroundNeutral.withOpacity(0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Medical Icon
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColor.info.withOpacity(0.9),
                  AppColor.info.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.health_and_safety,
              color: Colors.white,
              size: 26.sp,
            ),
          ),

          SizedBox(width: 16.w),

          /// Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.translate("welcome"),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textNeutral,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  locale.translate("its"),
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.4,
                    color: AppColor.textNeutral.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),

          /// Subtle Arrow (UX hint)
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16.sp,
            color: AppColor.textNeutral.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}