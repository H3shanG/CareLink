
import 'package:flutter/material.dart';
import 'pediatrician_appointment_store.dart';
class PediatricianLocatorScreen extends StatefulWidget {
  const PediatricianLocatorScreen({super.key});

  @override
  State<PediatricianLocatorScreen> createState() =>
      _PediatricianLocatorScreenState();
}

class _PediatricianLocatorScreenState
    extends State<PediatricianLocatorScreen> {
  final _searchController = TextEditingController();
final List<Map<String, String>> _appointments =
    PediatricianAppointmentStore.appointments;
  final List<Map<String, String>> _doctors = [
    {
      'name': 'Dr. Nimal Perera ',
      'specialization': 'Pediatrician',
      'location': 'Colombo',
      'hospital': 'Asiri Hospital',
    },
    {
      'name': 'Dr. Saman Silva',
      'specialization': 'Pediatrician',
      'location': 'colombo',
      'hospital': 'Durdans Hospital',
    },
    {
      'name': 'Dr. Amara Fernando',
      'specialization': 'Pediatrician',
      'location': 'colombo',
      'hospital': 'Nawaloka Hospital',
    },
    {
      'name': 'Dr. Kasun Jayasinghe ',
      'specialization': 'Pediatrician',
      'location': 'Kandy',
      'hospital': 'Asiri Hospital',
    },
  ];

  String _searchQuery = '';


void _editAppointment(Map<String, String> appointment) {
  final childNameController = TextEditingController(
    text: appointment['childName'] ?? '',
  );

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final savedDate = appointment['appointmentDate'];
  if (savedDate != null) {
    final parts = savedDate.split('/');
    if (parts.length == 3) {
      selectedDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }
  }

  final savedTime = appointment['appointmentTime'];
  if (savedTime != null) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(savedTime);

    if (match != null) {
      var hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();

      hour = hour % 12 + (period == 'PM' ? 12 : 0);
      selectedTime = TimeOfDay(hour: hour, minute: minute);
    }
  }

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Appointment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: childNameController,
                    decoration: const InputDecoration(
                      labelText: 'Child Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      selectedDate == null
                          ? 'Select Appointment Date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    onTap: () async {
                      final today = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate != null &&
                                !selectedDate!.isBefore(
                                  DateTime(today.year, today.month, today.day),
                                )
                            ? selectedDate!
                            : today,
                        firstDate: DateTime(
                          today.year,
                          today.month,
                          today.day,
                        ),
                        lastDate: today.add(
                          const Duration(days: 365),
                        ),
                      );

                      if (date != null && context.mounted) {
                        setDialogState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      selectedTime == null
                          ? 'Select Appointment Time'
                          : selectedTime!.format(context),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );

                      if (time != null && context.mounted) {
                        setDialogState(() {
                          selectedTime = time;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final childName = childNameController.text.trim();

                  if (childName.isEmpty ||
                      selectedDate == null ||
                      selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please complete all fields.'),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    appointment['childName'] = childName;
                    appointment['appointmentDate'] =
                        '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
                    appointment['appointmentTime'] =
                        selectedTime!.format(context);
                  });

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment updated!'),
                    ),
                  );
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      );
    },
  ).then((_) {
    childNameController.dispose();
  });
}



void _showAppointmentForm(Map<String, String> doctor) {
  final childNameController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Request Appointment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: childNameController,
                    decoration: const InputDecoration(
                      labelText: 'Child Name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      selectedDate == null
                          ? 'Select Appointment Date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365),
                        ),
                      );

                      if (date != null && context.mounted) {
                        setDialogState(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      selectedTime == null
                          ? 'Select Appointment Time'
                          : selectedTime!.format(context),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time != null && context.mounted) {
                        setDialogState(() {
                          selectedTime = time;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () {
                  final childName =
                      childNameController.text.trim();

                  if (childName.isEmpty ||
                      selectedDate == null ||
                      selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please complete all fields.',
                        ),
                      ),
                    );
                    return;
                  }

                  final appointmentDate =
                      '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

                  final appointmentTime =
                      selectedTime!.format(context);

                  setState(() {
                    _appointments.add({
                      'doctor': doctor['name'] ?? '',
                      'childName': childName,
                      'appointmentDate': appointmentDate,
                      'appointmentTime': appointmentTime,
                      'status': 'Pending',
                      'date': DateTime.now()
                          .toString()
                          .substring(0, 16),
                    });
                  });

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Demo appointment request saved!',
                      ),
                    ),
                  );
                },
                child: const Text('Submit Request'),
              ),
            ],
          );
        },
      );
    },
  ).then((_) {
    childNameController.dispose();
  });
}


void _showDoctorDetails(Map<String, String> doctor) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(doctor['name'] ?? 'Doctor Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.medical_services,
              size: 50,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Specialization: ${doctor['specialization']}',
            ),
            const SizedBox(height: 8),
            Text('Hospital: ${doctor['hospital']}'),
            const SizedBox(height: 8),
            Text('Location: ${doctor['location']}'),
            const SizedBox(height: 16),
            const Text(
              'Demo profile only. Provider details '
              'are fictional.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
   
actions: [
  ElevatedButton.icon(
    onPressed: () {
      Navigator.pop(context);
      _showAppointmentForm(doctor);
    },
    icon: const Icon(Icons.calendar_month),
    label: const Text('Request Appointment'),
  ),
  TextButton(
    onPressed: () {
      Navigator.pop(context);
    },
    child: const Text('Close'),
  ),
],

      );
    },
  );
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _doctors.where((doctor) {
      final query = _searchQuery.toLowerCase();

      return doctor['name']!.toLowerCase().contains(query) ||
          doctor['location']!.toLowerCase().contains(query) ||
          doctor['hospital']!.toLowerCase().contains(query);
    }).toList();

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

          Expanded(
            child: filteredDoctors.isEmpty
                ? const Center(
                    child: Text('No pediatricians found.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = filteredDoctors[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () {
                           _showDoctorDetails(doctor);
                          },
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(
                              Icons.medical_services,
                              color: Colors.green,
                            ),
                          ),
                          title: Text(
                            doctor['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(doctor['specialization']!),
                              Text(
                                'Hospital: ${doctor['hospital']}',
                              ),
                              Text(
                                'Location: ${doctor['location']}',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

if (_appointments.isNotEmpty) ...[
  const Padding(
    padding: EdgeInsets.all(12),
    child: Text(
      'Appointment History',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  SizedBox(
    height: 200,
    child: ListView.builder(
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments.reversed.toList()[index];

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


trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(
        Icons.edit,
        color: Colors.blue,
      ),
      tooltip: 'Edit Appointment',
      onPressed: () {
        _editAppointment(appointment);
      },
    ),
    IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      tooltip: 'Delete Appointment',
      onPressed: () {
        setState(() {
          _appointments.remove(appointment);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment deleted!'),
          ),
        );
      },
    ),
  ],
),


            title: Text(appointment['doctor'] ?? ''),
           
subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Child: ${appointment['childName']}',
    ),
    Text(
      'Requested Date: ${appointment['appointmentDate'] ?? 'Not selected'}',
    ),
    Text(
      'Requested Time: ${appointment['appointmentTime'] ?? 'Not selected'}',
    ),
    Text(
      'Status: ${appointment['status']}',
    ),
    Text(
      'Submitted: ${appointment['date']}',
    ),
  ],
),

          ),
        );
      },
    ),
  ),
],

          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Demo directory only. Doctor names and '
              'facilities are fictional and are not '
              'verified healthcare providers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
