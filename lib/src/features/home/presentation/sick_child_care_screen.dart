import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'child_care_request_store.dart';

class SickChildCareScreen extends StatelessWidget {
  const SickChildCareScreen({super.key});

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
              title: const Text('Sick Child Care'),
              backgroundColor: const Color(0xFFFFE4EC),
            ),
            body: const Center(
              child: Text('Please log in to access child care.'),
            ),
          );
        }

        return _SickChildCareForm(key: ValueKey(snapshot.data!.uid));
      },
    );
  }
}

class _SickChildCareForm extends StatefulWidget {
  const _SickChildCareForm({super.key});

  @override
  State<_SickChildCareForm> createState() => _SickChildCareFormState();
}

class _SickChildCareFormState extends State<_SickChildCareForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _symptomsController = TextEditingController();

  // Firebase backend store
  final ChildCareRequestStore _store = ChildCareRequestStore();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _requestsStream;

  // Loading state
  bool _isBusy = false;

  static const List<String> _statuses = ['Pending', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();

    // Listen to requests from Firebase
    _requestsStream = _store.getRequests();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  // ==========================================
  // DISPLAY MESSAGE
  // ==========================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ==========================================
  // CREATE CHILD CARE REQUEST
  // ==========================================

  Future<void> _submitRequest() async {
    if (_isBusy) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final symptoms = _symptomsController.text.trim();

    if (age == null || age < 0 || age > 17) {
      _showMessage('Please enter a valid age.', isError: true);
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      await _store.addRequest(name: name, age: age, symptoms: symptoms);

      if (!mounted) return;

      _nameController.clear();
      _ageController.clear();
      _symptomsController.clear();

      _showMessage('Request saved successfully!');
    } on FirebaseException catch (e) {
      debugPrint('Firestore create error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied. Check Firebase rules.'
            : 'Unable to save request. Please try again.',
        isError: true,
      );
    } catch (_) {
      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  // ==========================================
  // UPDATE REQUEST STATUS
  // ==========================================

  Future<void> _updateStatus(String requestId, String newStatus) async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
    });

    try {
      await _store.updateStatus(requestId: requestId, status: newStatus);

      _showMessage('Request status updated successfully!');
    } on FirebaseException catch (e) {
      debugPrint('Firestore update error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied.'
            : 'Unable to update request status.',
        isError: true,
      );
    } catch (_) {
      _showMessage('Unable to update request status.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  // ==========================================
  // DELETE CHILD CARE REQUEST
  // ==========================================

  Future<void> _deleteRequest(String requestId) async {
    if (_isBusy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Request'),
          content: const Text('Are you sure you want to delete this request?'),
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
      _isBusy = true;
    });

    try {
      await _store.deleteRequest(requestId);

      _showMessage('Request deleted successfully!');
    } on FirebaseException catch (e) {
      debugPrint('Firestore delete error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied.'
            : 'Unable to delete request.',
        isError: true,
      );
    } catch (_) {
      _showMessage('Unable to delete request.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  // ==========================================
  // READ REQUEST HISTORY FROM FIREBASE
  // ==========================================

  Widget _buildRequestHistory() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _requestsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;

          if (error is FirebaseException) {
            debugPrint('Firestore read error: ${error.code}');
          }

          return const Text(
            'Unable to load requests. '
            'Check Firebase permissions.',
            style: TextStyle(color: Colors.red),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs.toList() ?? [];

        // Display newest requests first
        requests.sort((a, b) {
          final aTime = a.data()['createdAt'];
          final bTime = b.data()['createdAt'];

          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }

          if (aTime is Timestamp) return 1;
          if (bTime is Timestamp) return -1;

          return 0;
        });

        if (requests.isEmpty) {
          return const Text('No requests added yet.');
        }

        return Column(
          children: requests.map((doc) {
            final request = doc.data();

            final savedStatus = request['status']?.toString();

            final status = _statuses.contains(savedStatus)
                ? savedStatus!
                : 'Pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.child_care, color: Colors.pink),

                title: Text(request['name']?.toString() ?? ''),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Age: ${request['age']}'),

                    Text('Concern: ${request['symptoms']}'),

                    const SizedBox(height: 8),

                    DropdownButton<String>(
                      value: status,
                      underline: const SizedBox(),

                      items: _statuses.map((value) {
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

                      onChanged: _isBusy
                          ? null
                          : (newStatus) {
                              if (newStatus != null && newStatus != status) {
                                _updateStatus(doc.id, newStatus);
                              }
                            },
                    ),

                    if (doc.metadata.hasPendingWrites)
                      const Text(
                        'Syncing...',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete request',
                  onPressed: _isBusy ? null : () => _deleteRequest(doc.id),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ==========================================
  // EXISTING USER INTERFACE
  // ==========================================

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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text('Enter your child details below.'),

              const SizedBox(height: 25),

              // CHILD NAME
              TextFormField(
                controller: _nameController,
                enabled: !_isBusy,

                decoration: const InputDecoration(
                  labelText: 'Child Name',
                  prefixIcon: Icon(Icons.child_care),
                  border: OutlineInputBorder(),
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

              const SizedBox(height: 20),

              // CHILD AGE
              TextFormField(
                controller: _ageController,
                enabled: !_isBusy,
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

              // SYMPTOMS
              TextFormField(
                controller: _symptomsController,
                enabled: !_isBusy,
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

                  if (value.trim().length > 2000) {
                    return 'Description is too long';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              // SUBMIT REQUEST BUTTON
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: _isBusy ? null : _submitRequest,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),

                  child: _isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Request'),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Demo only: Requests are saved to the '
                'database but are not sent to a care '
                'provider. Use fictional information only. '
                'For emergencies, contact local '
                'emergency services.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              // REQUEST HISTORY
              const SizedBox(height: 30),

              const Text(
                'Request History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              _buildRequestHistory(),
            ],
          ),
        ),
      ),
    );
  }
}
