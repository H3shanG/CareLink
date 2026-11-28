import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/launcher_helper.dart';

const Color _kDanger = Color(0xFFE53935);
const Color _kGreen = Color(0xFF2E9E5B);
const Color _kBlue = Color(0xFF1E5BB8);

// Demo data (Colombo). TODO: replace with live data from the backend.
const LatLng _userPos = LatLng(6.9022, 79.8612);
const LatLng _ambulancePos = LatLng(6.9105, 79.8660);
const LatLng _hospitalPos = LatLng(6.9185, 79.8683);
const String _driverName = 'Chamal Silva';
const String _driverPhone = '0771234567';

/// Emergency Transport (Member 5, adult flow): real map + ambulance details.
/// Uses OpenStreetMap tiles through flutter_map, so no API key is needed.
class AdultEmergencyTransportScreen extends StatelessWidget {
  const AdultEmergencyTransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text('Emergency Transport',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          const Expanded(child: _MapArea()),
          _BottomPanel(),
        ],
      ),
    );
  }
}

class _MapArea extends StatelessWidget {
  const _MapArea();

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(6.9100, 79.8640),
        initialZoom: 14.5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.carelink',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [
                _userPos,
                LatLng(6.9040, 79.8650),
                LatLng(6.9105, 79.8660),
                _hospitalPos,
              ],
              strokeWidth: 5,
              color: _kBlue,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _userPos,
              width: 22,
              height: 22,
              child: Container(
                decoration: BoxDecoration(
                  color: _kBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
            Marker(
              point: _ambulancePos,
              width: 44,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: _kDanger,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 6),
                  ],
                ),
                child: const Icon(Icons.local_shipping, color: Colors.white, size: 22),
              ),
            ),
            Marker(
              point: _hospitalPos,
              width: 130,
              height: 76,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Color(0x22000000), blurRadius: 6),
                      ],
                    ),
                    child: const Text('National Hospital\nColombo',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.location_on, color: _kDanger, size: 32),
                ],
              ),
            ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}

class _BottomPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F9F4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: _kGreen,
                    child: Icon(Icons.local_shipping, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ambulance on the way',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        Text('5 min away',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF1E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Live',
                        style: TextStyle(
                            color: _kGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFE8F1FB),
                  child: Icon(Icons.person, color: _kBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_driverName,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFFFB300)),
                          const SizedBox(width: 3),
                          Text('4.8 (210)',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      Text('Ambulance  •  WP ABC 1234',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => callNumber(context, _driverPhone),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => messageNumber(context, _driverPhone),
                    icon: const Icon(Icons.message_outlined, size: 18),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
