
import 'package:flutter/material.dart';
import 'pediatric_medicine_request_store.dart';

class PediatricMedicineScreen extends StatefulWidget {
  const PediatricMedicineScreen({super.key});

  @override
  State<PediatricMedicineScreen> createState() =>
      _PediatricMedicineScreenState();
}
class _PediatricMedicineScreenState
    extends State<PediatricMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, String>> _requests =
    PediatricMedicineRequestStore.requests;
    Map<String, String>? _editingRequest;

  final _childNameController = TextEditingController();
  final _medicineController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _childNameController.dispose();
    _medicineController.dispose();
    _notesController.dispose();
    super.dispose();
  }
void _cancelEditing() {
  setState(() {
    _editingRequest = null;
    _childNameController.clear();
    _medicineController.clear();
    _notesController.clear();
  });
}
void _editRequest(Map<String, String> request) {
  setState(() {
    _editingRequest = request;

    _childNameController.text = request['childName'] ?? '';
    _medicineController.text = request['medicine'] ?? '';
    _notesController.text = request['notes'] ?? '';
  });
}

  

void _submitRequest() {
  if (!_formKey.currentState!.validate()) return;

  final updatedRequest = <String, String>{
    'childName': _childNameController.text.trim(),
    'medicine': _medicineController.text.trim(),
    'notes': _notesController.text.trim(),
  };

  final isEditing = _editingRequest != null;

  setState(() {
    if (isEditing) {
      // Update existing request.
      _editingRequest!.addAll(updatedRequest);
      _editingRequest = null;
    } else {
      // Add new request.
      _requests.add({
        ...updatedRequest,
        'status': 'Pending',
        'date': DateTime.now().toString().substring(0, 16),
      });
    }
  });

  _childNameController.clear();
  _medicineController.clear();
  _notesController.clear();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isEditing
            ? 'Medicine request updated!'
            : 'Medicine request saved to history!',
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pediatric Medicine'),
        backgroundColor: const Color(0xFFF3E8FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.medication_outlined,
                size: 65,
                color: Colors.purple,
              ),

              const SizedBox(height: 12),

              const Text(
                'Medicine Request',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              TextFormField(
                controller: _childNameController,
                decoration: const InputDecoration(
                  labelText: 'Child Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.child_care),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter child name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _medicineController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes / Prescription Details',
                  hintText: 'Enter details from an existing prescription',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _submitRequest,
                icon: const Icon(Icons.send),
               label: Text(
  _editingRequest == null
      ? 'Submit Request'
      : 'Save Changes',
),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
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
  'Medicine Request History',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

if (_requests.isEmpty)
  const Text('No medicine requests saved yet.'),

..._requests.reversed.map((request) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: const Icon(
        Icons.medication_outlined,
        color: Colors.purple,
      ),
      title: Text(request['medicine'] ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Child: ${request['childName']}'),
          Text('Notes: ${request['notes']}'),
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
  _editRequest(request);
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



              const Text(
                'Demo only. This form does not send a request '
                'to a pharmacy or healthcare provider. '
                'Use medicines only as directed by a '
                'qualified healthcare professional.',
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
