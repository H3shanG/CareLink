import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../data/blood_request_repository.dart';
import '../models/blood_request.dart';
import '../models/donor.dart';

const Color _danger = Color(0xFFE53935);

class BloodRequestScreen extends StatelessWidget {
  const BloodRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Post Blood Request',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: BloodRequestForm(onSubmitted: (_) => Navigator.pop(context)),
    );
  }
}

class BloodRequestForm extends StatefulWidget {
  final void Function(BloodRequest request)? onSubmitted;
  const BloodRequestForm({super.key, this.onSubmitted});

  @override
  State<BloodRequestForm> createState() => _BloodRequestFormState();
}

class _BloodRequestFormState extends State<BloodRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _patientCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _repo = BloodRequestRepository();
  bool _submitting = false;

  String _bloodGroup = 'A+';
  int _units = 1;
  Urgency _urgency = Urgency.normal;
  DateTime? _neededBy;

  @override
  void dispose() {
    _patientCtrl.dispose();
    _hospitalCtrl.dispose();
    _contactCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _neededBy ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _neededBy = picked);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_neededBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the date needed')),
      );
      return;
    }

    final request = BloodRequest(
      patientName: _patientCtrl.text.trim(),
      bloodGroup: _bloodGroup,
      units: _units,
      hospital: _hospitalCtrl.text.trim(),
      urgency: _urgency,
      neededBy: _neededBy!,
      contactNumber: _contactCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    setState(() => _submitting = true);
    try {
      // Saves the request to Firestore (collection: blood_requests)
      await _repo.createRequest(request).timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Blood request failed: $e');
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not post the request. Please try again.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Blood request posted successfully')),
    );

    // Clear the form
    _formKey.currentState?.reset();
    _patientCtrl.clear();
    _hospitalCtrl.clear();
    _contactCtrl.clear();
    _noteCtrl.clear();
    setState(() {
      _submitting = false;
      _units = 1;
      _urgency = Urgency.normal;
      _neededBy = null;
    });

    widget.onSubmitted?.call(request);
  }

  InputDecoration _decoration(String label, {IconData? icon}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _patientCtrl,
            decoration: _decoration('Patient name', icon: Icons.person_outline),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter patient name' : null,
          ),

          _label('Blood group'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in bloodGroups)
                ChoiceChip(
                  label: Text(g),
                  selected: _bloodGroup == g,
                  showCheckmark: false,
                  selectedColor: _danger,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                  labelStyle: TextStyle(
                    color: _bloodGroup == g
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _bloodGroup = g),
                ),
            ],
          ),

          _label('Quantity (units)'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _units > 1 ? () => setState(() => _units--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_units unit${_units > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _units < 10
                      ? () => setState(() => _units++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),

          _label('Urgency'),
          Wrap(
            spacing: 8,
            children: [
              for (final u in Urgency.values)
                ChoiceChip(
                  label: Text(u.label),
                  selected: _urgency == u,
                  showCheckmark: false,
                  selectedColor: _danger,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                  labelStyle: TextStyle(
                    color: _urgency == u ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _urgency = u),
                ),
            ],
          ),

          _label('Needed by'),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: _decoration('Date', icon: Icons.calendar_today),
              child: Text(
                _neededBy == null
                    ? 'Select date'
                    : '${_neededBy!.year}-'
                          '${_neededBy!.month.toString().padLeft(2, '0')}-'
                          '${_neededBy!.day.toString().padLeft(2, '0')}',
              ),
            ),
          ),

          const SizedBox(height: 16),
          TextFormField(
            controller: _hospitalCtrl,
            decoration: _decoration(
              'Hospital',
              icon: Icons.local_hospital_outlined,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter hospital' : null,
          ),

          const SizedBox(height: 16),
          TextFormField(
            controller: _contactCtrl,
            keyboardType: TextInputType.phone,
            decoration: _decoration(
              'Contact number',
              icon: Icons.phone_outlined,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter contact number' : null,
          ),

          const SizedBox(height: 16),
          TextFormField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: _decoration('Note (optional)', icon: Icons.notes),
          ),

          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Post Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
