import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/core/routes/app_routes.dart';
import 'package:untitled10/features/home/presentation/manager/settings_cubit.dart';
import 'package:untitled10/features/home/presentation/manager/settings_state.dart';
import 'package:untitled10/features/home/presentation/widgets/change_password_bottom_sheet.dart';
import 'package:untitled10/features/home/presentation/widgets/settings_item.dart';
import 'package:untitled10/features/home/presentation/widgets/switch-item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'GlucoTrack',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textNeutral,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColor.backgroundNeutral,
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.bell,color: AppColor.info,),
              onPressed: () {},
            ),
          ],
        ),
        backgroundColor: AppColor.backgroundNeutral,
        body: BlocBuilder<SettingsCubit,SettingsState>(
          builder: (context,state){
            if (state is! SettingsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
          
            return ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                _sectionTitle(context.read<LocaleCubit>().translate('profile')),
                SettingsItem(
                  icon: Icons.person,
                    iconColor: AppColor.info,
                   title: context.read<LocaleCubit>().translate('edit_profile'),
                    titleColor: AppColor.textNeutral,
                    onTap: (){
                    Navigator.pushNamed(context, AppRoutes.editProfile);
                    }),
                _sectionTitle(context.read<LocaleCubit>().translate('aa')),
              SwitchItem(
                icon: Icons.monitor_heart,
                  iconColor: AppColor.info,
                 title:context.read<LocaleCubit>().translate('bb'),
                  titleColor: AppColor.textNeutral,
                  value: state.sugarReminder, 
                  onChanged: (v)=>context.read<SettingsCubit>().toggleSugarReminder(v)
                  ),   
                   SwitchItem(
                  icon: Icons.medication,
                     iconColor: AppColor.info,
                  title: context.read<LocaleCubit>().translate('cc'),
                     titleColor: AppColor.textNeutral,
                  value: state.medicineReminder,
                  onChanged: (v) =>
                      context.read<SettingsCubit>().toggleMedicineReminder(v),
                ),

                 _sectionTitle(context.read<LocaleCubit>().translate('hh')),
                   SettingsItem(
                  icon: Icons.lock,
                     iconColor: AppColor.info,
                     titleColor: AppColor.textNeutral,
                  title: context.read<LocaleCubit>().translate('ii'),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_)=>const ChangePasswordBottomSheet());
                  },
                ),
                 _sectionTitle(context.read<LocaleCubit>().translate('jj')),

                SettingsItem(
                  icon: Icons.info_outline,
                  iconColor: AppColor.info,
                  titleColor: AppColor.textNeutral,
                  title: context.read<LocaleCubit>().translate('about_app'),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.aboutApp);
                  },
                ),
                SizedBox(height: 24.h,),
                ElevatedButton.icon(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppColor.negative,
                    minimumSize: Size(double.infinity, 50.h),),
                     icon: const Icon(Icons.logout,color: AppColor.info,),
                  label: Text(context.read<LocaleCubit>().translate('kk'),
                      style:TextStyle(color: AppColor.textNeutral)),
                  onPressed: () {},
                )
              ],

            );
          }),
      ));
  }
}
Widget _sectionTitle(String title) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        /// Accent Medical Bar
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: AppColor.info,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),

        SizedBox(width: 10.w),

        /// Title Text
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: AppColor.textNeutral,
          ),
        ),
      ],
    ),
  );
}

