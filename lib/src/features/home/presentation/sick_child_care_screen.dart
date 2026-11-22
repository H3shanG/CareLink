
import 'package:flutter/material.dart';
import 'child_care_request_store.dart';

class SickChildCareScreen extends StatefulWidget {
  const SickChildCareScreen({super.key});

  @override
  State<SickChildCareScreen> createState() =>
      _SickChildCareScreenState();
}

class _SickChildCareScreenState
    extends State<SickChildCareScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, String>> _requests =
    ChildCareRequestStore.requests;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _symptomsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

 
void _submitRequest() {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _requests.add({
        'name': _nameController.text.trim(),
        'age': _ageController.text.trim(),
        'symptoms': _symptomsController.text.trim(),
        'status': 'Pending',
      });
    });

    _nameController.clear();
    _ageController.clear();
    _symptomsController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo request added to history!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sick Child Care'),
        backgroundColor: const Color(0xFFFFE4EC),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Request Child Care',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Enter your child details below.',
              ),

              const SizedBox(height: 25),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Child Name',
                  prefixIcon: Icon(Icons.child_care),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter child name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Child Age (Years)',
                  prefixIcon: Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final age = int.tryParse(value?.trim() ?? '');
                  if (age == null || age < 0 || age > 17) {
                    return 'Enter a valid age (0-17)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _symptomsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Symptoms / Health Concerns',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.medical_information_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the concern';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Submit Request'),
                ),
              ),

              const SizedBox(height: 12),

              
              const Text(
                'Demo only: This form does not send a request '
                'to a care provider. For emergencies, contact '
                'local emergency services.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              // REQUEST HISTORY STARTS HERE

              const SizedBox(height: 30),

              const Text(
                'Request History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              if (_requests.isEmpty)
                const Text('No requests added yet.'),

              ..._requests.map((request) {
final status = request['status'] ?? 'Pending';


return Card(
margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.child_care,
                      color: Colors.pink,
                    ),
                    title: Text(request['name'] ?? ''),
                   
subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Age: ${request['age']}'),
    Text('Concern: ${request['symptoms']}'),

    const SizedBox(height: 8),

   
DropdownButton<String>(
  value: status,
  underline: const SizedBox(),

  items: ['Pending', 'In Progress', 'Completed']
      .map((value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(
        value,
        style: TextStyle(
          color: value == 'Completed'
              ? Colors.green
              : value == 'In Progress'
                  ? Colors.blue
                  : Colors.orange,
        ),
      ),
    );
  }).toList(),

  onChanged: (newStatus) {
    if (newStatus != null) {
      setState(() {
        request['status'] = newStatus;
      });
    }
  },
),

  ],
),



trailing: IconButton(
  icon: const Icon(
    Icons.delete_outline,
    color: Colors.red,
  ),
  tooltip: 'Delete request',
  onPressed: () {
    setState(() {
      _requests.remove(request);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request deleted'),
      ),
    );
  },
),

                  ),
                );
              }),

              // REQUEST HISTORY ENDS HERE

            ], // Column children ends here
          ),
        ),
      ),
    );
  }
}

