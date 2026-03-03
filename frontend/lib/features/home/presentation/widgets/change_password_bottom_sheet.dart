import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/color/app_color.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_feild.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState
    extends State<ChangePasswordBottomSheet> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r),
          ),
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
              'تغيير كلمة المرور',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textNeutral,
              ),
            ),
            SizedBox(height: 16.h),

            AppTextField(
              controller: _oldPasswordController,
              label: 'كلمة المرور الحالية',
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
            ),
            SizedBox(height: 12.h),

            AppTextField(
              controller: _newPasswordController,
              label: 'كلمة المرور الجديدة',
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
            ),
            SizedBox(height: 12.h),

            AppTextField(
              controller: _confirmPasswordController,
              label: 'تأكيد كلمة المرور',
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
            ),

            SizedBox(height: 24.h),

            AppButton(
              text: 'حفظ التغييرات',
              icon: Icons.save,
              textColor: Colors.white,
              iconColor: Colors.white,
              backgroundColor: AppColor.positive,
              onPressed: () {

                Navigator.pop(context);
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
