class Pharmacy {
  final String name;
  final double distanceKm;
  final bool open24h;
  final bool openNow;
  final bool expressDelivery;
  final double rating;
  final int reviews;
  final String phone;

  /// Optional asset image, e.g. assets/images/pharmacies/healthplus.png.
  /// If the file is missing the card shows a pharmacy icon instead.
  final String? imagePath;

  const Pharmacy({
    required this.name,
    required this.distanceKm,
    required this.rating,
    required this.reviews,
    required this.phone,
    this.imagePath,
    this.open24h = false,
    this.openNow = true,
    this.expressDelivery = false,
  });

  String get statusText {
    if (open24h) return 'Open 24/7';
    return openNow ? 'Open now' : 'Closed';
  }

  bool get isOpen => open24h || openNow;
}

class Medicine {
  final String name;
  final String strength;
  final int price; // Rs.
  final String pharmacy;
  final bool inStock;

  const Medicine({
    required this.name,
    required this.strength,
    required this.price,
    required this.pharmacy,
    this.inStock = true,
  });
}

// Dummy data for UI. Replace with Firestore / repository later.
const List<Pharmacy> samplePharmacies = [
  Pharmacy(
    name: 'HealthPlus Pharmacy',
    distanceKm: 1.2,
    open24h: true,
    expressDelivery: true,
    rating: 4.6,
    reviews: 320,
    phone: '0112345601',
    imagePath: 'assets/images/pharmacies/healthplus.png',
  ),
  Pharmacy(
    name: 'City Care Pharmacy',
    distanceKm: 2.3,
    rating: 4.4,
    reviews: 210,
    phone: '0112345602',
    imagePath: 'assets/images/pharmacies/citycare.png',
  ),
  Pharmacy(
    name: 'Wellness Pharmacy',
    distanceKm: 3.1,
    expressDelivery: true,
    rating: 4.5,
    reviews: 178,
    phone: '0112345603',
    imagePath: 'assets/images/pharmacies/wellness.png',
  ),
  Pharmacy(
    name: 'Lanka Pharma',
    distanceKm: 4.0,
    openNow: false,
    rating: 4.2,
    reviews: 95,
    phone: '0112345604',
  ),
];

const List<Medicine> sampleMedicines = [
  Medicine(name: 'Paracetamol', strength: '500 mg • 10 tablets', price: 120, pharmacy: 'HealthPlus Pharmacy'),
  Medicine(name: 'Amoxicillin', strength: '250 mg • 10 capsules', price: 450, pharmacy: 'City Care Pharmacy'),
  Medicine(name: 'Cetirizine', strength: '10 mg • 10 tablets', price: 180, pharmacy: 'Wellness Pharmacy'),
  Medicine(name: 'Vitamin C', strength: '1000 mg • 20 tablets', price: 650, pharmacy: 'HealthPlus Pharmacy'),
  Medicine(name: 'Omeprazole', strength: '20 mg • 14 capsules', price: 320, pharmacy: 'Lanka Pharma', inStock: false),
  Medicine(name: 'Metformin', strength: '500 mg • 30 tablets', price: 280, pharmacy: 'City Care Pharmacy'),
  Medicine(name: 'Salbutamol Inhaler', strength: '100 mcg', price: 850, pharmacy: 'Wellness Pharmacy'),
  Medicine(name: 'ORS Sachets', strength: 'Pack of 5', price: 60, pharmacy: 'HealthPlus Pharmacy'),
];

