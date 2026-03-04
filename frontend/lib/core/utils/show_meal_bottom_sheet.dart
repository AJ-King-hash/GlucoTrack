import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/core/widgets/app_button.dart';
import 'package:untitled10/core/widgets/app_text_feild.dart';

void showMealBottomSheet(BuildContext context) {
  final TextEditingController mealDescription = TextEditingController();
  String selectedMealType = 'fasting';
  TimeOfDay? selectedMealTime;
  String getMealDescription(String mealType, BuildContext context) {
    final cubit = context.read<LocaleCubit>();
    switch (mealType) {
      case 'fasting':
        return cubit.translate('fasting_desc');
      case 'before':
        return cubit.translate('before_desc');
      case 'after':
        return cubit.translate('after_desc');
      default:
        return '';
    }
  }

  String getMealTimeLabel(BuildContext context, String mealType) {
    final cubit = context.read<LocaleCubit>();

    switch (mealType) {
      case 'before':
        return cubit.translate('before_time');
      case 'after':
        return cubit.translate('after_time');
      case 'fasting':
      default:
        return cubit.translate('fasting_time');
    }
  }

  Future<void> pickMealTime(
    BuildContext context,
    Function(TimeOfDay) onPicked,
  ) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      onPicked(time);
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.read<LocaleCubit>().translate('mealInfo'),
                  style: const TextStyle(
                    color: AppColor.textNeutral,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  initialValue: selectedMealType,
                  decoration: InputDecoration(
                    labelText: context.read<LocaleCubit>().translate(
                      'mealType',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'fasting',
                      child: Text(
                        context.read<LocaleCubit>().translate('fasting'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'before',
                      child: Text(
                        context.read<LocaleCubit>().translate('before'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'after',
                      child: Text(
                        context.read<LocaleCubit>().translate('after'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMealType = value!;
                      mealDescription.text = getMealDescription(
                        selectedMealType,
                        context,
                      );
                      selectedMealTime = null;
                    });
                  },
                ),
                SizedBox(height: 16.h),

                InkWell(
                  onTap: () {
                    pickMealTime(context, (time) {
                      setState(() {
                        selectedMealTime = time;
                      });
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 12),
                        Text(
                          selectedMealTime == null
                              ? getMealTimeLabel(context, selectedMealType)
                              : selectedMealTime!.format(context),
                          style: TextStyle(
                            color:
                                selectedMealTime == null
                                    ? Colors.grey
                                    : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                AppTextField(
                  controller: mealDescription,
                  label: getMealDescription(selectedMealType, context),
                  icon: Icons.food_bank_outlined,
                ),
                SizedBox(height: 10.h),
                //submit Button
                AppButton(
                  text: context.read<LocaleCubit>().translate('submit'),
                  onPressed: () {},
                  icon: Icons.send,
                  iconColor: AppColor.info,
                ),
                SizedBox(height: 8.h),
              ],
            );
          },
        ),
      );
    },
  );
}
