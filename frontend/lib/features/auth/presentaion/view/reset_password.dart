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

class ResetPasswordPage extends StatelessWidget {
  ResetPasswordPage({super.key});

  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // FIX: Only react to OTP Sent here
        if (state is AuthOtpSentSuccess) {
          ToastUtility.showSuccessDismissibleToast(
            context,
            message: state.message,
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.pushNamed(
                context,
                AppRoutes.otp,
                arguments: emailController.text.trim(),
              );
            }
          });
        }

        if (state is AuthError) {
          ToastUtility.showErrorWithRetryToast(
            context,
            message: state.message,
            onRetry:
                () => context.read<AuthCubit>().forgotPassword(
                  email: emailController.text.trim(),
                ),
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
                            'reset_password',
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
                            'enter_email_for_otp',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColor.textNeutral,
                          ),
                        ),

                        SizedBox(height: 40.h),

                        AppTextField(
                          controller: emailController,
                          label: context.read<LocaleCubit>().translate('email'),
                          icon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.read<LocaleCubit>().translate(
                                'email_required',
                              );
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return context.read<LocaleCubit>().translate(
                                'invalid_email',
                              );
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 30.h),

                        AppButton(
                          loading: state is AuthLoading,
                          icon: Icons.send,
                          iconColor: AppColor.info,
                          text: context.read<LocaleCubit>().translate(
                            'send_code',
                          ),
                          backgroundColor: AppColor.positive,
                          textColor: AppColor.textNeutral,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().forgotPassword(
                                email: emailController.text.trim(),
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
                            Navigator.pop(context);
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
