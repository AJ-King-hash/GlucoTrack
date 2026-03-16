import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/api/api_service.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/core/routes/app_routes.dart';
import 'package:untitled10/features/auth/presentaion/manager/auth_cubit.dart';
import 'package:untitled10/features/home/presentation/manager/settings_cubit.dart';
import 'package:untitled10/features/home/presentation/manager/settings_state.dart';
import 'package:untitled10/features/home/presentation/widgets/change_password_bottom_sheet.dart';
import 'package:untitled10/features/home/presentation/widgets/settings_item.dart';
import 'package:untitled10/features/home/presentation/widgets/time_picker_item.dart';
import 'package:untitled10/features/user/presentation/manager/user_cubit.dart';
import 'package:untitled10/features/user/presentation/manager/user_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final settingsCubit = SettingsCubit(ApiService());
        final userState = context.read<UserCubit>().state;
        if (userState is UserLoaded) {
          settingsCubit.loadSettings(userState.userModel);
        }
        return settingsCubit;
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<UserCubit, UserState>(
            listener: (context, state) {
              if (state is UserLoaded) {
                context.read<SettingsCubit>().loadSettings(state.userModel);
              }
            },
          ),
          BlocListener<SettingsCubit, SettingsState>(
            listener: (context, state) {
              if (state is SettingsFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColor.negative,
                  ),
                );
              } else if (state is SettingsInitial && state.isSuccess) {
                // Add isSuccess flag to state
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings updated successfully!'),
                    backgroundColor: AppColor.positive,
                  ),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              context.read<LocaleCubit>().translate('app_title'),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textNeutral,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColor.backgroundNeutral,
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.bell, color: AppColor.info),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
            ],
          ),
          backgroundColor: AppColor.backgroundNeutral,
          body: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SettingsFailure) {
                // Still show the settings UI with the last known state values
                // and display an error message
                return Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.all(16.w),
                      children: [
                        _sectionTitle(
                          context.read<LocaleCubit>().translate('profile'),
                        ),
                        SettingsItem(
                          icon: Icons.person,
                          iconColor: AppColor.info,
                          title: context.read<LocaleCubit>().translate(
                            'edit_profile',
                          ),
                          titleColor: AppColor.textNeutral,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.editProfile);
                          },
                        ),
                        _sectionTitle(
                          context.read<LocaleCubit>().translate('reminders'),
                        ),
                        TimePickerItem(
                          icon: Icons.monitor_heart,
                          iconColor: AppColor.info,
                          title: context.read<LocaleCubit>().translate(
                            'sugar_reminder_time',
                          ),
                          titleColor: AppColor.textNeutral,
                          selectedTime: state.glucoTime,
                          isEnabled: state.sugarReminder,
                          onToggle:
                              (v) => context
                                  .read<SettingsCubit>()
                                  .toggleSugarReminder(v),
                          onTimeSelected:
                              (time) => context
                                  .read<SettingsCubit>()
                                  .updateGlucoTime(time),
                        ),
                        TimePickerItem(
                          icon: Icons.medication,
                          iconColor: AppColor.info,
                          title: context.read<LocaleCubit>().translate(
                            'medicine_reminder_time',
                          ),
                          titleColor: AppColor.textNeutral,
                          selectedTime: state.medicineTime,
                          isEnabled: state.medicineReminder,
                          onToggle: (v) async {
                            context
                                .read<SettingsCubit>()
                                .toggleMedicineReminder(v);
                            try {
                              await context.read<UserCubit>().getUser();
                            } catch (e) {
                              print("errror: " + e.toString());
                            }
                          },
                          onTimeSelected: (time) async {
                            context.read<SettingsCubit>().updateMedicineTime(
                              time,
                            );
                            try {
                              await context.read<UserCubit>().getUser();
                            } catch (e) {
                              print("errror: " + e.toString());
                            }
                          },
                        ),
                        _sectionTitle(
                          context.read<LocaleCubit>().translate('security'),
                        ),
                        SettingsItem(
                          icon: Icons.lock,
                          iconColor: AppColor.info,
                          titleColor: AppColor.textNeutral,
                          title: context.read<LocaleCubit>().translate(
                            'change_password',
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const ChangePasswordBottomSheet(),
                            );
                          },
                        ),
                        _sectionTitle(
                          context.read<LocaleCubit>().translate('about'),
                        ),
                        SettingsItem(
                          icon: Icons.info_outline,
                          iconColor: AppColor.info,
                          titleColor: AppColor.textNeutral,
                          title: context.read<LocaleCubit>().translate(
                            'about_app',
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.aboutApp);
                          },
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.negative,
                            minimumSize: Size(double.infinity, 50.h),
                          ),
                          icon: const Icon(Icons.logout, color: AppColor.info),
                          label: Text(
                            context.read<LocaleCubit>().translate('logout'),
                            style: TextStyle(color: AppColor.textNeutral),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    context.read<LocaleCubit>().translate(
                                      'logout',
                                    ),
                                  ),
                                  content: Text(
                                    context.read<LocaleCubit>().translate(
                                      'are_you_sure_logout',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        context.read<LocaleCubit>().translate(
                                          'cancel',
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        context.read<LocaleCubit>().translate(
                                          'yes',
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        context
                                            .read<AuthCubit>()
                                            .logout(); // NOT awaited
                                        Navigator.pushNamedAndRemoveUntil(
                                          // runs immediately
                                          context,
                                          AppRoutes.login,
                                          (route) => false,
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      top: 16.h,
                      left: 16.w,
                      right: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.negative.withValues(alpha: 0.1),
                          border: Border.all(color: AppColor.negative),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColor.negative,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                state.message,
                                style: TextStyle(
                                  color: AppColor.negative,
                                  fontSize: 14.sp,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            ElevatedButton(
                              onPressed: () {
                                // Retry the failed setting
                                final failedSetting = state.failedSetting;
                                switch (failedSetting) {
                                  case FailedSetting.sugarReminder:
                                    context
                                        .read<SettingsCubit>()
                                        .toggleSugarReminder(
                                          state.sugarReminder,
                                        );
                                    break;
                                  case FailedSetting.medicineReminder:
                                    context
                                        .read<SettingsCubit>()
                                        .toggleMedicineReminder(
                                          state.medicineReminder,
                                        );
                                    break;

                                  case FailedSetting.none:
                                    // Reset to initial state
                                    context
                                        .read<SettingsCubit>()
                                        .toggleSugarReminder(
                                          state.sugarReminder,
                                        );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.positive,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                              ),
                              child: Text(
                                context.read<LocaleCubit>().translate('retry'),
                                style: TextStyle(
                                  color: AppColor.textNeutral,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (state is! SettingsInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _sectionTitle(
                    context.read<LocaleCubit>().translate('profile'),
                  ),
                  SettingsItem(
                    icon: Icons.person,
                    iconColor: AppColor.info,
                    title: context.read<LocaleCubit>().translate(
                      'edit_profile',
                    ),
                    titleColor: AppColor.textNeutral,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.editProfile);
                    },
                  ),
                  _sectionTitle(
                    context.read<LocaleCubit>().translate('reminders'),
                  ),
                  TimePickerItem(
                    icon: Icons.monitor_heart,
                    iconColor: AppColor.info,
                    title: context.read<LocaleCubit>().translate(
                      'sugar_reminder_time',
                    ),
                    titleColor: AppColor.textNeutral,
                    selectedTime: state.glucoTime,
                    isEnabled: state.sugarReminder,
                    onToggle:
                        (v) => context
                            .read<SettingsCubit>()
                            .toggleSugarReminder(v),
                    onTimeSelected:
                        (time) =>
                            context.read<SettingsCubit>().updateGlucoTime(time),
                  ),
                  TimePickerItem(
                    icon: Icons.medication,
                    iconColor: AppColor.info,
                    title: context.read<LocaleCubit>().translate(
                      'medicine_reminder_time',
                    ),
                    titleColor: AppColor.textNeutral,
                    selectedTime: state.medicineTime,
                    isEnabled: state.medicineReminder,
                    onToggle:
                        (v) => context
                            .read<SettingsCubit>()
                            .toggleMedicineReminder(v),
                    onTimeSelected:
                        (time) => context
                            .read<SettingsCubit>()
                            .updateMedicineTime(time),
                  ),

                  _sectionTitle(
                    context.read<LocaleCubit>().translate('security'),
                  ),
                  SettingsItem(
                    icon: Icons.lock,
                    iconColor: AppColor.info,
                    titleColor: AppColor.textNeutral,
                    title: context.read<LocaleCubit>().translate(
                      'change_password',
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const ChangePasswordBottomSheet(),
                      );
                    },
                  ),
                  _sectionTitle(context.read<LocaleCubit>().translate('about')),

                  SettingsItem(
                    icon: Icons.info_outline,
                    iconColor: AppColor.info,
                    titleColor: AppColor.textNeutral,
                    title: context.read<LocaleCubit>().translate('about_app'),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.aboutApp);
                    },
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.negative,
                      minimumSize: Size(double.infinity, 50.h),
                    ),
                    icon: const Icon(Icons.logout, color: AppColor.info),
                    label: Text(
                      context.read<LocaleCubit>().translate('logout'),
                      style: TextStyle(color: AppColor.textNeutral),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              context.read<LocaleCubit>().translate('logout'),
                            ),
                            content: Text(
                              context.read<LocaleCubit>().translate(
                                'are_you_sure_logout',
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  context.read<LocaleCubit>().translate(
                                    'cancel',
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  context.read<LocaleCubit>().translate('yes'),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  context.read<AuthCubit>().logout();
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.login,
                                    (route) => false,
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _sectionTitle(String title) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Accent Medical Bar
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: AppColor.info,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),

        SizedBox(width: 10.w),

        /// Title Text
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: AppColor.textNeutral,
          ),
        ),
      ],
    ),
  );
}
