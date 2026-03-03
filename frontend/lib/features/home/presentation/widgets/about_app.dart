import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/core/widgets/app_logo.dart';
import '../../../../core/color/app_color.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundNeutral,
      appBar: AppBar(
        title:  Text(
          context.read<LocaleCubit>().translate('about_app'),
        ),
        backgroundColor: AppColor.backgroundNeutral,
        centerTitle: true,
        elevation: 2,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h,),

           AppLogo(),
            SizedBox(height: 20.h,),
            Text(
              'GlucoTrack',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textNeutral,
              ),
            ),
            Text(
              context.read<LocaleCubit>().translate('version'),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.textNeutral,
              ),
            ),

            SizedBox(height: 24.h),
            _animatedInfoCard(
              icon: Icons.info,
              iconColor:AppColor.info,
              title:  context.read<LocaleCubit>().translate('s'),
              content:
              context.read<LocaleCubit>().translate('w'),
            ),
            _animatedInfoCard(
              icon: Icons.check_circle_outline,
              iconColor:AppColor.info,
              title: context.read<LocaleCubit>().translate('a'),
              content:
              '${context.read<LocaleCubit>().translate('q')}\n'
                  '${context.read<LocaleCubit>().translate('z')}\n'
                  '${context.read<LocaleCubit>().translate('r')}\n'
                  '${context.read<LocaleCubit>().translate('d')}\n'
                  '${context.read<LocaleCubit>().translate('f')}',
            ),
            _animatedInfoCard(
              icon: Icons.flag,
              iconColor:AppColor.info,
              title:  context.read<LocaleCubit>().translate('g'),
              content:
              context.read<LocaleCubit>().translate('h'),
            ),

            SizedBox(height: 24.h),

            // ===== Footer =====
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                children: [
                  Text(
                    context.read<LocaleCubit>().translate('developed'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textNeutral,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                   context.read<LocaleCubit>().translate('all'),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColor.textNeutral,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Animated Info Card =====
  Widget _animatedInfoCard({
    required Color iconColor,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColor.backgroundNeutral,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28.sp, color: AppColor.info),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textNeutral,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.6,
                        color: AppColor.textNeutral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
