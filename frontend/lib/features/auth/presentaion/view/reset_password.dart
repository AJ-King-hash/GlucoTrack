import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_feild.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/states/error_state.dart';
import '../../../../core/widgets/states/loading_state.dart';
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
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم إرسال رمز التحقق إلى بريدك الإلكتروني"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushNamed(
            context,
            AppRoutes.otp,
            arguments: emailController.text.trim(),
          );
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return Scaffold(
            backgroundColor: AppColor.backgroundNeutral,
            body: AuthBackground(
              child: SafeArea(
                child: Center(
                  child: const LoadingState(message: 'Sending reset code...'),
                ),
              ),
            ),
          );
        }
        if (state is AuthError) {
          return Scaffold(
            backgroundColor: AppColor.backgroundNeutral,
            body: AuthBackground(
              child: SafeArea(
                child: Center(
                  child: ErrorState(
                    message: state.message,
                    onActionPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // context.read<AuthCubit>().forgotPassword(
                        //   emailController.text.trim(),
                        // );
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        }
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
                          "إعادة تعيين كلمة المرور",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.info,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        Text(
                          "أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColor.textNeutral,
                          ),
                        ),

                        SizedBox(height: 40.h),

                        AppTextField(
                          controller: emailController,
                          label: "البريد الإلكتروني",
                          icon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return 'يرجى إدخال بريد إلكتروني صحيح';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 30.h),

                        AppButton(
                          icon: Icons.send,
                          iconColor: AppColor.info,
                          text: "إرسال الرمز",
                          backgroundColor: AppColor.positive,
                          textColor: AppColor.textNeutral,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // context.read<AuthCubit>().forgotPassword(
                              //   emailController.text.trim(),
                              // );
                            }
                          },
                        ),

                        SizedBox(height: 20.h),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "العودة إلى تسجيل الدخول",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColor.warning,
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
