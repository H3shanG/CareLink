import 'package:cloud_firestore/cloud_firestore.dart';

import 'caregiver_model.dart';

class CaregiverRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('caregivers');

  // Firestore එකේ caregivers ඔක්කොම කියවන්න (වෙනස් වුණොත් ඉබේම update වෙනවා)
  Stream<List<Caregiver>> watchCaregivers() {
    return _col.snapshots().map(
          (snap) => snap.docs
              .map((doc) => Caregiver.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Dummy data Firestore එකට එක පාරක් upload කරන්න. Data කලින්ම තියෙනවා නම් මුකුත් කරන්නේ නෑ.
  Future<void> seedIfEmpty() async {
    final existing = await _col.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final c in dummyCaregivers) {
      batch.set(_col.doc(), c.toMap());
    }
    await batch.commit();
  }
}