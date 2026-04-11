import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glucotrack/core/color/app_color.dart';
import 'package:glucotrack/core/localization/locale_cubit.dart';
import 'package:glucotrack/core/routes/app_routes.dart';
import 'package:glucotrack/core/widgets/app_button.dart';
import 'package:glucotrack/core/widgets/app_logo.dart';
import 'package:glucotrack/core/widgets/auth_background.dart';
import 'package:glucotrack/core/utils/toast_utility.dart';
import 'package:glucotrack/features/auth/presentaion/widgets/otp_box.dart';

import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';

class OtpPage extends StatefulWidget {
  final String? email;

  const OtpPage({super.key, this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();

  late List<TextEditingController> controllers;
  @override
  void initState() {
    controllers = List.generate(6, (_) => TextEditingController());
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final String email = args is String ? args : '';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpVerifiedSuccess) {
          ToastUtility.showSuccessDismissibleToast(
            context,
            message: state.message,
          );

          Navigator.pushNamed(context, AppRoutes.newPassword, arguments: email);
        }

        if (state is AuthOtpSentSuccess) {
          ToastUtility.showSuccessDismissibleToast(
            context,
            message: state.message,
          );
          for (var controller in controllers) {
            controller.clear();
          }
          if (controllers.isNotEmpty) {
            FocusScope.of(context).requestFocus();
          }
        }

        if (state is AuthError) {
          // Show error toast with retry action
          ToastUtility.showErrorWithRetryToast(
            context,
            message: state.message,
            onRetry: () {
              final allFilled = controllers.every((c) => c.text.isNotEmpty);
              if (allFilled && email.isNotEmpty) {
                final otp = controllers.map((e) => e.text).join();
                cubit.verifyOtp(email: email, otp: otp);
              } else {
                ToastUtility.showErrorDismissibleToast(
                  context,
                  message: context.read<LocaleCubit>().translate(
                    'please_fill_all_fields',
                  ),
                );
              }
            },
          );
        }
      },

      child: Scaffold(
        backgroundColor: AppColor.backgroundNeutral,
        body: AuthBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppLogo(),
                        SizedBox(height: 24.h),
                        Text(
                          context.read<LocaleCubit>().translate(
                            'confirm_account',
                          ),
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textNeutral,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          context.read<LocaleCubit>().translate(
                            'enter_otp_sent',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColor.textNeutral,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 40.h),

                        /// OTP FORM
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  6,
                                  (index) => SizedBox(
                                    width: 40.w,
                                    child: OtpBox(
                                      controller: controllers[index],
                                      autoFocus: index == 0,
                                      onChanged: (value) {
                                        if (value.length == 1 && index < 5) {
                                          FocusScope.of(context).nextFocus();
                                        }
                                      },
                                      validator:
                                          (value) => value!.isEmpty ? '' : null,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 32.h),
                              AppButton(
                                loading: state is AuthLoading,
                                icon: Icons.send,
                                iconColor: AppColor.info,
                                text: context.read<LocaleCubit>().translate(
                                  'confirm',
                                ),
                                height: 50.h,
                                fontSize: 16.sp,
                                textColor: Colors.white,
                                backgroundColor: AppColor.positive,
                                onPressed: () {
                                  if (_formKey.currentState!.validate() &&
                                      email.isNotEmpty) {
                                    final otp =
                                        controllers.map((e) => e.text).join();

                                    cubit.verifyOtp(email: email, otp: otp);
                                  } else {
                                    // Show validation error toast
                                    ToastUtility.showErrorDismissibleToast(
                                      context,
                                      message: context
                                          .read<LocaleCubit>()
                                          .translate('please_fill_all_fields'),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        if (state is AuthLoading)
                          const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.info,
                              ),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: email.isEmpty
                                ? null
                                : () {
                                    context.read<AuthCubit>().forgotPassword(
                                          email: email,
                                        );
                                  },
                            child: Text(
                              context.read<LocaleCubit>().translate('resend_otp'),
                              style: TextStyle(
                                color: email.isEmpty
                                    ? AppColor.textNeutral.withValues(alpha: 0.5)
                                    : AppColor.info,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
