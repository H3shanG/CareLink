import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'baby_equipment_rental_store.dart';

class BabyEquipmentRentalScreen extends StatelessWidget {
  const BabyEquipmentRentalScreen({super.key});

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
              title: const Text('Baby Equipment Rental'),
              backgroundColor: const Color(0xFFE3F2FD),
            ),
            body: const Center(
              child: Text('Please log in to access rental requests.'),
            ),
          );
        }

        return _BabyEquipmentRentalForm(key: ValueKey(snapshot.data!.uid));
      },
    );
  }
}

class _BabyEquipmentRentalForm extends StatefulWidget {
  const _BabyEquipmentRentalForm({super.key});

  @override
  State<_BabyEquipmentRentalForm> createState() =>
      _BabyEquipmentRentalFormState();
}

class _BabyEquipmentRentalFormState extends State<_BabyEquipmentRentalForm> {
  final _formKey = GlobalKey<FormState>();

  // Firebase backend store
  final BabyEquipmentRentalStore _store = BabyEquipmentRentalStore();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _requestsStream;

  Map<String, String>? _editingRequest;

  bool _isBusy = false;

  // Text controllers
  final _durationController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedEquipment = 'Baby Stroller';

  final List<String> _equipmentList = BabyEquipmentRentalStore.equipmentList;

  // ==========================================
  // INITIALIZE FIREBASE STREAM
  // ==========================================

  @override
  void initState() {
    super.initState();

    _requestsStream = _store.getRentals();
  }

  @override
  void dispose() {
    _durationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ==========================================
  // CANCEL EDITING
  // ==========================================

  void _cancelEditing() {
    setState(() {
      _editingRequest = null;
      _selectedEquipment = 'Baby Stroller';

      _durationController.clear();
      _addressController.clear();
    });
  }

  // ==========================================
  // EDIT RENTAL REQUEST
  // ==========================================

  void _editRental(Map<String, String> request) {
    if (_isBusy) return;

    setState(() {
      _editingRequest = request;

      final equipment = request['equipment'];

      _selectedEquipment = _equipmentList.contains(equipment)
          ? equipment!
          : 'Baby Stroller';

      _durationController.text = request['duration'] ?? '';

      _addressController.text = request['address'] ?? '';
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
  // CREATE OR UPDATE RENTAL REQUEST
  // ==========================================

  Future<void> _submitRental() async {
    if (_isBusy) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final equipment = _selectedEquipment;

    final duration = int.tryParse(_durationController.text.trim());

    final address = _addressController.text.trim();

    if (duration == null || duration <= 0) {
      _showMessage('Enter a valid rental duration.');
      return;
    }

    if (address.isEmpty || address.length > 500) {
      _showMessage('Enter a valid delivery address.');
      return;
    }

    final requestId = _editingRequest?['id'];
    final isEditing = requestId != null;

    setState(() {
      _isBusy = true;
    });

    try {
      if (requestId != null) {
        // Update existing rental request

        await _store.updateRental(
          requestId: requestId,
          equipment: equipment,
          duration: duration,
          address: address,
        );
      } else {
        // Create new rental request

        await _store.addRental(
          equipment: equipment,
          duration: duration,
          address: address,
        );
      }

      if (!mounted) return;

      _cancelEditing();

      _showMessage(
        isEditing
            ? 'Rental request updated!'
            : 'Rental request saved to history!',
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('Firestore save error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied. Check Firebase rules.'
            : 'Unable to save rental request.',
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
  // DELETE RENTAL REQUEST
  // ==========================================

  Future<void> _deleteRental(String requestId) async {
    if (_isBusy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Rental Request'),

        content: const Text(
          'Are you sure you want to delete '
          'this rental request?',
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
      await _store.deleteRental(requestId);

      if (!mounted) return;

      if (_editingRequest?['id'] == requestId) {
        _cancelEditing();
      }

      _showMessage('Rental request deleted!');
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('Firestore delete error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied.'
            : 'Unable to delete rental request.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage('Unable to delete rental request.');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  // ==========================================
  // DISPLAY RENTAL HISTORY FROM FIREBASE
  // ==========================================

  Widget _buildRentalHistory() {
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
            'Unable to load rental requests.',
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
          return const Text('No rental requests saved yet.');
        }

        // Display rental cards

        return Column(
          children: requests.map((doc) {
            final data = doc.data();

            final createdAt = data['createdAt'];

            final date = createdAt is Timestamp
                ? createdAt.toDate().toString().substring(0, 16)
                : 'Pending synchronization';

            final request = <String, String>{
              'id': doc.id,

              'equipment': data['equipment']?.toString() ?? '',

              'duration': data['duration']?.toString() ?? '',

              'address': data['address']?.toString() ?? '',

              'status': data['status']?.toString() ?? 'Pending',

              'date': date,
            };

            return Card(
              margin: const EdgeInsets.only(bottom: 12),

              child: ListTile(
                leading: const Icon(Icons.child_friendly, color: Colors.blue),

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
                    // Edit button

                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),

                      onPressed: _isBusy
                          ? null
                          : () {
                              _editRental(request);
                            },
                    ),

                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),

                      onPressed: _isBusy
                          ? null
                          : () {
                              _deleteRental(doc.id);
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
              const Icon(Icons.child_friendly, size: 65, color: Colors.blue),

              const SizedBox(height: 12),

              const Text(
                'Rent Baby Equipment',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              // EQUIPMENT DROPDOWN
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

                onChanged: _isBusy
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedEquipment = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 16),

              // RENTAL DURATION FIELD
              TextFormField(
                controller: _durationController,

                enabled: !_isBusy,

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

              // DELIVERY ADDRESS FIELD
              TextFormField(
                controller: _addressController,

                enabled: !_isBusy,

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

                  if (value.trim().length > 500) {
                    return 'Delivery address is too long';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // SUBMIT RENTAL REQUEST BUTTON
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _submitRental,

                icon: _isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),

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

              // RENTAL HISTORY TITLE
              const Text(
                'Rental Request History',

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // FIREBASE RENTAL HISTORY
              _buildRentalHistory(),

              const SizedBox(height: 16),

              // DISCLAIMER
              const Text(
                'Demo only. Rental requests are saved '
                'to the database but are not sent to '
                'equipment providers. '
                'Use fictional information only. '
                'Availability, pricing, and safety must '
                'be confirmed with a real provider.',

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
