import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AvatarIcon extends StatelessWidget {
  final bool isUser;
  const AvatarIcon({super.key,required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
    child: CircleAvatar(
      radius: 14,
      backgroundColor: isUser?Colors.green.shade600:Colors.blueAccent.shade200,
      child: Icon(
        isUser?Icons.person:Icons.smart_toy,
        size: 16.sp,
        color: Colors.white,
      ),

    ),);
  }
}
