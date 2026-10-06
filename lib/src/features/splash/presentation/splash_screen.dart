import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/routes/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, RouteNames.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenHorizontalPadding,
          ),
          child: Column(
            children: [
              const Spacer(),

              Image.asset(
                AssetPaths.careLinkLogo,
                width: 110,
                height: 110,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: AppSizes.lg),

              Text(
                'CareLink',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: AppSizes.sm),

              Text(
                'Healthier People\nStronger Families',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: AppColors.textSecondary),
              ),

              const SizedBox(height: AppSizes.xxxl),

              Expanded(
                flex: 3,
                child: Image.asset(
                  AssetPaths.splashFamily,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              Text(
                'A unified platform for adult patient care & baby/childcare services.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: AppSizes.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
