import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'emergency_transport_request_store.dart';

class EmergencyTransportScreen extends StatelessWidget {
  const EmergencyTransportScreen({super.key});

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
              title: const Text('Emergency Transport'),
              backgroundColor: const Color(0xFFFFE7EA),
            ),
            body: const Center(
              child: Text('Please log in to access demo requests.'),
            ),
          );
        }

        return _EmergencyTransportContent(
          key: ValueKey(snapshot.data!.uid),
          userId: snapshot.data!.uid,
        );
      },
    );
  }
}

class _EmergencyTransportContent extends StatefulWidget {
  final String userId;

  const _EmergencyTransportContent({super.key, required this.userId});

  @override
  State<_EmergencyTransportContent> createState() =>
      _EmergencyTransportContentState();
}

class _EmergencyTransportContentState
    extends State<_EmergencyTransportContent> {
  final _formKey = GlobalKey<FormState>();

  final EmergencyTransportRequestStore _store =
      EmergencyTransportRequestStore();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _requestsStream;

  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _detailsController = TextEditingController();

  String? _editingRequestId;

  bool _isBusy = false;

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
    _locationController.dispose();
    _contactController.dispose();
    _detailsController.dispose();

    super.dispose();
  }

  // ==========================================
  // CHECK LOGGED-IN USER
  // ==========================================

  bool get _isCurrentUser =>
      FirebaseAuth.instance.currentUser?.uid == widget.userId;

  // ==========================================
  // DISPLAY MESSAGES
  // ==========================================

  void _showMessage(String message) {
    if (!mounted || !_isCurrentUser) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================
  // CLEAR FORM
  // ==========================================

  void _clearForm() {
    _locationController.clear();
    _contactController.clear();
    _detailsController.clear();

    setState(() {
      _editingRequestId = null;
    });

    _formKey.currentState?.reset();
  }

  // ==========================================
  // EDIT EXISTING REQUEST
  // ==========================================

  void _editRequest(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    if (_isBusy || !_isCurrentUser) return;

    final request = doc.data();

    setState(() {
      _editingRequestId = doc.id;

      _locationController.text = request['location']?.toString() ?? '';

      _contactController.text = request['contact']?.toString() ?? '';

      _detailsController.text = request['details']?.toString() ?? '';
    });
  }

  // ==========================================
  // CREATE OR UPDATE FIREBASE REQUEST
  // ==========================================

  Future<void> _submitRequest() async {
    if (_isBusy || !_isCurrentUser) return;

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final requestId = _editingRequestId;

    final location = _locationController.text.trim();
    final contact = _contactController.text.trim();
    final details = _detailsController.text.trim();

    setState(() {
      _isBusy = true;
    });

    try {
      if (requestId != null) {
        await _store.updateRequest(
          requestId: requestId,
          location: location,
          contact: contact,
          details: details,
        );
      } else {
        await _store.addRequest(
          location: location,
          contact: contact,
          details: details,
        );
      }

      if (!mounted || !_isCurrentUser) return;

      _clearForm();

      _showMessage(
        requestId != null
            ? 'Demo request updated successfully!'
            : 'Demo request saved to history only!',
      );
    } on FirebaseException catch (e) {
      debugPrint('Emergency transport Firebase error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied. Check Firebase rules.'
            : 'Unable to save demo request.',
      );
    } on ArgumentError catch (e) {
      _showMessage(e.message?.toString() ?? 'Invalid request details.');
    } on StateError catch (e) {
      _showMessage(e.message);
    } catch (_) {
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
  // DELETE FIREBASE REQUEST
  // ==========================================

  Future<void> _deleteRequest(String requestId) async {
    if (_isBusy || !_isCurrentUser) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Request'),
          content: const Text(
            'Are you sure you want to delete '
            'this demo transport request?',
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

    if (!mounted || confirmed != true || _isBusy || !_isCurrentUser) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      await _store.deleteRequest(requestId);

      if (!mounted || !_isCurrentUser) return;

      if (_editingRequestId == requestId) {
        _clearForm();
      }

      _showMessage('Demo request deleted!');
    } on FirebaseException catch (e) {
      debugPrint('Emergency transport delete error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied.'
            : 'Unable to delete request.',
      );
    } on StateError catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Unable to delete demo request.');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  // ==========================================
  // FORMAT FIRESTORE TIMESTAMP
  // ==========================================

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal().toString().substring(0, 16);
    }

    return 'Pending synchronization';
  }

  // ==========================================
  // VALIDATE CONTACT NUMBER
  // ==========================================

  String? _validateContact(String? value) {
    final contact = value?.trim() ?? '';

    if (contact.isEmpty) {
      return 'Please enter contact number';
    }

    final validPhone = RegExp(r'^\+?[0-9][0-9\s-]*$').hasMatch(contact);

    final digitCount = contact.replaceAll(RegExp(r'[^0-9]'), '').length;

    if (!validPhone ||
        digitCount < 7 ||
        digitCount > 15 ||
        contact.length > 30) {
      return 'Please enter a valid contact number';
    }

    return null;
  }

  // ==========================================
  // FIREBASE REQUEST HISTORY
  // ==========================================

  Widget _buildRequestHistory() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _requestsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;

          if (error is FirebaseException) {
            debugPrint('Emergency request history error: ${error.code}');
          }

          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Unable to load request history. '
              'Check your connection and Firebase permissions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs.toList() ?? [];

        // Sort newest requests first.

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

        if (requests.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Request History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ...requests.map((doc) {
              final request = doc.data();

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.red),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Request',
                        onPressed: _isBusy
                            ? null
                            : () {
                                _editRequest(doc);
                              },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Request',
                        onPressed: _isBusy
                            ? null
                            : () {
                                _deleteRequest(doc.id);
                              },
                      ),
                    ],
                  ),

                  title: Text('Pickup: ${request['location'] ?? ''}'),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact: ${request['contact'] ?? ''}'),

                      Text('Details: ${request['details'] ?? ''}'),

                      Text(
                        'Submitted: '
                        '${_formatDate(request['createdAt'])}',
                      ),

                      const Text('Status: Demo Only'),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // ==========================================
  // ORIGINAL FRONTEND DESIGN
  // ==========================================

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
              const Icon(Icons.emergency, size: 65, color: Colors.red),

              const SizedBox(height: 12),

              const Text(
                'Emergency Transport Request',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              const Text(
                'DEMO ONLY - This form does not contact '
                'an ambulance or emergency service. '
                'For a real emergency in Sri Lanka, '
                'call 1990 directly. '
                'Use fictional information only.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // PICKUP LOCATION
              TextFormField(
                controller: _locationController,
                enabled: !_isBusy,

                decoration: const InputDecoration(
                  labelText: 'Pickup Location',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter pickup location';
                  }

                  if (value.trim().length > 500) {
                    return 'Pickup location is too long';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // CONTACT NUMBER
              TextFormField(
                controller: _contactController,
                enabled: !_isBusy,
                keyboardType: TextInputType.phone,

                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),

                validator: _validateContact,
              ),

              const SizedBox(height: 16),

              // EMERGENCY DETAILS
              TextFormField(
                controller: _detailsController,
                enabled: !_isBusy,
                maxLines: 3,

                decoration: const InputDecoration(
                  labelText: 'Emergency Details (Optional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if ((value?.trim().length ?? 0) > 2000) {
                    return 'Emergency details are too long';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // SUBMIT OR UPDATE REQUEST
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _submitRequest,

                icon: const Icon(Icons.send),

                label: Text(
                  _isBusy
                      ? 'Saving...'
                      : _editingRequestId == null
                      ? 'Submit Demo Request'
                      : 'Save Changes',
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),

              // CANCEL EDITING
              if (_editingRequestId != null)
                TextButton(
                  onPressed: _isBusy ? null : _clearForm,
                  child: const Text('Cancel Editing'),
                ),

              if (_isBusy)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(color: Colors.red),
                ),

              const SizedBox(height: 24),

              // FIREBASE REQUEST HISTORY
              _buildRequestHistory(),
            ],
          ),
        ),
      ),
    );
  }
}
