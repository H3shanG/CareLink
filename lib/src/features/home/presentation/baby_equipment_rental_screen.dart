
import 'package:flutter/material.dart';
import 'baby_equipment_rental_store.dart';

class BabyEquipmentRentalScreen extends StatefulWidget {
  const BabyEquipmentRentalScreen({super.key});

  @override
  State<BabyEquipmentRentalScreen> createState() =>
      _BabyEquipmentRentalScreenState();
}

class _BabyEquipmentRentalScreenState
    extends State<BabyEquipmentRentalScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, String>> _requests =
    BabyEquipmentRentalStore.requests;
    Map<String, String>? _editingRequest;

  final _durationController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedEquipment = 'Baby Stroller';

  final List<String> _equipmentList = [
    'Baby Stroller',
    'Baby Crib',
    'Baby Car Seat',
    'Baby Walker',
    'Baby High Chair',
    'Baby Carrier',
  ];

  @override
  void dispose() {
    _durationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

void _cancelEditing() {
  setState(() {
    _editingRequest = null;
    _selectedEquipment = 'Baby Stroller';
    _durationController.clear();
    _addressController.clear();
  });
}
void _editRental(Map<String, String> request) {
  setState(() {
    _editingRequest = request;

    _selectedEquipment =
        request['equipment'] ?? 'Baby Stroller';

    _durationController.text =
        request['duration'] ?? '';

    _addressController.text =
        request['address'] ?? '';
  });
}
  

void _submitRental() {
  if (!_formKey.currentState!.validate()) return;

  final updatedRequest = <String, String>{
    'equipment': _selectedEquipment,
    'duration': _durationController.text.trim(),
    'address': _addressController.text.trim(),
  };

  final isEditing = _editingRequest != null;

  setState(() {
    if (isEditing) {
      // Update the existing rental request.
      _editingRequest!.addAll(updatedRequest);
      _editingRequest = null;
    } else {
      // Create a new rental request.
      _requests.add({
        ...updatedRequest,
        'status': 'Pending',
        'date': DateTime.now().toString().substring(0, 16),
      });
    }
  });

  _durationController.clear();
  _addressController.clear();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isEditing
            ? 'Rental request updated!'
            : 'Rental request saved to history!',
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Equipment Rental'),
        backgroundColor: const Color(0xFFE3F2FD),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.child_friendly,
                size: 65,
                color: Colors.blue,
              ),

              const SizedBox(height: 12),

              const Text(
                'Rent Baby Equipment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              DropdownButtonFormField<String>(
                key: ValueKey(_selectedEquipment),
                initialValue: _selectedEquipment,
                decoration: const InputDecoration(
                  labelText: 'Select Equipment',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                items: _equipmentList.map((equipment) {
                  return DropdownMenuItem<String>(
                    value: equipment,
                    child: Text(equipment),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedEquipment = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rental Duration (Days)',
                  hintText: 'Example: 7',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  final days = int.tryParse(value?.trim() ?? '');
                  if (days == null || days <= 0) {
                    return 'Enter a valid number of days';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Enter delivery address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter delivery address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _submitRental,
                icon: const Icon(Icons.send),
               label: Text(
  _editingRequest == null
      ? 'Submit Rental Request'
      : 'Save Changes',
),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              if (_editingRequest != null) ...[
  const SizedBox(height: 10),
  TextButton.icon(
    onPressed: _cancelEditing,
    icon: const Icon(Icons.close),
    label: const Text('Cancel Editing'),
  ),
],

              const SizedBox(height: 20),

const Divider(),

const SizedBox(height: 12),

const Text(
  'Rental Request History',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

if (_requests.isEmpty)
  const Text('No rental requests saved yet.'),

..._requests.reversed.map((request) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: const Icon(
        Icons.child_friendly,
        color: Colors.blue,
      ),
      title: Text(request['equipment'] ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Duration: ${request['duration']} days'),
          Text('Address: ${request['address']}'),
          Text('Status: ${request['status']}'),
          Text('Date: ${request['date']}'),
        ],
      ),
     
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(
        Icons.edit,
        color: Colors.blue,
      ),
     onPressed: () {
  _editRental(request);
},
    ),
    IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () {
        setState(() {
          _requests.remove(request);
        });
      },
    ),
  ],
),

    ),
  );
}),

const SizedBox(height: 16),


              const Text(
                'Demo only. Rental requests are not sent '
                'to equipment providers. Availability, '
                'pricing, and safety must be confirmed '
                'with a real provider.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
