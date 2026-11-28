import 'package:flutter/material.dart';

import '../../../core/routes/route_names.dart';
import 'child_my_requests_screen.dart';
import 'sick_child_care_screen.dart';
import 'baby_health_record_screen.dart';
import 'pediatric_medicine_screen.dart';
import 'baby_equipment_rental_screen.dart';
import 'pediatrician_locator_screen.dart';
import 'emergency_transport_screen.dart';
import '../../messages/presentation/messages_screen.dart';

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'name': 'Sick Child Care',
        'icon': Icons.medical_services_outlined,
        'color': Colors.pink,
      },
      {
        'name': 'Baby Health Record',
        'icon': Icons.description_outlined,
        'color': Colors.teal,
      },
      {
        'name': 'Pediatric Medicine',
        'icon': Icons.medication_outlined,
        'color': Colors.purple,
      },
      {
        'name': 'Baby Equipment Rental',
        'icon': Icons.child_friendly,
        'color': Colors.blue,
      },
      {
        'name': 'Pediatrician Locator',
        'icon': Icons.location_on,
        'color': Colors.green,
      },
      {
        'name': 'Emergency Transport',
        'icon': Icons.local_shipping,
        'color': Colors.red,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CareLink header
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 30),
                  const SizedBox(width: 8),
                  const Text(
                    'CareLink',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Row(
                children: [
                  Icon(Icons.location_on, size: 17),
                  SizedBox(width: 5),
                  Text('Colombo, Sri Lanka'),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),

              const SizedBox(height: 20),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search services, providers...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Promotional banner
              Container(
                height: 140,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE7EA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Happy & Healthy\nChildhood',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Trusted care for your little ones.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/onboarding/child_care.png',
                        width: 120,
                        height: 115,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Services heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Child Care Services',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),

              const SizedBox(height: 12),

              // Service grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                ),

                itemBuilder: (context, index) {
                  final service = services[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(15),

                    onTap: () {
                      if (index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SickChildCareScreen(),
                          ),
                        );
                      } else if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BabyHealthRecordScreen(),
                          ),
                        );
                      } else if (index == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PediatricMedicineScreen(),
                          ),
                        );
                      } else if (index == 3) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BabyEquipmentRentalScreen(),
                          ),
                        );
                      } else if (index == 4) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PediatricianLocatorScreen(),
                          ),
                        );
                      } else if (index == 5) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EmergencyTransportScreen(),
                          ),
                        );
                      }
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? const Color(0xFFFFF0F5)
                            : const Color(0xFFEAF8F4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            service['icon'] as IconData,
                            size: 30,
                            color: service['color'] as Color,
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              service['name'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChildMyRequestsScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessagesScreen()),
            );
          } else if (index == 3) {
            Navigator.pushNamed(context, RouteNames.profile);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'My Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
