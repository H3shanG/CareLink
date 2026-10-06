import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      title: 'All the care you need\nin one place',
      description: 'Find trusted people, services and resources for you and your family.',
      image: AssetPaths.onboardingOne,
    ),
    OnboardingItem(
      title: 'Trusted care providers',
      description: 'Connect with caregivers, nurses, pharmacies and health services near you.',
      image: AssetPaths.onboardingTwo,
    ),
    OnboardingItem(
      title: 'Care for the whole family',
      description:
          'Manage adult care and child health services from one simple place.',
      image: AssetPaths.onboardingThree,
    ),
  ];

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _goToLogin();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenHorizontalPadding,
            AppSizes.lg,
            AppSizes.screenHorizontalPadding,
            AppSizes.xl,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _goToLogin,
                  child: const Text('Skip'),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(context, _pages[index]);
                  },
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildIndicator(index),
                ),
              ),

              const SizedBox(height: AppSizes.xxl),

              PrimaryButton(
                text: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                onPressed: _nextPage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingItem item) {
    return Column(
      children: [
        const SizedBox(height: AppSizes.xl),

        Text(
          item.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: AppSizes.md),

        Text(
          item.description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: AppSizes.xxxl),

        Expanded(child: Image.asset(item.image, fit: BoxFit.contain)),
      ],
    );
  }

  Widget _buildIndicator(int index) {
    final bool isSelected = index == _currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isSelected ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
  });
}
