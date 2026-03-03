import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/color/app_color.dart';

class SwitchItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? titleColor;
  final Color? iconColor;

  const SwitchItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.titleColor,
    this.iconColor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColor.info),
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeColor: AppColor.positive, // لون عند تشغيل التبديل
        inactiveThumbColor: AppColor.textNeutral.withOpacity(0.6), // لون المؤشر عند الايقاف
        inactiveTrackColor: AppColor.textNeutral.withOpacity(0.3),
      ),
    );
  }
}
