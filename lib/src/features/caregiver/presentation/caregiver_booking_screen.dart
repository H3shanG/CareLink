import 'package:flutter/material.dart';

import '../data/caregiver_model.dart';
import '../../booking/data/booking_model.dart';
import '../../booking/presentation/booking_details_screen.dart';
import '../../booking/data/booking_repository.dart';

class CaregiverBookingScreen extends StatefulWidget {
  final Caregiver caregiver;
  const CaregiverBookingScreen({super.key, required this.caregiver});

  @override
  State<CaregiverBookingScreen> createState() => _CaregiverBookingScreenState();
}

class _CaregiverBookingScreenState extends State<CaregiverBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  final List<String> _services = [
    'Home Care Nurse',
    'Elder Care',
    'Patient Care',
    'Post-surgery Care',
  ];
  String _service = 'Home Care Nurse';
  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;

  final BookingRepository _bookingRepo = BookingRepository();
  bool _isSaving = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  double get _hours {
    if (_start == null || _end == null) return 0;
    final diff =
        (_end!.hour * 60 + _end!.minute) - (_start!.hour * 60 + _start!.minute);
    return diff > 0 ? diff / 60 : 0;
  }

  int get _total => (_hours * widget.caregiver.pricePerHour).round();

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (!mounted) return;
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime(bool isStart) async {
    final t = await showTimePicker(
      context: context,
      initialTime: isStart
          ? const TimeOfDay(hour: 10, minute: 0)
          : const TimeOfDay(hour: 16, minute: 0),
    );
    if (!mounted) return;
    if (t != null) {
      setState(() {
        if (isStart) {
          _start = t;
        } else {
          _end = t;
        }
      });
    }
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _start == null || _end == null) {
      _showMessage('Please select date, start time and end time');
      return;
    }
    if (_hours <= 0) {
      _showMessage('End time must be after start time');
      return;
    }

    final booking = Booking(
      id: makeBookingId(_date!),
      caregiver: widget.caregiver,
      service: _service,
      date: _date!,
      startTime: _start!,
      endTime: _end!,
      address: _addressController.text.trim(),
      total: _total,
    );

    setState(() => _isSaving = true);

    try {
      final docId = await _bookingRepo.createBooking(booking);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BookingDetailsScreen(booking: booking.copyWith(docId: docId)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not save your booking. Please try again');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.caregiver;
    return Scaffold(
      appBar: AppBar(title: const Text('Book Caregiver'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '${c.name} • ${c.role}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _service,
              decoration: const InputDecoration(
                labelText: 'Service',
                border: OutlineInputBorder(),
              ),
              items: _services
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _service = v!),
            ),
            const SizedBox(height: 12),
            _PickerTile(
              icon: Icons.calendar_today,
              label: 'Date',
              value: _date == null ? 'Select date' : formatDate(_date!),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PickerTile(
                    icon: Icons.access_time,
                    label: 'Start',
                    value: _start == null ? 'Select' : _start!.format(context),
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerTile(
                    icon: Icons.access_time_filled,
                    label: 'End',
                    value: _end == null ? 'Select' : _end!.format(context),
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: '123, Galle Road, Colombo 03',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter your address'
                  : null,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_hours.toStringAsFixed(1)} hrs × Rs. ${c.pricePerHour}',
                  ),
                  Text(
                    'Rs. $_total',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _confirm,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm Booking'),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        child: Text(value),
      ),
    );
  }
}
