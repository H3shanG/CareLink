import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'baby_health_record_store.dart';

class BabyHealthRecordScreen extends StatelessWidget {
  const BabyHealthRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Unable to verify login.')),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Baby Health Record')),
            body: const Center(
              child: Text('Please log in to access health records.'),
            ),
          );
        }

        return _BabyHealthRecordForm(key: ValueKey(user.uid));
      },
    );
  }
}

class _BabyHealthRecordForm extends StatefulWidget {
  const _BabyHealthRecordForm({super.key});

  @override
  State<_BabyHealthRecordForm> createState() => _BabyHealthRecordFormState();
}

class _BabyHealthRecordFormState extends State<_BabyHealthRecordForm> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  // Firebase backend service
  final BabyHealthRecordStore _store = BabyHealthRecordStore();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _recordsStream;

  // Form variables
  DateTime? _dateOfBirth;
  String _bloodGroup = 'Unknown';

  // Editing and loading states
  String? _editingRecordId;
  bool _isSaving = false;
  bool _isDeleting = false;

  static const List<String> _bloodGroups = [
    'Unknown',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  bool get _isBusy => _isSaving || _isDeleting;

  @override
  void initState() {
    super.initState();

    // Listen to Firebase records
    _recordsStream = _store.getRecords();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();

    super.dispose();
  }

  // ==========================================
  // SHOW MESSAGE
  // ==========================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================
  // FORMAT DATE
  // ==========================================

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ==========================================
  // SELECT DATE OF BIRTH
  // ==========================================

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (!mounted || pickedDate == null) return;

    setState(() {
      _dateOfBirth = pickedDate;
    });
  }

  // ==========================================
  // CLEAR FORM
  // ==========================================

  void _clearForm() {
    _formKey.currentState?.reset();

    setState(() {
      _editingRecordId = null;

      _nameController.clear();
      _weightController.clear();
      _heightController.clear();

      _dateOfBirth = null;
      _bloodGroup = 'Unknown';
    });
  }

  // ==========================================
  // CANCEL EDITING
  // ==========================================

  void _cancelEditing() {
    _clearForm();
  }

  // ==========================================
  // EDIT EXISTING RECORD
  // ==========================================

  void _editRecord(String recordId, Map<String, dynamic> record) {
    final dob = record['dob'];
    final bloodGroup = record['bloodGroup']?.toString() ?? 'Unknown';

    _formKey.currentState?.reset();

    setState(() {
      _editingRecordId = recordId;

      _nameController.text = record['name']?.toString() ?? '';

      _weightController.text = record['weight']?.toString() ?? '';

      _heightController.text = record['height']?.toString() ?? '';

      _bloodGroup = _bloodGroups.contains(bloodGroup) ? bloodGroup : 'Unknown';

      _dateOfBirth = dob is Timestamp ? dob.toDate() : null;
    });

    _showMessage('Editing baby profile');
  }

  // ==========================================
  // CREATE OR UPDATE RECORD
  // ==========================================

  Future<void> _saveProfile() async {
    if (_isBusy) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      _showMessage('Please select date of birth');
      return;
    }

    final weight = double.tryParse(_weightController.text.trim());

    final height = double.tryParse(_heightController.text.trim());

    if (weight == null ||
        height == null ||
        !weight.isFinite ||
        !height.isFinite ||
        weight <= 0 ||
        weight > 300 ||
        height <= 0 ||
        height > 250) {
      _showMessage('Please enter valid measurements');
      return;
    }

    final name = _nameController.text.trim();
    final dob = _dateOfBirth!;
    final bloodGroup = _bloodGroup;
    final recordId = _editingRecordId;

    final isEditing = recordId != null;

    setState(() {
      _isSaving = true;
    });

    try {
      if (isEditing) {
        // UPDATE existing Firebase document

        await _store.updateRecord(
          recordId: recordId,
          name: name,
          dob: dob,
          bloodGroup: bloodGroup,
          weight: weight,
          height: height,
        );
      } else {
        // CREATE new Firebase document

        await _store.addRecord(
          name: name,
          dob: dob,
          bloodGroup: bloodGroup,
          weight: weight,
          height: height,
        );
      }

      if (!mounted) return;

      _clearForm();

      _showMessage(
        isEditing
            ? 'Baby profile updated successfully!'
            : 'Baby profile saved successfully!',
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('Firestore save error: ${e.code}');

      if (e.code == 'permission-denied') {
        _showMessage('Permission denied. Check Firebase rules.');
      } else {
        _showMessage('Unable to save profile. Please try again.');
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ==========================================
  // DELETE RECORD
  // ==========================================

  Future<void> _deleteRecord(String recordId) async {
    if (_isBusy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Record'),
          content: const Text(
            'Are you sure you want to permanently '
            'delete this baby health record?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted || _isBusy) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await _store.deleteRecord(recordId);

      if (!mounted) return;

      if (_editingRecordId == recordId) {
        _clearForm();
      }

      _showMessage('Record deleted successfully!');
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('Firestore delete error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied.'
            : 'Unable to delete record.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage('Unable to delete record.');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // ==========================================
  // DISPLAY FIREBASE RECORDS
  // ==========================================

  Widget _buildRecordHistory() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _recordsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;

          if (error is FirebaseException) {
            debugPrint('Firestore read error: ${error.code}');
          }

          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Unable to load health records. '
              'Check your connection and permissions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final records = snapshot.data?.docs.toList() ?? [];

        // Sort newest records first
        records.sort((a, b) {
          final aTime = a.data()['updatedAt'];
          final bTime = b.data()['updatedAt'];

          final aDate = aTime is Timestamp
              ? aTime.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0);

          final bDate = bTime is Timestamp
              ? bTime.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0);

          return bDate.compareTo(aDate);
        });

        if (records.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.folder_open, size: 50, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  'No health records saved yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: records.map((doc) {
            final record = doc.data();

            final dob = record['dob'];
            final updatedAt = record['updatedAt'];

            final dobText = dob is Timestamp
                ? _formatDate(dob.toDate())
                : 'Unknown';

            final recordedText = updatedAt is Timestamp
                ? updatedAt.toDate().toString().substring(0, 16)
                : 'Pending synchronization';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF8F4),
                    child: Icon(Icons.child_care, color: Colors.teal),
                  ),
                  title: Text(
                    record['name']?.toString() ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      Text('DOB: $dobText'),

                      Text(
                        'Blood Group: '
                        '${record['bloodGroup'] ?? 'Unknown'}',
                      ),

                      Text(
                        'Weight: '
                        '${record['weight'] ?? '-'} kg',
                      ),

                      Text(
                        'Height: '
                        '${record['height'] ?? '-'} cm',
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Recorded: $recordedText',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),

                      if (doc.metadata.hasPendingWrites)
                        const Text(
                          'Syncing...',
                          style: TextStyle(color: Colors.orange, fontSize: 11),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT BUTTON

                      IconButton(
                        tooltip: 'Edit record',
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: _isBusy
                            ? null
                            : () {
                                _editRecord(doc.id, record);
                              },
                      ),

                      // DELETE BUTTON
                      IconButton(
                        tooltip: 'Delete record',
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _isBusy
                            ? null
                            : () {
                                _deleteRecord(doc.id);
                              },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ==========================================
  // BUILD USER INTERFACE
  // ==========================================

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
            // BABY ICON

            const Icon(Icons.child_care, size: 65, color: Colors.teal),

            const SizedBox(height: 12),

            // PAGE TITLE
            Text(
              _editingRecordId == null ? 'Baby Profile' : 'Edit Baby Profile',

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // BABY PROFILE FORM
            Form(
              key: _formKey,

              child: Column(
                children: [
                  // BABY NAME

                  TextFormField(
                    controller: _nameController,

                    enabled: !_isBusy,

                    maxLength: 100,

                    decoration: const InputDecoration(
                      labelText: 'Baby Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter baby name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // DATE OF BIRTH
                  SizedBox(
                    width: double.infinity,

                    child: OutlinedButton.icon(
                      onPressed: _isBusy ? null : _selectDate,

                      icon: const Icon(Icons.calendar_month),

                      label: Text(
                        _dateOfBirth == null
                            ? 'Select Date of Birth'
                            : 'Date: ${_formatDate(_dateOfBirth!)}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BLOOD GROUP
                  DropdownButtonFormField<String>(
                    key: ValueKey('$_editingRecordId-$_bloodGroup'),

                    initialValue: _bloodGroup,

                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      prefixIcon: Icon(Icons.bloodtype),
                      border: OutlineInputBorder(),
                    ),

                    items: _bloodGroups.map((group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      );
                    }).toList(),

                    onChanged: _isBusy
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _bloodGroup = value;
                              });
                            }
                          },
                  ),

                  const SizedBox(height: 16),

                  // WEIGHT
                  TextFormField(
                    controller: _weightController,

                    enabled: !_isBusy,

                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),

                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon: Icon(Icons.monitor_weight),
                      border: OutlineInputBorder(),
                    ),

                    validator: (value) {
                      final number = double.tryParse(value?.trim() ?? '');

                      if (number == null ||
                          !number.isFinite ||
                          number <= 0 ||
                          number > 300) {
                        return 'Enter a valid weight';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // HEIGHT
                  TextFormField(
                    controller: _heightController,

                    enabled: !_isBusy,

                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),

                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      prefixIcon: Icon(Icons.height),
                      border: OutlineInputBorder(),
                    ),

                    validator: (value) {
                      final number = double.tryParse(value?.trim() ?? '');

                      if (number == null ||
                          !number.isFinite ||
                          number <= 0 ||
                          number > 250) {
                        return 'Enter a valid height';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: _isBusy ? null : _saveProfile,

                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _editingRecordId == null
                                  ? 'Save Baby Profile'
                                  : 'Save Changes',
                            ),
                    ),
                  ),

                  // CANCEL EDITING BUTTON
                  if (_editingRecordId != null) ...[
                    const SizedBox(height: 10),

                    TextButton.icon(
                      onPressed: _isBusy ? null : _cancelEditing,

                      icon: const Icon(Icons.close),

                      label: const Text('Cancel Editing'),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 10),

            // RECORD HISTORY TITLE
            const Text(
              'Baby Health Record History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (_isDeleting) const LinearProgressIndicator(),

            // REAL-TIME FIREBASE RECORDS
            _buildRecordHistory(),

            const SizedBox(height: 16),

            const Text(
              'Student prototype. Use fictional '
              'health information only.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
