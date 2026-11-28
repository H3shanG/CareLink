import 'package:geolocator/geolocator.dart';

import '../models/donor.dart';

class DonorLocation {
  DonorLocation._();

  // Returns the device position, or null if location is off or denied
  static Future<Position?> currentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // Adds distanceKm to every donor that has coordinates
  static List<Donor> withDistance(List<Donor> donors, Position? position) {
    if (position == null) return donors;

    return donors.map((d) {
      final lat = d.latitude;
      final lng = d.longitude;
      if (lat == null || lng == null) return d;

      final meters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );
      return d.copyWith(
        distanceKm: double.parse((meters / 1000).toStringAsFixed(1)),
      );
    }).toList();
  }
}