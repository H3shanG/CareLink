class Donor {
  final String id;
  final String name;
  final String bloodGroup;
  final String area;
  final String phone;
  final double distanceKm;
  final double rating;
  final bool isAvailable;
  final String? photoAsset; // optional: assets/images/providers/xxx.png

  const Donor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.area,
    required this.phone,
    required this.distanceKm,
    required this.rating,
    required this.isAvailable,
    this.photoAsset,
  });
}

const List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];


const List<Donor> sampleDonors = [
  Donor(id: 'd1', name: 'Kasun Perera', bloodGroup: 'A+', area: 'Colombo 03', phone: '0771234567', distanceKm: 2.1, rating: 4.9, isAvailable: true),
  Donor(id: 'd2', name: 'Nimali Fernando', bloodGroup: 'A+', area: 'Bambalapitiya', phone: '0712345678', distanceKm: 3.4, rating: 4.7, isAvailable: true),
  Donor(id: 'd3', name: 'Ruwan Silva', bloodGroup: 'A+', area: 'Dehiwala', phone: '0759876543', distanceKm: 5.8, rating: 4.5, isAvailable: false),
  Donor(id: 'd4', name: 'Tharushi Jayasinghe', bloodGroup: 'O+', area: 'Colombo 07', phone: '0701122334', distanceKm: 1.6, rating: 4.8, isAvailable: true),
  Donor(id: 'd5', name: 'Dilini Wickrama', bloodGroup: 'B+', area: 'Maharagama', phone: '0765544332', distanceKm: 4.3, rating: 4.6, isAvailable: true),
  Donor(id: 'd6', name: 'Ishara Gunawardena', bloodGroup: 'O-', area: 'Colombo 05', phone: '0786677889', distanceKm: 2.9, rating: 5.0, isAvailable: true),
  Donor(id: 'd7', name: 'Sahan Rathnayake', bloodGroup: 'AB-', area: 'Nugegoda', phone: '0723344556', distanceKm: 6.2, rating: 4.4, isAvailable: true),
  Donor(id: 'd8', name: 'Madhavi Senanayake', bloodGroup: 'A+', area: 'Rajagiriya', phone: '0745566778', distanceKm: 7.5, rating: 4.8, isAvailable: true),
  Donor(id: 'd9', name: 'Pasindu Herath', bloodGroup: 'AB+', area: 'Kotte', phone: '0789988776', distanceKm: 3.8, rating: 4.6, isAvailable: false),
  Donor(id: 'd10', name: 'Upul Bandara', bloodGroup: 'A-', area: 'Kottava', phone: '0716574123', distanceKm: 8.3, rating: 5.7, isAvailable: true),
];

