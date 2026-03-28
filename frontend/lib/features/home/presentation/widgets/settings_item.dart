import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subTitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;
  final Color? subTitleColor;

  const SettingsItem({super.key,
    required this.icon,
    required this.title,
    this.subTitle,
    required this.onTap,
    this.titleColor,
    this.iconColor,
    this.subTitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.blue),
        title: Text(title, style: TextStyle(color: titleColor)),
        subtitle: subTitle != null ? Text(subTitle!, style: TextStyle(color: subTitleColor)) : null,
        trailing: const Icon(Icons.arrow_forward, size: 16),
        onTap: onTap,
      ),
    );
  }
}
