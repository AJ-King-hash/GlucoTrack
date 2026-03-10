import 'package:flutter/material.dart';
import '../color/app_color.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Base medical gradient background
          const _BaseGradient(),

          // 🔹 Soft glowing overlays for depth and premium feel
          const _TopGlowOverlay(),
          const _BottomGlowOverlay(),

          // 🔹 Floating medical icons (optional subtle touch)
          const _FloatingIcons(),

          // 🔹 Page content with safe padding
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// Base medical gradient
/// ===============================
class _BaseGradient extends StatelessWidget {
  const _BaseGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.positive.withValues(alpha: 0.9),
            AppColor.positive.withValues(alpha: 0.6),
            Colors.white,
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// Soft top glow overlay
/// ===============================
class _TopGlowOverlay extends StatelessWidget {
  const _TopGlowOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: -80,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.25), Colors.transparent],
            radius: 0.8,
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// Soft bottom glow overlay
/// ===============================
class _BottomGlowOverlay extends StatelessWidget {
  const _BottomGlowOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -120,
      right: -90,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColor.positive.withValues(alpha: 0.15),
              Colors.transparent,
            ],
            radius: 0.7,
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// Floating medical icons for subtle design touch
/// ===============================
class _FloatingIcons extends StatelessWidget {
  const _FloatingIcons();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          right: 30,
          child: Icon(
            Icons.local_hospital,
            color: Colors.white.withValues(alpha: 0.1),
            size: 60,
          ),
        ),
        Positioned(
          bottom: 100,
          left: 40,
          child: Icon(
            Icons.medical_services,
            color: Colors.white.withValues(alpha: 0.08),
            size: 50,
          ),
        ),
      ],
    );
  }
}
