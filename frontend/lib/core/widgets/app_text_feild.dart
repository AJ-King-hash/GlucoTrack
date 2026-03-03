import 'package:flutter/material.dart';

import '../color/app_color.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final bool isPasswordHidden;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Color? borderColor;
  final Color? labelColor;
  final Color? iconColor;
  final Color? hintColor;
  final String? hintText;
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.suffixIcon,
    this.isPasswordHidden=true,
    this.obscure = false,
    this.validator,
     this.keyboardType = TextInputType.text,
    this.borderColor,
    this.labelColor,
    this.hintColor,
    this.hintText,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? Colors.grey.shade400;
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(color: labelColor ?? AppColor.textNeutral),
        prefixIcon: Icon(icon, color: iconColor ?? AppColor.info),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: color,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
