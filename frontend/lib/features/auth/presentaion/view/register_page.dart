import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:untitled10/features/user/presentation/manager/user_cubit.dart';
import 'package:untitled10/features/user/presentation/manager/user_state.dart';
import '../../../../core/color/app_color.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_feild.dart';
import '../../../../core/utils/toast_utility.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundNeutral,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
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
                  context.read<LocaleCubit>().translate('register'),
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.info,
                  ),
                ),
                SizedBox(height: 24.h),
                AppTextField(
                  controller: nameController,
                  label: context.read<LocaleCubit>().translate('full_name'),
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.read<LocaleCubit>().translate(
                        'name_required',
                      );
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
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
                  label: context.read<LocaleCubit>().translate('password'),
                  icon: Icons.lock,
                  obscure: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return context.read<LocaleCubit>().translate(
                        'password_too_short',
                      );
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                BlocConsumer<UserCubit, UserState>(
                  listener: (context, state) {
                    if (state is UserSuccess) {
                      // Show success toast
                      ToastUtility.showSuccessDismissibleToast(
                        context,
                        message: state.message,
                      );
                      // Navigate to login after a brief delay
                      Future.delayed(const Duration(milliseconds: 3500), () {
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        }
                      });
                    }
                    if (state is UserError) {
                      // Show error toast with retry action
                      ToastUtility.showErrorWithRetryToast(
                        context,
                        message: state.message,
                        onRetry: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<UserCubit>().createUser(
                              name: nameController.text.trim(),
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
                      loading: state is UserLoading,
                      iconColor: AppColor.info,
                      text: context.read<LocaleCubit>().translate('register'),
                      icon: Icons.person_add,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<UserCubit>().createUser(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
