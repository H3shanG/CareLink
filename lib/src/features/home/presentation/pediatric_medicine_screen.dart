import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pediatric_medicine_request_store.dart';

class PediatricMedicineScreen extends StatelessWidget {
  const PediatricMedicineScreen({super.key});

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

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pediatric Medicine'),
              backgroundColor: const Color(0xFFF3E8FF),
            ),
            body: const Center(
              child: Text('Please log in to access medicine requests.'),
            ),
          );
        }

        return _PediatricMedicineForm(key: ValueKey(snapshot.data!.uid));
      },
    );
  }
}

class _PediatricMedicineForm extends StatefulWidget {
  const _PediatricMedicineForm({super.key});

  @override
  State<_PediatricMedicineForm> createState() => _PediatricMedicineFormState();
}

class _PediatricMedicineFormState extends State<_PediatricMedicineForm> {
  final _formKey = GlobalKey<FormState>();

  // Firebase backend store
  final PediatricMedicineRequestStore _store = PediatricMedicineRequestStore();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _requestsStream;

  Map<String, String>? _editingRequest;

  bool _isBusy = false;

  // Text controllers
  final _childNameController = TextEditingController();
  final _medicineController = TextEditingController();
  final _notesController = TextEditingController();

  // ==========================================
  // INITIALIZE FIREBASE STREAM
  // ==========================================

