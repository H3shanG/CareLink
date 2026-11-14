import 'package:flutter/material.dart';
import '../data/booking_model.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;
  const BookingDetailsScreen({super.key, required this.booking});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Yes, cancel',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking Confirmed',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      Text('Your caregiver booking has been confirmed.',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _row('Booking ID', b.id),
          const Divider(height: 1),
          _row('Service', b.service),
          const Divider(height: 1),
          _row('Caregiver',
              '${b.caregiver.name}\n★ ${b.caregiver.rating} (${b.caregiver.reviews} reviews)'),
          const Divider(height: 1),
          _row('Date & Time',
              '${formatDate(b.date)}\n${b.startTime.format(context)} – ${b.endTime.format(context)}'),
          const Divider(height: 1),
          _row('Address', b.address),
          const Divider(height: 1),
          _row('Total Price', 'Rs. ${b.total}'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Reschedule'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () => _confirmCancel(context),
                  child: const Text('Cancel Booking'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}