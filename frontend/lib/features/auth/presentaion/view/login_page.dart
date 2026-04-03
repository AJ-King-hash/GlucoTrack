import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:glucotrack/core/color/app_color.dart';
import 'package:glucotrack/core/localization/locale_cubit.dart';
import 'package:glucotrack/core/routes/app_routes.dart';
import 'package:glucotrack/core/widgets/app_button.dart';
import 'package:glucotrack/core/widgets/app_text_feild.dart';
import 'package:glucotrack/core/widgets/language_bottom_sheet.dart';
import 'package:glucotrack/core/utils/toast_utility.dart';
import 'package:glucotrack/features/user/presentation/manager/user_cubit.dart';
import 'package:glucotrack/features/auth/presentaion/manager/auth_cubit.dart';
import '../manager/auth_state.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundNeutral,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8.h,
              left: 8.w,
              child: InkWell(
                onTap: () {
                  showLanguageBottomSheet(context);
                },
                child: Icon(Icons.language, color: AppColor.info),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Lottie.asset(
                        'assets/lottie/Welcome Animation.json',
                        height: 300.h,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        context.read<LocaleCubit>().translate('welcome_back'),
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.info,
                        ),
                      ),
                      SizedBox(height: 32.h),
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
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: passwordController,
                        label: context.read<LocaleCubit>().translate(
                          'password',
                        ),
                        icon: Icons.lock,
                        obscure: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.read<LocaleCubit>().translate(
                              'password_required',
                            );
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.resetPassword,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 30.h),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            context.read<LocaleCubit>().translate(
                              'forgot_password',
                            ),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColor.info,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          // FIX: Only react to Login Success here
                          if (state is AuthLoginSuccess) {
                            ToastUtility.showSuccessDismissibleToast(
                              context,
                              message: state.message,
                            );

                            if (state.user != null) {
                              context.read<UserCubit>().setUser(state.user!);
                            }

                            Future.delayed(
                              const Duration(milliseconds: 3500),
                              () {
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.home,
                                  );
                                }
                              },
                            );
                          }

                          if (state is AuthError) {
                            ToastUtility.showErrorWithRetryToast(
                              context,
                              message: state.message,
                              onRetry: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().login(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );
                                }
                              },
                            );
                          }
                        },
                        builder: (context, state) {
                          return AppButton(
                            loading: state is AuthLoading,
                            text: context.read<LocaleCubit>().translate(
                              'login',
                            ),
                            icon: Icons.login,
                            iconColor: AppColor.info,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().login(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.read<LocaleCubit>().translate(
                              'dont_have_account',
                            ),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColor.textNeutral,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
                            child: Text(
                              " ${context.read<LocaleCubit>().translate('register')}",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
