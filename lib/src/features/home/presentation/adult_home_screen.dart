import 'package:flutter/material.dart';

import '../../requests/presentation/urgent_request_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/route_names.dart';
import '../../blood_donation/presentation/blood_donation_screen.dart';
import '../../equipment_rental/presentation/equipment_rental_screen.dart';
import '../../organ_donor/presentation/organ_donor_screen.dart';
import '../../profile/notifications/presentation/notifications_screen.dart';
import '../../requests/presentation/my_requests_screen.dart';
import '../../messages/presentation/messages_screen.dart';

const Color _danger = Color(0xFFE53935);

class AdultHomeScreen extends StatefulWidget {
  const AdultHomeScreen({super.key});

  @override
  State<AdultHomeScreen> createState() => _AdultHomeScreenState();
}

class _Routes {
  static const caregiver = '/caregiver';
  static const pharmacy = '/pharmacy';
  static const emergency = '/emergency';
  static const equipmentRental = RouteNames.equipmentRental;
  static const organDonor = RouteNames.organDonor;
}

class _Service {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _Service(this.label, this.icon, this.color, this.route);
}

class _AdultHomeScreenState extends State<AdultHomeScreen> {
  int _navIndex = 0;

  final List<_Service> _services = const [
    _Service(
      'Blood\nDonation',
      Icons.water_drop,
      Color(0xFFE53935),
      RouteNames.bloodDonation,
    ),
    _Service(
      'Caregiver\nBooking',
      Icons.person,
      Color(0xFF43A047),
      RouteNames.caregiverList,
    ),
    _Service(
      'Medicine &\nPharmacy',
      Icons.medication,
      Color(0xFF1E5BB8),
      _Routes.pharmacy,
    ),
    _Service(
      'Emergency\nTransport',
      Icons.local_shipping,
      Color(0xFFE53935),
      _Routes.emergency,
    ),
    _Service(
      'Medical\nEquipment',
      Icons.accessible,
      Color(0xFF1E5BB8),
      _Routes.equipmentRental,
    ),
    _Service(
      'Organ\nDonor Registry',
      Icons.favorite,
      Color(0xFFE91E8C),
      _Routes.organDonor,
    ),
  ];

  void _open(String route) => Navigator.pushNamed(context, route);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildUrgentBanner(),
            const SizedBox(height: 20),
            _buildSectionTitle('Adult Care Services'),
            const SizedBox(height: 12),
            _buildServiceGrid(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite, color: _danger, size: 30),
            const SizedBox(width: 8),
            const Text(
              'CareLink',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.notifications_none,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: const [
            Icon(Icons.location_on, color: _danger, size: 16),
            SizedBox(width: 4),
            Text(
              'Colombo, Sri Lanka',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search services, providers...',
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildUrgentBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need urgent help?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  "We're here for you.",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UrgentRequestScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Request Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          Image.asset(
            'assets/images/home/female_doctor.png',
            height: 100,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () => _showAllServices(context),
          child: const Text('See All', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildServiceGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, i) {
        final s = _services[i];
        return InkWell(
          onTap: () => _open(s.route),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: s.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(s.icon, color: s.color, size: 30),
                const SizedBox(height: 8),
                Text(
                  s.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _navIndex,

      onTap: (i) {
        if (i == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyRequestsScreen()),
          );
        } else if (i == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MessagesScreen()),
          );
        } else if (i == 3) {
          Navigator.pushNamed(context, RouteNames.profile);
        } else {
          setState(() => _navIndex = i);
        }
      },

      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'My Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

void _showAllServices(BuildContext context) {
  final services = <Map<String, dynamic>>[
    {
      'title': 'Blood Donation',
      'icon': Icons.bloodtype,
      'color': Colors.red,
      'screen': const BloodDonationScreen(),
    },
    {
      'title': 'Caregiver Booking',
      'icon': Icons.person,
      'color': Colors.green,
      'screen': null,
    },
    {
      'title': 'Medicine & Pharmacy',
      'icon': Icons.medication,
      'color': Colors.blue,
      'screen': null,
    },
    {
      'title': 'Emergency Transport',
      'icon': Icons.local_shipping,
      'color': Colors.red,
      'screen': null,
    },
    {
      'title': 'Medical Equipment',
      'icon': Icons.accessible,
      'color': Colors.indigo,
      'screen': const EquipmentRentalScreen(),
    },
    {
      'title': 'Organ Donor Registry',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'screen': const OrganDonorScreen(),
    },
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Adult Care Services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...services.map(
            (s) => ListTile(
              leading: Icon(s['icon'] as IconData, color: s['color'] as Color),
              title: Text(s['title'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(sheetContext);
                final screen = s['screen'] as Widget?;
                if (screen != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => screen),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${s['title']} is coming soon')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
