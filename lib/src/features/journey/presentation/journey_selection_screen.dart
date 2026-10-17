import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class JourneySelectionScreen extends StatelessWidget {
  const JourneySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.sm),

              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.maybePop(context),
              ),

              const SizedBox(height: AppSizes.lg),

              Text(
                'Choose Your Care Journey',
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: AppSizes.sm),

              Text(
                'Select the service area you want to use.\nYou can switch anytime.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 28),

              _JourneyCard(
                imagePath: 'assets/images/onboarding/adult_care.png',
                color: const Color(0xFFD5EEE9),
                title: 'Adult / Patient Care',
                description: 'Blood donation, caregivers, medicine, transport, equipment and more.',
                onTap: () {
                  // Navigation to Adult Home will be added when routes are ready.
                },
              ),

              const SizedBox(height: AppSizes.lg),

              _JourneyCard(
                imagePath: 'assets/images/onboarding/child_care.png',
                color: const Color(0xFFDDF0DC),
                title: 'Baby / Child Care',
                description: 'Childcare, pediatric services, medicine, equipment and more.',
                onTap: () {
                  // Navigation to Child Home will be added when routes are ready.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final String imagePath;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _JourneyCard({
    required this.imagePath,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2.5,
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
