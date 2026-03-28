import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/color/app_color.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_feild.dart';
import '../../../../features/user/presentation/manager/user_cubit.dart';
import '../../../../features/user/presentation/manager/user_state.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  bool _validatePasswords() {
    // Validate old password is not empty
    if (_oldPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleCubit>().translate('please_enter_old_password'),
          ),
          backgroundColor: AppColor.negative,
        ),
      );
      return false;
    }

    if (_newPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleCubit>().translate('please_enter_new_password'),
          ),
          backgroundColor: AppColor.negative,
        ),
      );
      return false;
    }

    if (_newPasswordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleCubit>().translate('password_too_short'),
          ),
          backgroundColor: AppColor.negative,
        ),
      );
      return false;
    }

    if (_confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleCubit>().translate('please_confirm_password'),
          ),
          backgroundColor: AppColor.negative,
        ),
      );
      return false;
    }

    if (_newPasswordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleCubit>().translate('passwords_do_not_match'),
          ),
          backgroundColor: AppColor.negative,
        ),
      );
      return false;
    }

    if (_newPasswordController.text.trim() ==
        _oldPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleCubit>().translate('new_password_same'),
          ),
          backgroundColor: AppColor.negative,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _changePassword() async {
    if (!_validatePasswords()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get the current user from the cubit
      final userState = context.read<UserCubit>().state;

      if (userState is! UserLoaded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<LocaleCubit>().translate('password_change_failed'),
              ),
              backgroundColor: AppColor.negative,
            ),
          );
        }
        return;
      }

      final currentUser = userState.userModel;

      // Call the updateUser method with current data and new password
      // Note: This implementation assumes the backend handles old password verification
      await context.read<UserCubit>().updateUser(
        name: currentUser.name,
        email: currentUser.email,
        password: _newPasswordController.text.trim(),
        oldPassword: _oldPasswordController.text.trim(),
      );

      // Check the state after the update (captured after await)
      if (!mounted) return;
      final newState = context.read<UserCubit>().state;

      if (newState is UserError) {
        // Show the error message from the API (e.g., "Incorrect old password")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newState.message),
            backgroundColor: AppColor.negative,
          ),
        );
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LocaleCubit>().translate(
                'password_changed_successfully',
              ),
            ),
            backgroundColor: AppColor.positive,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LocaleCubit>().translate('password_change_failed'),
            ),
            backgroundColor: AppColor.negative,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColor.backgroundNeutral,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColor.textNeutral,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              context.read<LocaleCubit>().translate('change_password'),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textNeutral,
              ),
            ),
            SizedBox(height: 16.h),

            AppTextField(
              controller: _oldPasswordController,
              label: context.read<LocaleCubit>().translate('old_password'),
              icon: Icons.lock_outline,
              obscure: _obscureOld,
              borderColor: Colors.grey,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOld ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.info,
                ),
                onPressed: () {
                  setState(() => _obscureOld = !_obscureOld);
                },
              ),
              enabled: !_isLoading,
            ),
            SizedBox(height: 12.h),

            AppTextField(
              controller: _newPasswordController,
              label: context.read<LocaleCubit>().translate('new_password'),
              icon: Icons.lock,
              obscure: _obscureNew,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.info,
                ),
                onPressed: () {
                  setState(() => _obscureNew = !_obscureNew);
                },
              ),
              enabled: !_isLoading,
            ),
            SizedBox(height: 12.h),

            AppTextField(
              controller: _confirmPasswordController,
              label: context.read<LocaleCubit>().translate('confirm_password'),
              icon: Icons.lock,
              obscure: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.info,
                ),
                onPressed: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),
              enabled: !_isLoading,
            ),

            SizedBox(height: 24.h),

            AppButton(
              text: context.read<LocaleCubit>().translate('save_changes'),
              icon: Icons.save,
              textColor: Colors.white,
              iconColor: Colors.white,
              backgroundColor: AppColor.positive,
              onPressed: _isLoading ? null : _changePassword,
              loading: _isLoading,
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
