import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/injection_container.dart';
import 'package:untitled10/features/home/presentation/manager/bottom_nav_cubit.dart';
import 'package:untitled10/features/home/presentation/manager/home_cubit.dart';
import 'package:untitled10/features/archives/presentaiton/view/archive_page.dart';
import 'package:untitled10/features/chat/presentation/view/chat_page.dart';
import 'package:untitled10/features/chat/presentation/manager/chat_cubit.dart';
import 'package:untitled10/features/home/presentation/view/settings_page.dart';
import 'package:untitled10/features/home/presentation/widgets/custom_bottom_nav.dart';

import '../widgets/home_content.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final List<Widget> screens = [
    const HomeContent(),
    const ChatPage(),
    const ArchivesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeCubit>()),
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(create: (_) => sl<BotCubit>()),
      ],

      child: Scaffold(
        backgroundColor: AppColor.backgroundNeutral,

        body: BlocBuilder<BottomNavCubit, int>(
          builder: (context, index) {
            if (index < 0 || index >= screens.length) {
              return const HomeContent();
            }
            return screens[index];
          },
        ),

        bottomNavigationBar: const CustomBottomNav(),
      ),
    );
  }
}
