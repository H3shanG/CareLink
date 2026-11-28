import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pediatrician_appointment_store.dart';

class PediatricianLocatorScreen extends StatelessWidget {
  const PediatricianLocatorScreen({super.key});

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
              title: const Text('Pediatrician Locator'),
              backgroundColor: const Color(0xFFE8F5E9),
            ),
            body: const Center(
              child: Text('Please log in to access appointments.'),
            ),
          );
        }

        return _PediatricianLocatorContent(key: ValueKey(snapshot.data!.uid));
      },
    );
  }
}

class _PediatricianLocatorContent extends StatefulWidget {
  const _PediatricianLocatorContent({super.key});

  @override
  State<_PediatricianLocatorContent> createState() =>
      _PediatricianLocatorContentState();
}

class _PediatricianLocatorContentState
    extends State<_PediatricianLocatorContent> {
  final _searchController = TextEditingController();

  final PediatricianAppointmentStore _store = PediatricianAppointmentStore();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _doctorsStream;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _appointmentsStream;

  String _searchQuery = '';

  bool _isBusy = false;

  // ==========================================
  // INITIALIZE FIREBASE STREAMS
  // ==========================================

  @override
  void initState() {
    super.initState();

    _doctorsStream = _store.getPediatricians();
    _appointmentsStream = _store.getAppointments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
  // FORMAT DATE
  // ==========================================

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ==========================================
  // CREATE OR EDIT APPOINTMENT
  // ==========================================

  Future<void> _showAppointmentForm({
    required String doctorId,
    String? appointmentId,
    String childName = '',
    DateTime? existingAppointment,
  }) async {
    if (_isBusy) return;

    final isEditing = appointmentId != null;

    final result = await showDialog<_AppointmentFormResult>(
      context: context,
      builder: (context) {
        return _AppointmentFormDialog(
          isEditing: isEditing,
          childName: childName,
          existingAppointment: existingAppointment,
        );
      },
    );

    if (!mounted || result == null || _isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      if (appointmentId != null) {
        await _store.updateAppointment(
          appointmentId: appointmentId,
          childName: result.childName,
          appointmentAt: result.appointmentAt,
        );
      } else {
        await _store.addAppointment(
          doctorId: doctorId,
          childName: result.childName,
          appointmentAt: result.appointmentAt,
        );
      }

      if (!mounted) return;

      _showMessage(
        isEditing ? 'Appointment updated!' : 'Demo appointment request saved!',
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('Firestore appointment error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied. Check Firebase rules.'
            : 'Unable to save appointment.',
      );
    } on ArgumentError catch (e) {
      if (!mounted) return;

      _showMessage(e.message?.toString() ?? 'Invalid appointment details.');
    } on StateError catch (e) {
      if (!mounted) return;

      _showMessage(e.message);
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
  // EDIT EXISTING APPOINTMENT
  // ==========================================

  Future<void> _editAppointment(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    final appointmentAt = data['appointmentAt'];

    await _showAppointmentForm(
      doctorId: data['doctorId']?.toString() ?? '',
      appointmentId: doc.id,
      childName: data['childName']?.toString() ?? '',
      existingAppointment: appointmentAt is Timestamp
          ? appointmentAt.toDate().toLocal()
          : null,
    );
  }

  // ==========================================
  // DELETE APPOINTMENT
  // ==========================================

  Future<void> _deleteAppointment(String appointmentId) async {
    if (_isBusy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Appointment'),
          content: const Text(
            'Are you sure you want to delete '
            'this appointment request?',
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

    if (!mounted || confirmed != true || _isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      await _store.deleteAppointment(appointmentId);

      if (!mounted) return;

      _showMessage('Appointment deleted!');
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint('Firestore delete error: ${e.code}');

      _showMessage(
        e.code == 'permission-denied'
            ? 'Permission denied.'
            : 'Unable to delete appointment.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage('Unable to delete appointment.');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  // ==========================================
  // DISPLAY DOCTOR DETAILS
  // ==========================================

  Future<void> _showDoctorDetails(
    String doctorId,
    Map<String, dynamic> doctor,
  ) async {
    final requestAppointment = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(doctor['name']?.toString() ?? 'Doctor Details'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Icon(Icons.medical_services, size: 50, color: Colors.green),

              const SizedBox(height: 16),

              Text(
                'Specialization: '
                '${doctor['specialization'] ?? ''}',
              ),

              const SizedBox(height: 8),

              Text('Hospital: ${doctor['hospital'] ?? ''}'),

              const SizedBox(height: 8),

              Text('Location: ${doctor['location'] ?? ''}'),

              const SizedBox(height: 16),

              const Text(
                'Demo profile only. Provider details '
                'are fictional.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),

          actions: [
            ElevatedButton.icon(
              onPressed: _isBusy
                  ? null
                  : () {
                      Navigator.pop(dialogContext, true);
                    },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Request Appointment'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    if (!mounted || requestAppointment != true) {
      return;
    }

    await _showAppointmentForm(doctorId: doctorId);
  }

  // ==========================================
  // FIREBASE PEDIATRICIAN DIRECTORY
  // ==========================================

  Widget _buildDoctorList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _doctorsStream,

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;

          if (error is FirebaseException) {
            debugPrint('Doctor directory error: ${error.code}');
          }

          return const Center(
            child: Text(
              'Unable to load pediatricians.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final doctors = snapshot.data?.docs.toList() ?? [];

        final query = _searchQuery.toLowerCase();

        final filteredDoctors = doctors.where((doc) {
          final doctor = doc.data();

          final name = doctor['name']?.toString().toLowerCase() ?? '';

          final location = doctor['location']?.toString().toLowerCase() ?? '';

          final hospital = doctor['hospital']?.toString().toLowerCase() ?? '';

          return name.contains(query) ||
              location.contains(query) ||
              hospital.contains(query);
        }).toList();

        filteredDoctors.sort((a, b) {
          final aName = a.data()['name']?.toString() ?? '';

          final bName = b.data()['name']?.toString() ?? '';

          return aName.compareTo(bName);
        });

        if (filteredDoctors.isEmpty) {
          return const Center(child: Text('No pediatricians found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),

          itemCount: filteredDoctors.length,

          itemBuilder: (context, index) {
            final doc = filteredDoctors[index];
            final doctor = doc.data();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),

              child: ListTile(
                onTap: () {
                  _showDoctorDetails(doc.id, doctor);
                },

                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),

                  child: Icon(Icons.medical_services, color: Colors.green),
                ),

                title: Text(
                  doctor['name']?.toString() ?? '',

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const SizedBox(height: 6),

                    Text(doctor['specialization']?.toString() ?? ''),

                    Text(
                      'Hospital: '
                      '${doctor['hospital'] ?? ''}',
                    ),

                    Text(
                      'Location: '
                      '${doctor['location'] ?? ''}',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // FIREBASE APPOINTMENT HISTORY
  // ==========================================

  Widget _buildAppointmentHistory() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _appointmentsStream,

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;

          if (error is FirebaseException) {
            debugPrint('Appointment history error: ${error.code}');
          }

          return const Padding(
            padding: EdgeInsets.all(12),

            child: Text(
              'Unable to load appointments.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(12),

            child: CircularProgressIndicator(),
          );
        }

        final appointments = snapshot.data?.docs.toList() ?? [];

        // Sort newest requests first

        appointments.sort((a, b) {
          final aTime = a.data()['createdAt'];
          final bTime = b.data()['createdAt'];

          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }

          if (aTime is Timestamp) return -1;
          if (bTime is Timestamp) return 1;

          return 0;
        });

        if (appointments.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Padding(
              padding: EdgeInsets.all(12),

              child: Text(
                'Appointment History',

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(
              height: 200,

              child: ListView.builder(
                itemCount: appointments.length,

                itemBuilder: (context, index) {
                  final doc = appointments[index];
                  final appointment = doc.data();

                  final appointmentAt = appointment['appointmentAt'];

                  final createdAt = appointment['createdAt'];

                  final requestedDate = appointmentAt is Timestamp
                      ? _formatDate(appointmentAt.toDate().toLocal())
                      : 'Not selected';

                  final requestedTime = appointmentAt is Timestamp
                      ? TimeOfDay.fromDateTime(appointmentAt.toDate().toLocal())
                            .format(context)
                      : 'Not selected';

                  final submittedDate = createdAt is Timestamp
                      ? createdAt.toDate().toLocal().toString().substring(0, 16)
                      : 'Pending synchronization';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),

                    child: ListTile(
                      leading: const Icon(
                        Icons.calendar_month,
                        color: Colors.green,
                      ),

                      title: Text(appointment['doctor']?.toString() ?? ''),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Child: '
                            '${appointment['childName'] ?? ''}',
                          ),

                          Text('Requested Date: $requestedDate'),

                          Text('Requested Time: $requestedTime'),

                          Text(
                            'Status: '
                            '${appointment['status'] ?? 'Pending'}',
                          ),

                          Text('Submitted: $submittedDate'),
                        ],
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),

                            tooltip: 'Edit Appointment',

                            onPressed: _isBusy
                                ? null
                                : () {
                                    _editAppointment(doc);
                                  },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),

                            tooltip: 'Delete Appointment',

                            onPressed: _isBusy
                                ? null
                                : () {
                                    _deleteAppointment(doc.id);
                                  },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
        title: const Text('Pediatrician Locator'),
        backgroundColor: const Color(0xFFE8F5E9),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(
              controller: _searchController,

              decoration: const InputDecoration(
                hintText: 'Search doctor or location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),

              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),

          if (_isBusy) const LinearProgressIndicator(color: Colors.green),

          Expanded(child: _buildDoctorList()),

          _buildAppointmentHistory(),

          const Padding(
            padding: EdgeInsets.all(12),

            child: Text(
              'Demo directory only. Doctor names and '
              'facilities are fictional and are not '
              'verified healthcare providers. '
              'Requests are not confirmed medical '
              'appointments. Use fictional information only.',

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// APPOINTMENT FORM RESULT
// ==========================================

class _AppointmentFormResult {
  final String childName;
  final DateTime appointmentAt;

  const _AppointmentFormResult({
    required this.childName,
    required this.appointmentAt,
  });
}

// ==========================================
// APPOINTMENT FORM DIALOG
// ==========================================

class _AppointmentFormDialog extends StatefulWidget {
  final bool isEditing;
  final String childName;
  final DateTime? existingAppointment;

  const _AppointmentFormDialog({
    required this.isEditing,
    required this.childName,
    required this.existingAppointment,
  });

  @override
  State<_AppointmentFormDialog> createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<_AppointmentFormDialog> {
  late final TextEditingController _childNameController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _childNameController = TextEditingController(text: widget.childName);

    final existing = widget.existingAppointment;

    if (existing != null) {
      _selectedDate = existing;
      _selectedTime = TimeOfDay.fromDateTime(existing);
    }
  }

  @override
  void dispose() {
    _childNameController.dispose();
    super.dispose();
  }

  // SELECT DATE

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final lastDate = today.add(const Duration(days: 365));

    final selected = _selectedDate;

    final initialDate =
        selected != null &&
            !selected.isBefore(today) &&
            !selected.isAfter(lastDate)
        ? selected
        : today;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: lastDate,
    );

    if (date != null && mounted) {
      setState(() {
        _selectedDate = date;
        _errorMessage = null;
      });
    }
  }

  // SELECT TIME

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() {
        _selectedTime = time;
        _errorMessage = null;
      });
    }
  }

  // VALIDATE AND RETURN FORM DATA

  void _submit() {
    final childName = _childNameController.text.trim();

    if (childName.isEmpty ||
        childName.length > 100 ||
        _selectedDate == null ||
        _selectedTime == null) {
      setState(() {
        _errorMessage = 'Please enter valid details for all fields.';
      });

      return;
    }

    final appointmentAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final now = DateTime.now();

    if (!appointmentAt.isAfter(now) ||
        appointmentAt.isAfter(now.add(const Duration(days: 365)))) {
      setState(() {
        _errorMessage = 'Select a future appointment within one year.';
      });

      return;
    }

    Navigator.pop(
      context,
      _AppointmentFormResult(
        childName: childName,
        appointmentAt: appointmentAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEditing ? 'Edit Appointment' : 'Request Appointment',
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: _childNameController,

              decoration: const InputDecoration(
                labelText: 'Child Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            ListTile(
              leading: const Icon(Icons.calendar_month),

              title: Text(
                _selectedDate == null
                    ? 'Select Appointment Date'
                    : '${_selectedDate!.day}/'
                          '${_selectedDate!.month}/'
                          '${_selectedDate!.year}',
              ),

              onTap: _selectDate,
            ),

            ListTile(
              leading: const Icon(Icons.access_time),

              title: Text(
                _selectedTime == null
                    ? 'Select Appointment Time'
                    : _selectedTime!.format(context),
              ),

              onTap: _selectTime,
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),

                child: Text(
                  _errorMessage!,

                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: _submit,

          child: Text(widget.isEditing ? 'Save Changes' : 'Submit Request'),
        ),
      ],
    );
  }
}
