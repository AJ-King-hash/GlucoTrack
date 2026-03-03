import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/widgets/app_button.dart';
import 'package:untitled10/features/home/presentation/manager/bottom_nav_cubit.dart';
import 'package:untitled10/features/home/presentation/manager/home_cubit.dart';
import 'package:untitled10/features/home/presentation/manager/home_state.dart';
import 'package:untitled10/features/archives/presentaiton/view/archive_page.dart';
import 'package:untitled10/features/chat/presentation/view/chat_page.dart';
import 'package:untitled10/features/home/presentation/view/settings_page.dart';
import 'package:untitled10/features/home/presentation/widgets/card_widget.dart';
import 'package:untitled10/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:untitled10/features/home/presentation/widgets/option_card.dart';

import '../widgets/home_content.dart';
import '../widgets/picker_bottom_sheet.dart';
import '../widgets/user_info_card.dart';

class HomePage extends StatelessWidget {
   HomePage({super.key});
 final List<Widget> screens =[
   ChatPage(),
   const ArchivesPage(archives: [],),
   const SettingsPage(),

  ];

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => BottomNavCubit()),
      ],

        child: Scaffold(
          backgroundColor: AppColor.backgroundNeutral,



          body: BlocBuilder<BottomNavCubit, int>(
            builder: (context, index) {
              switch (index) {
                case 0:
                  return const HomeContent();
                case 1:
                  return  ChatPage();
                case 2:
                  return const ArchivesPage(archives: [],);
                case 3:
                  return const SettingsPage();
                default:
                  return const HomeContent();
              }
            },
          ),

          bottomNavigationBar: const CustomBottomNav(),
        ),

    );
  }
}