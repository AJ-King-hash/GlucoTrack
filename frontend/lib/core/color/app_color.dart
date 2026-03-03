import 'package:flutter/material.dart';

class AppColor {
  // Neutrals - الألوان المحايدة للنصوص والخلفيات
  static const textNeutral = Color(0xFF4A4A4A);        // رمادي داكن للنصوص
  static const backgroundNeutral = Color(0xFFF5F7FA);  // خلفية فاتحة مريحة للعين
  static const cardBackground = Color(0xFFFFFFFF);     // خلفية البطاقات البيضاء
  static const borderNeutral = Color(0xFFE0E0E0);      // حدود ناعمة

  // Semantic Colors - ألوان المعنى والحالة
  static const positive = Color(0xFF28A745);           // أخضر للطاقة الصحية والنجاح
  static const negative = Color(0xFFDC3545);           // أحمر للتحذيرات والأخطاء
  static const warning = Color(0xFFFFC107);            // أصفر للتحذيرات الطفيفة
  static const info = Color(0xFF007BFF);               // أزرق طبي للرموز الرئيسية والإشعارات
  static const special = Color(0xFF6F42C1);            // بنفسجي للعناصر الخاصة أو مميزة

  // Optional: subtle shades for backgrounds / highlights
  static const lightBlueBackground = Color(0xFFE9F2FF);  // خلفية فاتحة لعناصر زرقاء
  static const lightGreenBackground = Color(0xFFE6F4EA); // خلفية فاتحة لعناصر صحية
}