import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/registration_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/journey/presentation/journey_selection_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/blood_donation/presentation/blood_donation_screen.dart';
import '../../features/blood_donation/presentation/blood_request_screen.dart';
import '../../features/blood_donation/presentation/donor_list_screen.dart';
import '../../features/home/presentation/adult_home_screen.dart';
import 'route_names.dart';

class AppRoutes {
  AppRoutes._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());

      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case RouteNames.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      case RouteNames.journeySelection:
        return MaterialPageRoute(
          builder: (_) => const JourneySelectionScreen(),
        );

              case RouteNames.adultHome:
        return MaterialPageRoute(builder: (_) => const AdultHomeScreen());

      case RouteNames.bloodDonation:
        return MaterialPageRoute(builder: (_) => const BloodDonationScreen());

      case RouteNames.bloodRequest:
        return MaterialPageRoute(builder: (_) => const BloodRequestScreen());

      case RouteNames.donorList:
        return MaterialPageRoute(builder: (_) => const DonorListScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
