import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/widgets/primary_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  Widget _buildRoleCard({
    required String id,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedRole == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 30, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _continue() {
    // Navigation to Journey Selection will be added when routes are ready.
  }

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Center(
                child: Image.asset(
                  AssetPaths.careLinkLogo,
                  width: 70,
                  height: 70,
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              Text(
                'How will you use CareLink?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: AppSizes.sm),

              Text(
                'Choose your role to personalize your experience.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              _buildRoleCard(
                id: 'seeker',
                icon: Icons.favorite_outline,
                title: 'Care Seeker',
                description: 'Looking for care for myself or my family.',
              ),

              const SizedBox(height: AppSizes.lg),

              _buildRoleCard(
                id: 'caregiver',
                icon: Icons.medical_services_outlined,
                title: 'Caregiver / Nurse',
                description: 'Offering care services to others.',
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Continue',
                onPressed: _selectedRole == null ? null : _continue,
              ),

              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}
