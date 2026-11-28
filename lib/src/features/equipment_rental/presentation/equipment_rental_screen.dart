import 'package:flutter/material.dart';

import '../data/equipment_rental_repository.dart';

class EquipmentRentalScreen extends StatelessWidget {
  const EquipmentRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Equipment Rental'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Available Medical Equipment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildEquipmentCard(
            context,
            icon: Icons.accessible,
            name: 'Wheelchair',
            description: 'Comfortable wheelchair for daily mobility.',
            price: 'Rs. 1,000 / day',
          ),

          _buildEquipmentCard(
            context,
            icon: Icons.airline_seat_flat,
            name: 'Hospital Bed',
            description: 'Adjustable bed for home patient care.',
            price: 'Rs. 2,500 / day',
          ),

          _buildEquipmentCard(
            context,
            icon: Icons.monitor_heart,
            name: 'Oxygen Concentrator',
            description: 'Equipment to support oxygen therapy.',
            price: 'Rs. 3,000 / day',
          ),

          _buildEquipmentCard(
            context,
            icon: Icons.health_and_safety,
            name: 'Blood Pressure Monitor',
            description: 'Monitor blood pressure at home.',
            price: 'Rs. 500 / day',
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String description,
    required String price,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 10),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openRentSheet(context, name, price),
                child: const Text('Rent Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRentSheet(BuildContext context, String name, String price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RentSheet(equipment: name, price: price),
    );
  }
}

class _RentSheet extends StatefulWidget {
  final String equipment;
  final String price;
  const _RentSheet({required this.equipment, required this.price});

  @override
  State<_RentSheet> createState() => _RentSheetState();
}

class _RentSheetState extends State<_RentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _repo = EquipmentRentalRepository();
  int _duration = 1;
  bool _submitting = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await _repo
          .createRental(
            equipment: widget.equipment,
            price: widget.price,
            duration: _duration,
            address: _addressCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Equipment rental failed: $e');
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not send the request. Please try again.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text('${widget.equipment} rental request sent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rent ${widget.equipment}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(widget.price,
                  style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Duration (days)'),
                  const Spacer(),
                  IconButton(
                    onPressed:
                        _duration > 1 ? () => setState(() => _duration--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_duration',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(
                    onPressed:
                        _duration < 30 ? () => setState(() => _duration++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Delivery address',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter delivery address'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter phone number'
                    : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}