import 'package:flutter/material.dart';

class HealthUtils {
  static String getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'bmi_underweight';
    if (bmi < 25) return 'bmi_normal';
    if (bmi < 30) return 'bmi_overweight';
    return 'bmi_obese';
  }

  static Color getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.amber;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}
