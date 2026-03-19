import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled10/core/injection_container.dart';

import 'package:untitled10/core/color/app_color.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/core/localization/locale_state.dart';
import 'package:untitled10/core/routes/app_routes.dart';
import 'package:untitled10/core/services/notification_service.dart';
import 'package:untitled10/core/services/navigation_service.dart';

import 'package:untitled10/features/auth/presentaion/manager/auth_cubit.dart';
import 'package:untitled10/features/auth/repo/auth_repo.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:untitled10/features/user/presentation/manager/user_cubit.dart';
import 'package:untitled10/features/user/repo/user_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await init();

  // Initialize notification service
  final notificationService = sl<NotificationService>();
  await notificationService.initialize();

  // Note: Token storage now uses FlutterSecureStorage (SecureStorageService)
  // SharedPreferences is initialized here for potential future use (e.g., locale persistence)
  await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // instantiate shared dependencies once and pass them to cubits
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (context) => AuthCubit(sl<AuthRepository>())),
        BlocProvider(
          create: (_) => UserCubit(sl<UserRepository>(), sl<AuthRepository>()),
        ),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, state) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return Sizer(
                builder: (context, orientation, deviceType) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    locale: context.read<LocaleCubit>().currentLocale,
                    supportedLocales: const [Locale('en'), Locale('ar')],
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    theme: ThemeData(
                      scaffoldBackgroundColor: AppColor.backgroundNeutral,
                      primaryColor: AppColor.positive,
                      colorScheme: ColorScheme.fromSwatch().copyWith(
                        secondary: AppColor.textNeutral,
                      ),
                    ),
                    initialRoute: AppRoutes.started,
                    routes: AppRoutes.routes,
                    navigatorKey: NavigationService().navigatorKey,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
