import 'package:flutter/material.dart';

import '../../features/home/presentation/child_home_screen.dart';
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
import '../../features/caregiver/presentation/caregiver_list_screen.dart';
import '../../features/caregiver/presentation/caregiver_profile_screen.dart';
import '../../features/caregiver/presentation/caregiver_booking_screen.dart';
import '../../features/caregiver/data/caregiver_model.dart';
import '../../features/booking/presentation/booking_details_screen.dart';
import '../../features/booking/data/booking_model.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/equipment_rental/presentation/equipment_rental_screen.dart';
import '../../features/organ_donor/presentation/organ_donor_screen.dart';
import '../../features/pharmacy/presentation/pharmacy_list_screen.dart';
import '../../features/pharmacy/presentation/emergency_transport_screen.dart'
    as pharmacy_emergency;

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

      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case RouteNames.equipmentRental:
        return MaterialPageRoute(builder: (_) => const EquipmentRentalScreen());

      case RouteNames.organDonor:
        return MaterialPageRoute(builder: (_) => const OrganDonorScreen());

      case RouteNames.childHome:
        return MaterialPageRoute(builder: (_) => const ChildHomeScreen());

      case RouteNames.bloodDonation:
        return MaterialPageRoute(builder: (_) => const BloodDonationScreen());

      case RouteNames.bloodRequest:
        return MaterialPageRoute(builder: (_) => const BloodRequestScreen());

      case RouteNames.donorList:
        return MaterialPageRoute(builder: (_) => const DonorListScreen());

      case RouteNames.caregiverList:
        return MaterialPageRoute(builder: (_) => const CaregiverListScreen());

      case RouteNames.caregiverProfile:
        final caregiver = settings.arguments as Caregiver;
        return MaterialPageRoute(
          builder: (_) => CaregiverProfileScreen(caregiver: caregiver),
        );

      case RouteNames.caregiverBooking:
        final caregiver = settings.arguments as Caregiver;
        return MaterialPageRoute(
          builder: (_) => CaregiverBookingScreen(caregiver: caregiver),
        );

      case RouteNames.bookingDetails:
        final booking = settings.arguments as Booking;
        return MaterialPageRoute(
          builder: (_) => BookingDetailsScreen(booking: booking),
        );

      case RouteNames.pharmacy:
        return MaterialPageRoute(builder: (_) => const PharmacyListScreen());

     case RouteNames.emergency:
        return MaterialPageRoute(
          builder: (_) =>
              const pharmacy_emergency.AdultEmergencyTransportScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
