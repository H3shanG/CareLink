
import 'package:flutter/material.dart';
import 'emergency_transport_request_store.dart';

class EmergencyTransportScreen extends StatefulWidget {
  const EmergencyTransportScreen({super.key});

  @override
  State<EmergencyTransportScreen> createState() =>
      _EmergencyTransportScreenState();
}

class _EmergencyTransportScreenState
    extends State<EmergencyTransportScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, String>? _editingRequest;
  final List<Map<String, String>> _requests =
    EmergencyTransportRequestStore.requests;

  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _detailsController = TextEditingController();

void _editRequest(Map<String, String> request) {
  setState(() {
    _editingRequest = request;

    _locationController.text = request['location'] ?? '';
    _contactController.text = request['contact'] ?? '';
    _detailsController.text = request['details'] ?? '';
  });
}



void _submitRequest() {
  if (!_formKey.currentState!.validate()) return;

  final isEditing = _editingRequest != null;

  final updatedRequest = <String, String>{
    'location': _locationController.text.trim(),
    'contact': _contactController.text.trim(),
    'details': _detailsController.text.trim(),
  };

  setState(() {
    if (isEditing) {
      _editingRequest!.addAll(updatedRequest);
      _editingRequest = null;
    } else {
      _requests.add({
        ...updatedRequest,
        'status': 'Demo Only',
        'date': DateTime.now().toString().substring(0, 16),
      });
    }
  });

  _locationController.clear();
  _contactController.clear();
  _detailsController.clear();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isEditing
            ? 'Demo request updated successfully!'
            : 'Demo request saved to history only!',
      ),
    ),
  );
}


  @override
  void dispose() {
    _locationController.dispose();
    _contactController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Transport'),
        backgroundColor: const Color(0xFFFFE7EA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.emergency,
                size: 65,
                color: Colors.red,
              ),

              const SizedBox(height: 12),

              const Text(
                'Emergency Transport Request',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'DEMO ONLY — This form does not contact '
                'an ambulance or emergency service. '
                'For a real emergency in Sri Lanka, '
                'call 1990 directly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Pickup Location',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter pickup location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _detailsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Emergency Details (Optional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _submitRequest,
                icon: const Icon(Icons.send),
               label: Text(
  _editingRequest == null
      ? 'Submit Demo Request'
      : 'Save Changes',
),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              
const SizedBox(height: 24),

if (_requests.isNotEmpty) ...[
  const Text(
    'Request History',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(height: 12),

  ..._requests.reversed.map((request) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.history,
          color: Colors.red,
        ),
        

trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(
        Icons.edit,
        color: Colors.blue,
      ),
      tooltip: 'Edit Request',
      onPressed: () {
        _editRequest(request);
      },
    ),
    IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      tooltip: 'Delete Request',
      onPressed: () {
        setState(() {
          if (identical(_editingRequest, request)) {
            _editingRequest = null;
            _locationController.clear();
            _contactController.clear();
            _detailsController.clear();
          }

          _requests.remove(request);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo request deleted!'),
          ),
        );
      },
    ),
  ],
),

        title: Text(
          'Pickup: ${request['location']}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact: ${request['contact']}'),
            Text('Details: ${request['details']}'),
            Text('Submitted: ${request['date']}'),
            Text('Status: ${request['status']}'),
          ],
        ),
      ),
    );
  }),
],

            ],
          ),
        ),
      ),
    );
  }
}
