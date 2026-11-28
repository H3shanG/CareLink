import '../../../models/pharmacy.dart';

class MedicineOrder {
  final String id;
  final String medicine;
  final String pharmacy;
  final int quantity;
  final int total; // Rs.
  final String address;
  final String phone;
  final DateTime placedAt;
  String status;

  MedicineOrder({
    required this.id,
    required this.medicine,
    required this.pharmacy,
    required this.quantity,
    required this.total,
    required this.address,
    required this.phone,
    required this.placedAt,
    this.status = 'Placed',
  });
}

/// In-memory store (same pattern as the other request stores in the project).
/// TODO: replace with Firestore writes when the backend collections are ready.
class MedicineOrderStore {
  static final List<MedicineOrder> orders = [];

  static MedicineOrder place({
    required Medicine medicine,
    required int quantity,
    required String address,
    required String phone,
  }) {
    final order = MedicineOrder(
      id: 'ORD-${1000 + orders.length + 1}',
      medicine: medicine.name,
      pharmacy: medicine.pharmacy,
      quantity: quantity,
      total: medicine.price * quantity,
      address: address,
      phone: phone,
      placedAt: DateTime.now(),
    );
    orders.insert(0, order);
    return order;
  }
}
