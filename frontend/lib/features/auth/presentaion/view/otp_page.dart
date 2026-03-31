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
    controllers = List.generate(4, (_) => TextEditingController());
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Show success toast
          ToastUtility.showSuccessDismissibleToast(
            context,
            message: state.message,
          );
          // Navigate after a brief delay
          Future.delayed(const Duration(milliseconds: 3500), () {
            if (context.mounted) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.newPassword,
                arguments: widget.email,
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
                final otp = controllers.map((e) => e.text).join();
                cubit.verifyOtp(widget.email!, otp);
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
                                  4,
                                  (index) => SizedBox(
                                    width: 65.w,
                                    child: OtpBox(
                                      controller: controllers[index],
                                      autoFocus: index == 0,
                                      onChanged: (value) {
                                        if (value.length == 1 && index < 3) {
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
                                  if (_formKey.currentState!.validate()) {
                                    final otp =
                                        controllers.map((e) => e.text).join();
                                    cubit.verifyOtp(widget.email!, otp);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        TextButton(
                          onPressed: () {
                            cubit.close();
                          },
                          child: Text(
                            context.read<LocaleCubit>().translate('resend_otp'),
                            style: TextStyle(
                              color: AppColor.warning,
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
