class Caregiver {
  final String name;
  final String role;
  final double rating;
  final int reviews;
  final String distance;
  final List<String> tags;
  final int pricePerHour;
  final int experienceYears;
  final String about;
  final List<String> languages;

  const Caregiver({
    required this.name,
    required this.role,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.tags,
    required this.pricePerHour,
    required this.experienceYears,
    required this.about,
    required this.languages,
  });
}

const List<Caregiver> dummyCaregivers = [
  Caregiver(
    name: 'Samanthi Silva',
    role: 'Registered Nurse',
    rating: 4.8,
    reviews: 120,
    distance: '1.5 km',
    tags: ['Elder Care', 'Patient Care', 'Home Visit'],
    pricePerHour: 650,
    experienceYears: 8,
    about: 'Experienced registered nurse providing professional home care for elderly and post-treatment patients.',
    languages: ['Sinhala', 'English'],
  ),
  Caregiver(
    name: 'Nadeee Perera',
    role: 'Caregiver',
    rating: 4.7,
    reviews: 95,
    distance: '2.1 km',
    tags: ['Home Care', 'Post-surgery', 'Elder Care'],
    pricePerHour: 500,
    experienceYears: 5,
    about: 'Caring and patient caregiver helping with daily activities and recovery after surgery.',
    languages: ['Sinhala', 'Tamil'],
  ),
  Caregiver(
    name: 'Tharushi Fernando',
    role: 'Nurse',
    rating: 4.9,
    reviews: 87,
    distance: '3.4 km',
    tags: ['Patient Care', 'Child Care', 'Home Visit'],
    pricePerHour: 600,
    experienceYears: 6,
    about: 'Dedicated nurse with experience in patient and child care visits at home.',
    languages: ['Sinhala', 'English'],
  ),
];
