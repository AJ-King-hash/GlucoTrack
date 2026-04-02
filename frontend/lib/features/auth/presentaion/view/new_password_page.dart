import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:glucotrack/core/color/app_color.dart';
import 'package:glucotrack/core/localization/locale_cubit.dart';
import 'package:glucotrack/core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_feild.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/utils/toast_utility.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';

class NewPasswordPage extends StatelessWidget {
  final String email;
  NewPasswordPage({super.key, required this.email});

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Show success toast
          ToastUtility.showSuccessDismissibleToast(
            context,
            message: state.message,
          );

          // Navigate after delay to allow toast to show
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (context.mounted) {
              context.read<AuthCubit>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            }
          });
        }
        if (state is AuthError) {
          // Show error toast with retry action
          ToastUtility.showErrorWithRetryToast(
            context,
            message: state.message,
            onRetry: () {
              if (_formKey.currentState!.validate()) {
                context.read<AuthCubit>().resetPassword(
                  email,
                  newPasswordController.text.trim(),
                );
              }
            },
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColor.backgroundNeutral,
          body: AuthBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.h),
                        const AppLogo(),
                        SizedBox(height: 24.h),

                        Text(
                          context.read<LocaleCubit>().translate(
                            'reset_your_password',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.info,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        Text(
                          context.read<LocaleCubit>().translate(
                            'enter_new_password_desc',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColor.textNeutral,
                          ),
                        ),

                        SizedBox(height: 40.h),

                        AppTextField(
                          controller: newPasswordController,
                          label: context.read<LocaleCubit>().translate(
                            'new_password',
                          ),
                          icon: Icons.lock,
                          obscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.read<LocaleCubit>().translate(
                                'please_enter_new_password',
                              );
                            }
                            if (value.length < 6) {
                              return context.read<LocaleCubit>().translate(
                                'password_too_short',
                              );
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        AppTextField(
                          controller: confirmPasswordController,
                          label: context.read<LocaleCubit>().translate(
                            'confirm_password',
                          ),
                          icon: Icons.lock_outline,
                          obscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.read<LocaleCubit>().translate(
                                'please_confirm_password',
                              );
                            }
                            if (value != newPasswordController.text) {
                              return context.read<LocaleCubit>().translate(
                                'passwords_do_not_match',
                              );
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 30.h),

                        AppButton(
                          loading: state is AuthLoading,
                          icon: Icons.lock_reset,
                          iconColor: AppColor.info,
                          text: context.read<LocaleCubit>().translate(
                            'password_reset_button',
                          ),
                          backgroundColor: AppColor.positive,
                          textColor: AppColor.textNeutral,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().resetPassword(
                                email,
                                newPasswordController.text.trim(),
                              );
                            } else {
                              // Show validation error toast
                              ToastUtility.showErrorDismissibleToast(
                                context,
                                message: context.read<LocaleCubit>().translate(
                                  'please_fill_all_fields',
                                ),
                              );
                            }
                          },
                        ),

                        SizedBox(height: 20.h),

                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (route) => false,
                            );
                          },
                          child: Text(
                            context.read<LocaleCubit>().translate(
                              'back_to_login',
                            ),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColor.info,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
