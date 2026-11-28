import 'package:flutter/material.dart';

class OrganDonorScreen extends StatefulWidget {
  const OrganDonorScreen({super.key});

  @override
  State<OrganDonorScreen> createState() => _OrganDonorScreenState();
}

class _OrganDonorScreenState extends State<OrganDonorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender;
  final List<String> _selectedOrgans = [];
  bool _hasGivenConsent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organ Donor Registry'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Icon(Icons.volunteer_activism, size: 70, color: Colors.red),
            const SizedBox(height: 16),

            const Text(
              'Become an Organ Donor',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const Text(
              'Register your interest in becoming an organ donor '
              'and help save lives.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                hintText: 'Enter your age',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) {
                final age = int.tryParse(value ?? '');
                if (age == null || age < 18 || age > 120) {
                  return 'Please enter a valid age (18 or above)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter your home address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              initialValue: _selectedGender,
              items: ['Male', 'Female', 'Other']
                  .map(
                    (gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select your gender';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Organ Donation Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            const Text(
              'Select Organs You Wish to Donate',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...[
              'Kidneys',
              'Liver',
              'Heart',
              'Lungs',
              'Pancreas',
              'Corneas',
            ].map((organ) {
              return CheckboxListTile(
                title: Text(organ),
                value: _selectedOrgans.contains(organ),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedOrgans.add(organ);
                    } else {
                      _selectedOrgans.remove(organ);
                    }
                  });
                },
              );
            }),

            const SizedBox(height: 16),

            CheckboxListTile(
              title: const Text(
                'I confirm that I understand organ donation and agree '
                'to register my interest.',
              ),
              value: _hasGivenConsent,
              onChanged: (value) {
                setState(() {
                  _hasGivenConsent = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _registerDonor,
                child: const Text(
                  'Register as an Organ Donor',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'This is a demonstration registration form. '
              'It does not create an official organ donor registration.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _registerDonor() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedOrgans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one organ.')),
      );
      return;
    }

    if (!_hasGivenConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm your consent.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registration Completed'),
          content: Text(
            'Thank you, ${_nameController.text.trim()}!\n\n'
            'Your demonstration registration form is complete.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