  @override
  void initState() {
    super.initState();

    _requestsStream = _store.getRequests();
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _medicineController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ==========================================
  // CANCEL EDITING
  // ==========================================

  void _cancelEditing() {
    setState(() {
      _editingRequest = null;

      _childNameController.clear();
      _medicineController.clear();
      _notesController.clear();
    });
  }

  // ==========================================
  // EDIT EXISTING REQUEST
  // ==========================================

  void _editRequest(Map<String, String> request) {
    if (_isBusy) return;

    setState(() {
      _editingRequest = request;

      _childNameController.text = request['childName'] ?? '';

      _medicineController.text = request['medicine'] ?? '';

      _notesController.text = request['notes'] ?? '';
    });
  }

  // ==========================================
  // DISPLAY MESSAGES
  // ==========================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================
  // CREATE OR UPDATE MEDICINE REQUEST
  // ==========================================

  Future<void> _submitRequest() async {
    if (_isBusy) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final childName = _childNameController.text.trim();

    final medicine = _medicineController.text.trim();

    final notes = _notesController.text.trim();

    if (childName.length > 100 ||
        medicine.length > 200 ||
        notes.length > 2000) {
      _showMessage('Please shorten your request details.');

      return;
    }

    final requestId = _editingRequest?['id'];
    final isEditing = requestId != null;

    setState(() {
      _isBusy = true;
    });

    try {
      if (requestId != null) {
        // Update existing request

        await _store.updateRequest(
          requestId: requestId,
          childName: childName,
          medicine: medicine,
          notes: notes,
        );
      } else {
        // Create new request

        await _store.addRequest(
          childName: childName,
          medicine: medicine,
          notes: notes,
        );
      }

      if (!mounted) return;

      _cancelEditing();

      _showMessage(
        isEditing
            ? 'Medicine request updated!'
            : 'Medicine request saved to history!',
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('Firestore save error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied. Check Firebase rules.'
            : 'Unable to save medicine request.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  // ==========================================
  // DELETE MEDICINE REQUEST
  // ==========================================

  Future<void> _deleteRequest(String requestId) async {
    if (_isBusy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Request'),

        content: const Text(
          'Are you sure you want to delete '
          'this medicine request?',
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
      ),
    );

    if (confirmed != true || !mounted || _isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      await _store.deleteRequest(requestId);

      if (!mounted) return;

      if (_editingRequest?['id'] == requestId) {
        _cancelEditing();
      }

      _showMessage('Medicine request deleted!');
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('Firestore delete error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied.'
            : 'Unable to delete request.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage('Unable to delete request.');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  // ==========================================
  // DISPLAY REQUEST HISTORY FROM FIREBASE
  // ==========================================

  Widget _buildRequestHistory() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _requestsStream,

      builder: (context, snapshot) {
        // Handle Firebase errors

        if (snapshot.hasError) {
          final error = snapshot.error;

          if (error is FirebaseException) {
            debugPrint('Firestore read error: ${error.code}');
          }

          return const Text(
            'Unable to load medicine requests.',
            style: TextStyle(color: Colors.red),
          );
        }

        // Loading indicator

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs.toList() ?? [];

        // Sort newest requests first

        requests.sort((a, b) {
          final aTime = a.data()['createdAt'];
          final bTime = b.data()['createdAt'];

          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }

          if (aTime is Timestamp) return -1;
          if (bTime is Timestamp) return 1;

          return 0;
        });

        // Empty request history

        if (requests.isEmpty) {
          return const Text('No medicine requests saved yet.');
        }

        // Display request cards

        return Column(
          children: requests.map((doc) {
            final data = doc.data();

            final createdAt = data['createdAt'];

            final date = createdAt is Timestamp
                ? createdAt.toDate().toString().substring(0, 16)
                : 'Pending synchronization';

            final request = <String, String>{
              'id': doc.id,

              'childName': data['childName']?.toString() ?? '',

              'medicine': data['medicine']?.toString() ?? '',

              'notes': data['notes']?.toString() ?? '',

              'status': data['status']?.toString() ?? 'Pending',

              'date': date,
            };

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
                    // Edit button

                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),

                      onPressed: _isBusy
                          ? null
                          : () {
                              _editRequest(request);
                            },
                    ),

                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),

                      onPressed: _isBusy
                          ? null
                          : () {
                              _deleteRequest(doc.id);
                            },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ==========================================
  // ORIGINAL USER INTERFACE
  // ==========================================

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

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              // CHILD NAME FIELD
              TextFormField(
                controller: _childNameController,
                enabled: !_isBusy,

                decoration: const InputDecoration(
                  labelText: 'Child Name',
                  border: OutlineInputBorder(),

                  prefixIcon: Icon(Icons.child_care),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter child name';
                  }

                  if (value.trim().length > 100) {
                    return 'Child name is too long';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // MEDICINE NAME FIELD
              TextFormField(
                controller: _medicineController,
                enabled: !_isBusy,

                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),

                  prefixIcon: Icon(Icons.medication),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medicine name';
                  }

                  if (value.trim().length > 200) {
                    return 'Medicine name is too long';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // PRESCRIPTION NOTES FIELD
              TextFormField(
                controller: _notesController,
                enabled: !_isBusy,
                maxLines: 3,

                decoration: const InputDecoration(
                  labelText: 'Notes / Prescription Details',

                  hintText: 'Enter details from an existing prescription',

                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if ((value?.trim().length ?? 0) > 2000) {
                    return 'Notes are too long';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // SUBMIT REQUEST BUTTON
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _submitRequest,

                icon: _isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,

                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),

                label: Text(
                  _editingRequest == null ? 'Submit Request' : 'Save Changes',
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),

              // CANCEL EDITING BUTTON
              if (_editingRequest != null) ...[
                const SizedBox(height: 10),

                TextButton.icon(
                  onPressed: _isBusy ? null : _cancelEditing,

                  icon: const Icon(Icons.close),

                  label: const Text('Cancel Editing'),
                ),
              ],

              const SizedBox(height: 20),

              const Divider(),

              const SizedBox(height: 12),

              // REQUEST HISTORY TITLE
              const Text(
                'Medicine Request History',

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // FIREBASE REQUEST HISTORY
              _buildRequestHistory(),

              // DISCLAIMER
              const Text(
                'Demo only. Requests are saved to the '
                'database but are not sent to a pharmacy '
                'or healthcare provider. '
                'Use fictional information only. '
                'Use medicines only as directed by a '
                'qualified healthcare professional.',

                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
