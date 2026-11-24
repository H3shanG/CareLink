import 'package:flutter/material.dart';
import '../data/booking_model.dart';
import '../data/booking_repository.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;
  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final BookingRepository _repo = BookingRepository();

  late String _status = widget.booking.status;
  bool _isCancelling = false;

  bool get _isCancelled => _status == 'cancelled';

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

  Future<void> _cancelBooking() async {
    setState(() => _isCancelling = true);

    try {
      if (widget.booking.docId.isEmpty) {
        throw Exception('Missing booking document id');
      }

      await _repo.cancelBooking(widget.booking.docId);

      if (!mounted) return;

      setState(() => _status = 'cancelled');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled')),
      );
    } catch (e) {
      // Print the real error so it shows up in the terminal.
      debugPrint('Cancel failed: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not cancel the booking. Please try again'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  void _confirmCancel() {
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
              _cancelBooking();
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
    final b = widget.booking;
    final bannerColor = _isCancelled ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isCancelled ? Colors.red.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: bannerColor,
                  child: Icon(
                    _isCancelled ? Icons.close : Icons.check,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCancelled
                            ? 'Booking Cancelled'
                            : 'Booking Confirmed',
                        style: TextStyle(
                          color: bannerColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isCancelled
                            ? 'This booking has been cancelled.'
                            : 'Your caregiver booking has been confirmed.',
                        style: const TextStyle(fontSize: 12),
                      ),
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
                  onPressed:
                      (_isCancelled || _isCancelling) ? null : _confirmCancel,
                  child: _isCancelling
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isCancelled ? 'Cancelled' : 'Cancel Booking'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}