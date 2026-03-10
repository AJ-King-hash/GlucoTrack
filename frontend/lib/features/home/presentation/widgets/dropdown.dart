import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final FormFieldValidator<String>? validator;

  const Dropdown({
    super.key,
    required this.label,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
