import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/color/app_color.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/show_meal_bottom_sheet.dart';
import '../../../../core/widgets/states/loading_state.dart';
import '../manager/home_cubit.dart';
import '../manager/home_state.dart';
import '../widgets/option_card.dart';
import '../widgets/card_widget.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final locale = context.read<LocaleCubit>();

        // Show loading state with blurred background
        if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                locale.translate('app_title'),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textNeutral,
                ),
              ),
              centerTitle: true,
              backgroundColor: AppColor.backgroundNeutral,
              elevation: 0,
            ),
            body: SafeArea(child: _buildLoadingWithBlur()),
          );
        }

        // Normal content
        return Scaffold(
          backgroundColor: AppColor.info,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              locale.translate('app_title'),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textNeutral,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColor.backgroundNeutral,
            elevation: 0,
            // actions: [
            //   IconButton(
            //     icon: const Icon(CupertinoIcons.bell, color: AppColor.info),
            //     onPressed: () {
            //       Navigator.pushNamed(context, AppRoutes.notifications);
            //     },
            //   ),
            // ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                /// Header Card (Balance / Quick Stats)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: const MedicalHeaderCard(),
                ),

                /// Main Content Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.backgroundNeutral,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 24.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Diabetes Type Selection
                          SizedBox(height: 28.h),

                          /// Timing Relative to Meals
                          buildMedicalSection(
                            title: locale.translate('lasteat'),
                            children: [
                              OptionCard(
                                label: locale.translate('fasting'),
                                icon: Icons.nightlight_round,
                                selected: state.mealTime == 0,
                                onTap:
                                    () async => await context
                                        .read<HomeCubit>()
                                        .updateMealTime(0),
                              ),
                              OptionCard(
                                label: locale.translate('before'),
                                icon: Icons.restaurant,
                                selected: state.mealTime == 1,
                                onTap:
                                    () async => await context
                                        .read<HomeCubit>()
                                        .updateMealTime(1),
                              ),
                              OptionCard(
                                label: locale.translate('after'),
                                icon: Icons.flatware,
                                selected: state.mealTime == 2,
                                onTap:
                                    () async => await context
                                        .read<HomeCubit>()
                                        .updateMealTime(2),
                              ),
                            ],
                          ),

                          SizedBox(height: 28.h),

                          /// Activity Level
                          buildMedicalSection(
                            title: locale.translate('physical'),
                            children: [
                              OptionCard(
                                label: locale.translate('low'),
                                icon: Icons.bed,
                                selected: state.activity == 0,
                                onTap:
                                    () async => await context
                                        .read<HomeCubit>()
                                        .updateActivity(0),
                              ),
                              OptionCard(
                                label: locale.translate('medarate'),
                                icon: Icons.directions_walk,
                                selected: state.activity == 1,
                                onTap:
                                    () async => await context
                                        .read<HomeCubit>()
                                        .updateActivity(1),
                              ),
                              OptionCard(
                                label: locale.translate('high_activity'),
                                icon: Icons.directions_run,
                                selected: state.activity == 2,
                                onTap:
                                    () async => await context
                                        .read<HomeCubit>()
                                        .updateActivity(2),
                              ),
                            ],
                          ),

                          SizedBox(height: 24.h),
                          _buildAnalyzeButton(context, locale),

                          SizedBox(height: 20.h),
                          _buildRiskManagementButton(context, locale),

                          SizedBox(
                            height: 40.h,
                          ), // Extra padding for bottom scroll
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build loading state with light blurred background
  Widget _buildLoadingWithBlur() {
    return Stack(
      children: [
        // Light blurred background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.white.withValues(alpha: 0.3)),
        ),
        // Loading indicator in center
        const Center(child: LoadingState(message: 'Loading...')),
      ],
    );
  }
}

Widget _buildAnalyzeButton(BuildContext context, LocaleCubit locale) {
  return SizedBox(
    width: double.infinity,
    height: 55.h,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.positive,
        foregroundColor: AppColor.textNeutral,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 4,
      ),
      icon: const Icon(Icons.analytics_outlined),
      label: Text(
        locale.translate('resultAna'),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
      ),
      onPressed: () => showMealBottomSheet(context),
    ),
  );
}

Widget _buildRiskManagementButton(BuildContext context, LocaleCubit locale) {
  return SizedBox(
    width: double.infinity,
    height: 55.h,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.info,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 4,
      ),
      icon: const Icon(Icons.warning_amber_rounded),
      label: Text(
        locale.translate('risk_factors'),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
      ),
      onPressed: () => Navigator.pushNamed(context, AppRoutes.risk),
    ),
  );
}

/// Helper function for section styling
Widget buildMedicalSection({
  required String title,
  required List<Widget> children,
}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: AppColor.info,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textNeutral,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...children.map(
          (child) =>
              Padding(padding: EdgeInsets.only(bottom: 12.h), child: child),
        ),
      ],
    ),
  );
}
