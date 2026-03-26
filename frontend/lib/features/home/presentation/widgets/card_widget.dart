import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/color/app_color.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../user/presentation/manager/user_cubit.dart';
import '../../../user/presentation/manager/user_state.dart';

class MedicalHeaderCard extends StatelessWidget {
  const MedicalHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<UserCubit>().getUser();
    final locale = context.read<LocaleCubit>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColor.backgroundNeutral.withValues(alpha: 0.6),
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
                  AppColor.info.withValues(alpha: 0.9),
                  AppColor.info.withValues(alpha: 0.6),
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
                /// Welcome message with user name
                BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    String userName = '';
                    if (state is UserLoaded &&
                        state.userModel.name.isNotEmpty) {
                      userName = state.userModel.name;
                    }
                    return Text(
                      '${locale.translate("welcome_message")} $userName',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textNeutral,
                      ),
                    );
                  },
                ),
                SizedBox(height: 4.h),

                /// Ayah display
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.translate("ayah_text"),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                          color: AppColor.textNeutral.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        locale.translate("ayah_reference"),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
