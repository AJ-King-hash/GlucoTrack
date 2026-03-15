import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/routes/app_routes.dart';
import 'package:untitled10/core/widgets/app_button.dart';
import 'package:untitled10/core/widgets/app_logo.dart';
import 'package:untitled10/core/widgets/auth_background.dart';
import 'package:untitled10/core/widgets/states/error_state.dart';
import 'package:untitled10/core/widgets/states/loading_state.dart';
import 'package:untitled10/features/auth/presentaion/widgets/otp_box.dart';

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
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                    if (state is AuthLoading) {
                      return const LoadingState(message: 'Verifying OTP...');
                    }
                    if (state is AuthError) {
                      return ErrorState(
                        message: state.message,
                        onActionPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final otp = controllers.map((e) => e.text).join();
                            cubit.verifyOtp(widget.email!, otp);
                          }
                        },
                      );
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppLogo(),
                        SizedBox(height: 24.h),
                        Text(
                          "تأكيد الحساب",
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textNeutral,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "أدخل رمز التحقق المرسل إلى بريدك الإلكتروني",
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
                                icon: Icons.send,
                                iconColor: AppColor.info,
                                text: "تأكيد",
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
                            "إعادة إرسال الرمز",
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
