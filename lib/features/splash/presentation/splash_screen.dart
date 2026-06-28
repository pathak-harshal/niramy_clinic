import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        context.go(RouteNames.login);
      } else {
        context.go(RouteNames.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, opacityValue, child) =>
            Opacity(opacity: opacityValue, child: child),
        child: Stack(
          children: [
            // Center Core Brand elements
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Branding Icon Base
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.surfaceDark
                          : AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: isDarkMode
                          ? null
                          : [
                              BoxShadow(
                                color: AppColors.textDark.withValues(
                                  alpha: 0.06,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: Icon(
                      Icons.healing_rounded,
                      size: 52,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // App Title
                  Text(
                    'Niramay Clinic',
                    style: AppTextStyles.appTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Your Health, On Time',
                    style: AppTextStyles.body.copyWith(
                      color: isDarkMode
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Progress Status
            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
