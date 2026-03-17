import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/injection_container.dart';
import 'package:untitled10/features/auth/presentaion/view/get_started_page.dart';
import 'package:untitled10/features/auth/presentaion/view/login_page.dart';
import 'package:untitled10/features/auth/presentaion/view/otp_page.dart';
import 'package:untitled10/features/auth/presentaion/view/register_page.dart';
import 'package:untitled10/features/auth/presentaion/view/reset_password.dart';
import 'package:untitled10/features/auth/presentaion/view/splash_page.dart';
import 'package:untitled10/features/home/presentation/view/edit_profile_page.dart';
import 'package:untitled10/features/home/presentation/view/home_page.dart';
import 'package:untitled10/features/home/presentation/widgets/about_app.dart';
import 'package:untitled10/features/risk/presentation/view/risk_page.dart';
import 'package:untitled10/features/risk/presentation/manager/risk_cubit.dart';
import 'package:untitled10/features/notification/presentation/view/reminder_settings_page.dart';
import 'package:untitled10/features/archives/presentaiton/view/archive_page.dart';

class AppRoutes {
  static const login = "/login";
  static const started = "/started";
  static const register = "/register";
  static const resetPassword = "/reset-password";
  static const home = "/home";
  static const otp = "/otp";
  static const editProfile = "/editprofile";
  static const archiveDetailsPage = "/archiveDetailsPage";
  static const splashScreen = "/splashScreen";
  static const aboutApp = "/aboutApp";
  static const risk = "/risk";
  static const notifications = "/notifications";
  static const archives = "/archives";
  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginPage(),
    register: (context) => RegisterPage(),
    resetPassword: (context) => ResetPasswordPage(),
    otp: (context) => OtpPage(),
    home: (context) => HomePage(),
    started: (context) => GetStartedPage(),
    editProfile: (context) => EditProfilePage(),
    // archiveDetailsPage:(context)=>ArchiveDetailsPage(),
    splashScreen: (context) => SplashScreen(),
    aboutApp: (context) => AboutAppPage(),
    risk:
        (context) => BlocProvider(
          create: (_) => sl<RiskCubit>(),
          child: const RiskPage(),
        ),
    notifications: (context) => const ReminderSettingsPage(),
    archives: (context) => const ArchivesPage(),
  };
}
