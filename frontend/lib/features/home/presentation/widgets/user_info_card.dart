import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/color/app_color.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../manager/home_state.dart';

class UserInfoCard extends StatelessWidget {
  final int age;
  final int weight;
  final Gender? gender;
  final MaritalStatus? maritalStatus;
  final int pregnancyCount;
  final VoidCallback onAgeTap;
  final VoidCallback onWeightTap;
  final ValueChanged<Gender> onGenderChanged;
  final ValueChanged<MaritalStatus> onMaritalStatusChanged;
  final ValueChanged<int> onPregnancyCountChanged;

  const UserInfoCard({
    super.key,
    required this.age,
    required this.weight,
    required this.gender,
    required this.maritalStatus,
    required this.pregnancyCount,
    required this.onAgeTap,
    required this.onWeightTap,
    required this.onGenderChanged,
    required this.onMaritalStatusChanged,
    required this.onPregnancyCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColor.info.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.translate('user_data'),
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textNeutral,
            ),
          ),
          SizedBox(height: 20.h),

          /// Age & Weight Row
          Row(
            children: [
              _infoItem(
                label: locale.translate('age'),
                value: locale
                    .translate('age_years')
                    .replaceAll('{age}', age.toString()),
                icon: Icons.cake,
                onTap: onAgeTap,
              ),
              SizedBox(width: 16.w),
              _infoItem(
                label: locale.translate('weight'),
                value: locale
                    .translate('weight_kg')
                    .replaceAll('{weight}', weight.toString()),
                icon: Icons.monitor_weight,
                onTap: onWeightTap,
              ),
            ],
          ),

          SizedBox(height: 20.h),

          /// Gender Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ChoiceChip(
                label: Text(locale.translate('male')),
                selected: gender == Gender.male,
                onSelected: (_) => onGenderChanged(Gender.male),
              ),
              SizedBox(width: 10.w),
              ChoiceChip(
                label: Text(locale.translate('female')),
                selected: gender == Gender.female,
                onSelected: (_) => onGenderChanged(Gender.female),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          /// Marital Status (Only if female)
          if (gender == Gender.female)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ChoiceChip(
                  label: Text(locale.translate('single')),
                  selected: maritalStatus == MaritalStatus.single,
                  onSelected:
                      (_) => onMaritalStatusChanged(MaritalStatus.single),
                ),
                SizedBox(width: 10.w),
                ChoiceChip(
                  label: Text(locale.translate('married')),
                  selected: maritalStatus == MaritalStatus.married,
                  onSelected:
                      (_) => onMaritalStatusChanged(MaritalStatus.married),
                ),
              ],
            ),

          SizedBox(height: 16.h),

          /// Pregnancy Count (Only if married female)
          if (gender == Gender.female && maritalStatus == MaritalStatus.married)
            Row(
              children: [
                Text('${locale.translate('pregnancy_count')}: $pregnancyCount'),
                SizedBox(width: 10.w),
                IconButton(
                  onPressed: () => onPregnancyCountChanged(pregnancyCount + 1),
                  icon: Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () {
                    if (pregnancyCount > 0) {
                      onPregnancyCountChanged(pregnancyCount - 1);
                    }
                  },
                  icon: Icon(Icons.remove),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoItem({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.info.withOpacity(0.15),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColor.info.withOpacity(0.4),
                      AppColor.info.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: AppColor.info, size: 24.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.textNeutral.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textNeutral,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
