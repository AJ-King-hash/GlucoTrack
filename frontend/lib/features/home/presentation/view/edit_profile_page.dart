import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/features/auth/data/models/user_model.dart';
import 'package:untitled10/features/user/presentation/manager/user_cubit.dart';
import 'package:untitled10/features/user/presentation/manager/user_state.dart';

import '../../../../core/color/app_color.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/utils/toast_utility.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_feild.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel? userModel;
  const EditProfilePage({super.key, this.userModel});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  StreamSubscription? _userSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.userModel != null) {
      nameController.text = widget.userModel!.name;
      emailController.text = widget.userModel!.email;
    } else {
      context.read<UserCubit>().getUser();
      _userSubscription = context.read<UserCubit>().stream.listen((state) {
        if (state is UserLoaded) {
          final user = state.userModel;
          print("user: " + user.toString());
          nameController.text = user.name;
          emailController.text = user.email;
        }
      });
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      ToastUtility.showErrorDismissibleToast(
        context,
        message: 'Name cannot be empty',
      );
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      ToastUtility.showErrorDismissibleToast(
        context,
        message: 'Email cannot be empty',
      );
      return false;
    }

    return true;
  }

  Future<void> _updateProfile() async {
    if (!_validateForm()) return;

    try {
      await context.read<UserCubit>().updateUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: '',
      );
    } catch (e) {
      if (mounted) {
        ToastUtility.showErrorDismissibleToast(
          context,
          message: 'Failed to update profile',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserSuccess) {
          // Profile updated successfully - only fires on update, not on page load
          ToastUtility.showSuccessDismissibleToast(
            context,
            message: state.message,
          );
        } else if (state is UserError) {
          // Show error toast
          ToastUtility.showErrorDismissibleToast(
            context,
            message: state.message,
          );
        }
      },
      child: RefreshIndicator(
        color: Colors.white,
        backgroundColor: AppColor.positive,
        displacement: 60,
        onRefresh: () async {
          await context.read<UserCubit>().getUser();
        },
        child: Scaffold(
          backgroundColor: AppColor.backgroundNeutral,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColor.backgroundNeutral,
            centerTitle: true,
            title: Text(
              context.read<LocaleCubit>().translate('edit_profile'),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textNeutral,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  CupertinoIcons.bell,
                  color: AppColor.info,
                  size: 22.sp,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 32.h),
                  //form card
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 22.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        /// Name
                        AppTextField(
                          controller: nameController,
                          label: context.read<LocaleCubit>().translate(
                            'full_name',
                          ),
                          icon: Icons.person_outline,
                          iconColor: AppColor.info,
                          labelColor: AppColor.textNeutral,
                        ),
                        SizedBox(height: 18.h),

                        /// Email
                        AppTextField(
                          controller: emailController,
                          label: context.read<LocaleCubit>().translate('email'),
                          icon: Icons.email_outlined,
                          iconColor: AppColor.info,
                          labelColor: AppColor.textNeutral,
                        ),
                        SizedBox(height: 18.h),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),
                  //button for save
                  SizedBox(
                    height: 54.h,
                    child: AppButton(
                      text: context.read<LocaleCubit>().translate('save'),
                      icon: Icons.save_outlined,
                      textColor: AppColor.textNeutral,
                      iconColor: AppColor.info,
                      backgroundColor: AppColor.positive,
                      onPressed: () {
                        _updateProfile();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
