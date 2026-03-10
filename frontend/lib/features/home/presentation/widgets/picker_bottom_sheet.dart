import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import '../../../../core/color/app_color.dart';

Future<void> showNumberPickerBottomSheet({
  required BuildContext context,
  required String title,
  required int initialValue,
  required int min,
  required int max,
  required String unit,
  required Function(int) onSave,
}) async {
  int selectedValue = initialValue;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        height: 360.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColor.backgroundNeutral,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColor.textNeutral.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textNeutral,
              ),
            ),

            SizedBox(height: 24.h),

            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: initialValue - min,
                ),
                itemExtent: 44.h,
                onSelectedItemChanged: (index) {
                  selectedValue = min + index;
                },
                children: List.generate(
                  max - min + 1,
                  (index) => Center(
                    child: Text(
                      '${min + index} $unit',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: AppColor.textNeutral,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  onSave(selectedValue);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.positive,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(
                  context.read<LocaleCubit>().translate('save'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
