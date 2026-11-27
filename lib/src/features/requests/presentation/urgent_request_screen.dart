
import 'package:flutter/material.dart';
import '../data/urgent_request_store.dart';

class UrgentRequestScreen extends StatefulWidget {
  const UrgentRequestScreen({super.key});

  @override
  State<UrgentRequestScreen> createState() =>
      _UrgentRequestScreenState();
}

class _UrgentRequestScreenState
    extends State<UrgentRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();

  String? _selectedService;

  final List<String> _services = [
    'Emergency Transport',
    'Urgent Caregiver',
    'Blood Donation',
    'Medicine & Pharmacy',
    'Medical Equipment',
  ];

void _submitRequest() {
  final form = _formKey.currentState;
  final service = _selectedService;

  if (form == null || !form.validate() || service == null) {
    return;
  }

  UrgentRequestStore.addRequest({
    'service': service,
    'patientName': _nameController.text.trim(),
    'phone': _phoneController.text.trim(),
    'location': _locationController.text.trim(),
    'details': _detailsController.text.trim(),
    'status': 'Demo Only',
    'date': DateTime.now().toString(),
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Demo request saved locally. No request was dispatched.',
      ),
      backgroundColor: Colors.green,
    ),
  );

  Navigator.pop(context);
}



  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (required &&
            (value == null || value.trim().isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Urgent Help Request'),
        backgroundColor: const Color(0xFFFFE7EA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.emergency,
                color: Colors.red,
                size: 60,
              ),

              const SizedBox(height: 12),

              const Text(
                'Request Urgent Assistance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Demo only. This form does not contact '
                  'emergency services. For a real medical '
                  'emergency, call 1990.',
                  style: TextStyle(color: Colors.red),
                ),
              ),

              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                initialValue: _selectedService,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Select Service',
                  prefixIcon: const Icon(Icons.medical_services),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _services.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedService = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a service';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildField(
                _nameController,
                'Patient Name',
                Icons.person_outline,
              ),

              const SizedBox(height: 16),

              _buildField(
                _phoneController,
                'Contact Number',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              _buildField(
                _locationController,
                'Location',
                Icons.location_on_outlined,
              ),

              const SizedBox(height: 16),

              _buildField(
                _detailsController,
                'Additional Details',
                Icons.description_outlined,
                maxLines: 4,
                required: false,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
