import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/services/auth_service.dart';
import '../data/donor_location.dart';
import '../data/donor_repository.dart';
import '../models/donor.dart';

Future<void> showBecomeDonorSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _BecomeDonorSheet(),
  );
}

class _BecomeDonorSheet extends StatefulWidget {
  const _BecomeDonorSheet();

  @override
  State<_BecomeDonorSheet> createState() => _BecomeDonorSheetState();
}

class _BecomeDonorSheetState extends State<_BecomeDonorSheet> {
  final _repo = DonorRepository();
  final _phoneCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();

  String? _group;
  bool _available = true;
  bool _shareLocation = true;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  // Pre-fills the form from an existing donor profile or the user's profile
  Future<void> _load() async {
    try {
      final existing = await _repo.getMyDonorProfile();
      if (existing != null) {
        _group = existing.bloodGroup;
        _phoneCtrl.text = existing.phone;
        _areaCtrl.text = existing.area;
        _available = existing.isAvailable;
        _shareLocation = existing.latitude != null;
      } else {
        final profile = await AuthService().getUserProfile();
        _phoneCtrl.text = (profile?['phone'] as String?) ?? '';
      }
    } catch (_) {
      // The form still works with empty fields
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final phone = _phoneCtrl.text.trim();
    if (_group == null) {
      setState(() => _error = 'Please choose your blood group');
      return;
    }
    if (phone.replaceAll(RegExp(r'\D'), '').length < 9) {
      setState(() => _error = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final profile = await AuthService().getUserProfile();
      final name = ((profile?['name'] as String?) ?? '').trim();

      double? lat;
      double? lng;
      if (_shareLocation) {
        final pos = await DonorLocation.currentPosition();
        lat = pos?.latitude;
        lng = pos?.longitude;
      }

      await _repo.saveMyDonorProfile(
        name: name.isEmpty ? 'Donor' : name,
        bloodGroup: _group!,
        phone: phone,
        area: _areaCtrl.text.trim(),
        isAvailable: _available,
        latitude: lat,
        longitude: lng,
      );

      if (!mounted) return;
      final locationMissing = _shareLocation && lat == null;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locationMissing
                ? 'Saved. Location was not available, so your distance will not be shown.'
                : 'You are registered as a donor',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
      child: _loading
          ? const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Become a donor',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                    'Your name, blood group and phone number will be visible to signed-in users who are looking for donors.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Blood group',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final g in bloodGroups)
                        ChoiceChip(
                          label: Text(g),
                          selected: _group == g,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.border),
                          labelStyle: TextStyle(
                            color: _group == g
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          onSelected: (_) => setState(() => _group = g),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _areaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Area (optional, e.g. Colombo 03)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('I am available to donate'),
                    value: _available,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _available = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Share my location'),
                    subtitle: const Text(
                      'Lets people see how far away you are',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _shareLocation,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _shareLocation = v),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 4),
                    Text(_error!,
                        style: const TextStyle(color: Color(0xFFE53935))),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}