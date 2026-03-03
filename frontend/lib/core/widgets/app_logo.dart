import 'package:flutter/material.dart';
import '../color/app_color.dart';

class AppLogo extends StatelessWidget {
  final String? imagePath;
  final double size;

  const AppLogo({
    super.key,
    this.imagePath,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final String logoPath = imagePath ?? 'assets/images/logo.png';

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval( // يضمن أن الصورة دائرية وتشغل كل المساحة
        child: Image.asset(
          logoPath,
          fit: BoxFit.cover, // الصورة تملأ كامل المساحة
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Color(0xFFB3E5FC), // لون خلفية احتياطي
            alignment: Alignment.center,
            child: Icon(
              Icons.water_drop,
              color: AppColor.positive,
              size: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
