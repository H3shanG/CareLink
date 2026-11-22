
import 'package:flutter/material.dart';
import 'baby_health_record_store.dart';
class BabyHealthRecordScreen extends StatefulWidget {
  const BabyHealthRecordScreen({super.key});

  @override
  State<BabyHealthRecordScreen> createState() =>
      _BabyHealthRecordScreenState();
}

class _BabyHealthRecordScreenState
    extends State<BabyHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  DateTime? _dateOfBirth;
  String _bloodGroup = 'Unknown';

 final List<Map<String, String>> _records =
    BabyHealthRecordStore.records;
    Map<String, String>? _editingRecord;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _dateOfBirth = pickedDate;
      });
    }
  }
void _cancelEditing() {
  setState(() {
    _editingRecord = null;
    _nameController.clear();
    _weightController.clear();
    _heightController.clear();
    _dateOfBirth = null;
    _bloodGroup = 'Unknown';
  });
}
 
void _editRecord(Map<String, String> record) {
  final parts = (record['dob'] ?? '').split('/');

  if (parts.length != 3) return;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) return;

  setState(() {
    _editingRecord = record;

    _nameController.text = record['name'] ?? '';
    _weightController.text = record['weight'] ?? '';
    _heightController.text = record['height'] ?? '';
    _bloodGroup = record['bloodGroup'] ?? 'Unknown';

    _dateOfBirth = DateTime(year, month, day);
  });
}

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
        ),
      );
      return;
    }


final updatedRecord = <String, String>{
  'name': _nameController.text.trim(),
  'dob':
      '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
  'bloodGroup': _bloodGroup,
  'weight': _weightController.text.trim(),
  'height': _heightController.text.trim(),
  'recordedAt': DateTime.now().toString().substring(0, 16),
};

setState(() {
  if (_editingRecord != null) {
    // Update the existing record.
    _editingRecord!.addAll(updatedRecord);
    _editingRecord = null;
  } else {
    // Save a new record.
    _records.add(updatedRecord);
  }
});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Baby profile saved successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Health Record'),
        backgroundColor: const Color(0xFFEAF8F4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.child_care,
              size: 65,
              color: Colors.teal,
            ),
            const SizedBox(height: 12),
            const Text(
              'Baby Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Baby Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter baby name'
                            : null,
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      _dateOfBirth == null
                          ? 'Select Date of Birth'
                          : 'Date: ${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _bloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Unknown',
                      'A+',
                      'A-',
                      'B+',
                      'B-',
                      'AB+',
                      'AB-',
                      'O+',
                      'O-',
                    ].map((group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Text(group),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _bloodGroup = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final number =
                          double.tryParse(value?.trim() ?? '');
                      if (number == null || number <= 0) {
                        return 'Enter a valid weight';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _heightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final number =
                          double.tryParse(value?.trim() ?? '');
                      if (number == null || number <= 0) {
                        return 'Enter a valid height';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text(
         _editingRecord == null
      ? 'Save Baby Profile'
      : 'Save Changes',
      
),
                    ),
                  ),if (_editingRecord != null) ...[
  const SizedBox(height: 10),
  TextButton.icon(
    onPressed: _cancelEditing,
    icon: const Icon(Icons.close),
    label: const Text('Cancel Editing'),
  ),
],
                ],
              ),
            ),

           
const SizedBox(height: 30),
const Divider(),

const Text(
  'Baby Health Record History',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

if (_records.isEmpty)
  const Text('No health records saved yet.'),

..._records.reversed.map((record) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: const Icon(
        Icons.child_care,
        color: Colors.teal,
      ),
      title: Text(record['name'] ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DOB: ${record['dob']}'),
          Text('Blood Group: ${record['bloodGroup']}'),
          Text('Weight: ${record['weight']} kg'),
          Text('Height: ${record['height']} cm'),
          Text('Recorded: ${record['recordedAt']}'),
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
  _editRecord(record);
},
    ),
    IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () {
        setState(() {
          _records.remove(record);
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
              'Demo only. Records are stored temporarily '
              'on this screen and are not medical records.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
