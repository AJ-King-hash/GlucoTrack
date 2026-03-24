import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glucotrack/features/home/presentation/manager/bottom_nav_cubit.dart';
import '../../../../core/color/app_color.dart';
import '../../../../core/localization/locale_cubit.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, int>(
      builder: (context, index) {
        return Container(
          height: 72.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColor.backgroundNeutral,
            borderRadius: BorderRadius.circular(40.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                context,
                icon: Icons.home,
                iconColor: AppColor.info,
                activeIconColor: AppColor.textNeutral,
                label: context.read<LocaleCubit>().translate('home'),
                isActive: index == 0,
                onTap: () => context.read<BottomNavCubit>().changeIndex(0),
              ),
              _navItem(
                context,
                icon: Icons.message,
                iconColor: AppColor.info,
                activeIconColor: AppColor.textNeutral,
                label: context.read<LocaleCubit>().translate('chat_gpt'),
                isActive: index == 1,
                onTap: () => context.read<BottomNavCubit>().changeIndex(1),
              ),
              _navItem(
                context,
                icon: Icons.layers,
                iconColor: AppColor.info,
                activeIconColor: AppColor.textNeutral,
                label: context.read<LocaleCubit>().translate('archives'),
                isActive: index == 2,
                onTap: () => context.read<BottomNavCubit>().changeIndex(2),
              ),
              _navItem(
                context,
                icon: Icons.settings,
                iconColor: AppColor.info,
                activeIconColor: AppColor.textNeutral,
                label: context.read<LocaleCubit>().translate('settings'),
                isActive: index == 3,
                onTap: () => context.read<BottomNavCubit>().changeIndex(3),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required Color iconColor,
    required Color activeIconColor,
    required VoidCallback onTap,
    String label = '',
  }) {
    return GestureDetector(
      onTap: onTap,
      child:
          isActive
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 48.w,
                    width: 48.w,
                    decoration: BoxDecoration(
                      color: AppColor.info,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColor.textNeutral, size: 24.sp),
                  ),
                  if (label.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColor.textNeutral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              )
              : Icon(icon, color: AppColor.info, size: 26.sp),
    );
  }
}
