import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/color/app_color.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_feild.dart';
import '../../../../features/archives/presentaiton/manager/archives_cubit.dart';
import '../../../../features/archives/presentaiton/manager/archives_state.dart';
import '../../../../features/archives/data/model/archives_model.dart';
import '../../../../features/archives/data/model/meal_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/injection_container.dart';
import '../../../../features/meal/repo/meal_repository.dart';

/// Maps backend meal type to frontend string value
String _mapBackendMealTypeToString(String mealType) {
  switch (mealType) {
    case 'Fast':
      return 'fasting';
    case 'Before Meal':
      return 'before';
    case 'After Meal':
      return 'after';
    default:
      return 'fasting';
  }
}

/// Maps frontend string value to backend meal type
String _mapMealTypeToBackend(String mealType) {
  switch (mealType) {
    case 'fasting':
      return 'Fast';
    case 'before':
      return 'Before Meal';
    case 'after':
      return 'After Meal';
    default:
      return 'Fast';
  }
}

void showMealBottomSheet(BuildContext context) async {
  String selectedMealType = 'fasting';

  // 1. Fetch last meal pre-selection logic
  try {
    final mealRepo = sl<MealRepository>();
    final result = await mealRepo.getLastMeal();

    if (!context.mounted) return;

    result.fold((failure) {}, (lastMeal) {
      if (lastMeal != null) {
        selectedMealType = _mapBackendMealTypeToString(lastMeal.mealType);
      }
    });
  } catch (e) {
    debugPrint("Error fetching last meal: $e");
  }

  if (!context.mounted) return;

  // 2. Local variables for the sheet
  final TextEditingController mealDescription = TextEditingController();
  TimeOfDay? selectedMealTime;

  // Helper translations
  String getMealDescription(String mealType, BuildContext context) {
    final cubit = context.read<LocaleCubit>();
    return cubit.translate('${mealType}_desc');
  }

  String getMealTimeLabel(String mealType, BuildContext context) {
    final cubit = context.read<LocaleCubit>();
    return cubit.translate('${mealType}_time');
  }

  // 3. Show the Bottom Sheet
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.backgroundNeutral,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
    ),
    builder: (sheetContext) {
      // Provide ArchiveCubit to the sheet context
      return BlocProvider(
        create: (context) => sl<ArchiveCubit>(),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
                left: 20.w,
                right: 20.w,
                top: 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    context.read<LocaleCubit>().translate('mealInfo'),
                    style: TextStyle(
                      color: AppColor.textNeutral,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Dropdown for Meal Type
                  DropdownButtonFormField<String>(
                    initialValue: selectedMealType,
                    style: TextStyle(
                      color: AppColor.textNeutral,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      labelText: context.read<LocaleCubit>().translate(
                        'mealType',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      prefixIcon: const Icon(
                        Icons.restaurant_menu,
                        color: AppColor.info,
                      ),
                    ),
                    items:
                        ['fasting', 'before', 'after'].map((String type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              context.read<LocaleCubit>().translate(type),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMealType = value!;
                        selectedMealTime = null; // Reset time if type changes
                      });
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Time Picker Trigger
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => selectedMealTime = time);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 15.h,
                        horizontal: 12.w,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppColor.info),
                          SizedBox(width: 12.w),
                          Text(
                            selectedMealTime == null
                                ? getMealTimeLabel(selectedMealType, context)
                                : selectedMealTime!.format(context),
                            style: TextStyle(
                              color:
                                  selectedMealTime == null
                                      ? Colors.grey
                                      : AppColor.textNeutral,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Description Field
                  AppTextField(
                    controller: mealDescription,
                    label: getMealDescription(selectedMealType, context),
                    icon: Icons.notes,
                  ),
                  SizedBox(height: 24.h),

                  // Submit logic with BlocConsumer
                  BlocConsumer<ArchiveCubit, ArchiveState>(
                    listener: (context, state) {
                      if (state.status == ArchiveStatus.success) {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.pushNamed(context, AppRoutes.archives);
                      } else if (state.status == ArchiveStatus.error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage ?? "Error"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      bool isLoading = state.status == ArchiveStatus.loading;
                      return AppButton(
                        text:
                            isLoading
                                ? context.read<LocaleCubit>().translate(
                                  'analyzing',
                                )
                                : context.read<LocaleCubit>().translate(
                                  'submit',
                                ),
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  if (selectedMealTime == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.read<LocaleCubit>().translate(
                                            'select_time',
                                          ),
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  final now = DateTime.now();
                                  final mealTime = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    selectedMealTime!.hour,
                                    selectedMealTime!.minute,
                                  );

                                  final mealModel = MealModel(
                                    description: mealDescription.text,
                                    mealType: _mapMealTypeToBackend(
                                      selectedMealType,
                                    ),
                                    mealTime: mealTime,
                                    userId: 0,
                                  );

                                  final archiveModel = ArchiveModel.fromMeal(
                                    mealModel,
                                  );

                                  context.read<ArchiveCubit>().createArchive(
                                    archiveModel,
                                  );
                                },
                        icon:
                            isLoading ? Icons.hourglass_empty : Icons.analytics,
                        iconColor: Colors.white,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
