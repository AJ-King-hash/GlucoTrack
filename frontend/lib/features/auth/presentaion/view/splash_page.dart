import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled10/core/routes/app_routes.dart';

import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/utils/source_storage_service.dart';
import '../../../../core/widgets/custom_icon_widget.dart';

/// Splash Screen for DiabetesAssistant application
/// Provides branded app launch experience while initializing diabetes management services
/// Implements RTL layout support and Arabic text rendering
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isInitializing = true;

  bool _showRetry = false;
  late String _statusMessage;

  @override
  void initState() {
    super.initState();
    _statusMessage = context.read<LocaleCubit>().translate('loading');
    _initializeAnimations();
    _initializeApp();
  }

  /// Initialize pulse animation for logo
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  /// Initialize app services and determine navigation path
  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isInitializing = true;
        _showRetry = false;
        _statusMessage = context.read<LocaleCubit>().translate('loading');
      });

      await Future.delayed(const Duration(milliseconds: 800));
      setState(
        () => _statusMessage = context.read<LocaleCubit>().translate('verify'),
      );

      await Future.delayed(const Duration(milliseconds: 600));
      setState(
        () =>
            _statusMessage = context.read<LocaleCubit>().translate('loadingst'),
      );

      await Future.delayed(const Duration(milliseconds: 700));
      setState(
        () => _statusMessage = context.read<LocaleCubit>().translate('syncing'),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      setState(
        () =>
            _statusMessage = context.read<LocaleCubit>().translate('settingth'),
      );

      await Future.delayed(const Duration(milliseconds: 400));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _showRetry = true;
          _statusMessage = context.read<LocaleCubit>().translate('anerr');
        });
      }
    }
  }

  void _navigateToNextScreen() async {
    final bool isFirstTime = await SecureStorageService.getIsFirstTime();
    final String? token = await SecureStorageService.getToken();

    if (mounted) {
      if (token != null) {
        // User is already logged in
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed(AppRoutes.home);
      } else if (isFirstTime) {
        // New users see login page
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed(AppRoutes.login);
      } else {
        // Existing users see login page
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  /// Retry initialization on failure
  void _retryInitialization() {
    _initializeApp();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Set system UI overlay style to match brand color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: theme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated logo with pulse effect
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 45.w,
                  height: 45.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'favorite',
                          color: theme.colorScheme.primary,
                          size: 20.w,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Gluco Track',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 6.h),

              // Loading indicator and status message
              if (_isInitializing) ...[
                SizedBox(
                  width: 8.w,
                  height: 8.w,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _statusMessage,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],

              // Retry button on error
              if (_showRetry) ...[
                Text(
                  _statusMessage,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: _retryInitialization,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 1.5.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'إعادة المحاولة',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],

              const Spacer(flex: 3),

              // App version and copyright
              Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Column(
                  children: [
                    Text(
                      context.read<LocaleCubit>().translate('version'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11.sp,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Gluco Track© 2026 ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10.sp,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
