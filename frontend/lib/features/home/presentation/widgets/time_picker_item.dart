import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/color/app_color.dart';
import '../../../../core/localization/locale_cubit.dart';

class TimePickerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? selectedTime;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final Color? titleColor;
  final Color? iconColor;

  const TimePickerItem({
    super.key,
    required this.icon,
    required this.title,
    this.selectedTime,
    required this.isEnabled,
    required this.onToggle,
    required this.onTimeSelected,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColor.info),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? AppColor.textNeutral,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: isEnabled ? () => _showTimePicker(context) : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isEnabled
                                ? AppColor.info.withValues(alpha: 0.1)
                                : AppColor.textNeutral.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color:
                              isEnabled
                                  ? AppColor.info
                                  : AppColor.textNeutral.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16.sp,
                            color:
                                isEnabled
                                    ? AppColor.info
                                    : AppColor.textNeutral.withValues(
                                      alpha: 0.5,
                                    ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            selectedTime ?? '--:--',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  isEnabled
                                      ? AppColor.info
                                      : AppColor.textNeutral.withValues(
                                        alpha: 0.5,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeThumbColor: AppColor.positive,
              inactiveThumbColor: AppColor.textNeutral.withValues(alpha: 0.6),
              inactiveTrackColor: AppColor.textNeutral.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context) {
    TimeOfDay initialTime = const TimeOfDay(hour: 8, minute: 0);

    if (selectedTime != null && selectedTime!.contains(':')) {
      final parts = selectedTime!.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          initialTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        TimeOfDay pickedTime = initialTime;

        return Container(
          height: 320.h,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColor.textNeutral.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        context.read<LocaleCubit>().translate('cancel'),
                        style: TextStyle(
                          color: AppColor.textNeutral,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    Text(
                      context.read<LocaleCubit>().translate('select_time'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textNeutral,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onTimeSelected(pickedTime);
                        Navigator.pop(context);
                      },
                      child: Text(
                        context.read<LocaleCubit>().translate('save'),
                        style: TextStyle(
                          color: AppColor.positive,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime dateTime) {
                    pickedTime = TimeOfDay(
                      hour: dateTime.hour,
                      minute: dateTime.minute,
                    );
                  },
                  use24hFormat: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
