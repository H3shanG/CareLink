class Donor {
  // The document id is the donor's userId (one donor document per user)
  final String id;
  final String name;
  final String bloodGroup;
  final String area;
  final String phone;
  final double rating;
  final bool isAvailable;
  final String? photoAsset;

  // Saved in Firestore so distance can be calculated on the device
  final double? latitude;
  final double? longitude;

  // Not saved in Firestore. Calculated on the device from the user's location.
  final double? distanceKm;

  const Donor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    this.area = '',
    required this.phone,
    this.distanceKm,
    this.rating = 0,
    required this.isAvailable,
    this.photoAsset,
    this.latitude,
    this.longitude,
  });

  Donor copyWith({double? distanceKm}) {
    return Donor(
      id: id,
      name: name,
      bloodGroup: bloodGroup,
      area: area,
      phone: phone,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating,
      isAvailable: isAvailable,
      photoAsset: photoAsset,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // Rating and distance are intentionally not written by the donor
  Map<String, dynamic> toMap() => {
    'name': name,
    'bloodGroup': bloodGroup,
    'area': area,
    'phone': phone,
    'isAvailable': isAvailable,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory Donor.fromMap(String id, Map<String, dynamic> map) {
    return Donor(
      id: id,
      name: (map['name'] as String?) ?? '',
      bloodGroup: (map['bloodGroup'] as String?) ?? '',
      area: (map['area'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      isAvailable: (map['isAvailable'] as bool?) ?? false,
      photoAsset: map['photoAsset'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}

const List<String> bloodGroups = [
  'A+',
  'A-',
  'B+',
  'B-',
  'O+',
  'O-',
  'AB+',
  'AB-',
];
