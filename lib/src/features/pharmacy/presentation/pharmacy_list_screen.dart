import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/launcher_helper.dart';
import '../../../models/pharmacy.dart';
import 'medicine_search_screen.dart';

const Color _kGreen = Color(0xFF2E9E5B);

/// Medicine & Pharmacy (Member 5): search, filters and nearby pharmacies.
class PharmacyListScreen extends StatefulWidget {
  const PharmacyListScreen({super.key});

  @override
  State<PharmacyListScreen> createState() => _PharmacyListScreenState();
}

class _PharmacyListScreenState extends State<PharmacyListScreen> {
  static const List<String> _filters = ['All', 'Nearby', '24/7', 'Express Delivery'];

  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Pharmacy> get _filtered {
    Iterable<Pharmacy> list = samplePharmacies;
    switch (_filter) {
      case 'Nearby':
        list = list.where((p) => p.distanceKm <= 3);
        break;
      case '24/7':
        list = list.where((p) => p.open24h);
        break;
      case 'Express Delivery':
        list = list.where((p) => p.expressDelivery);
        break;
    }
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(q));
    }
    return list.toList();
  }

  void _openMedicineSearch({String? pharmacyName}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicineSearchScreen(
          initialQuery: pharmacyName == null ? _searchCtrl.text.trim() : '',
          pharmacyName: pharmacyName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pharmacies = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Medicine & Pharmacy',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 13, color: Color(0xFFE53935)),
                const SizedBox(width: 3),
                Text('Colombo, Sri Lanka',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _openMedicineSearch(),
              decoration: InputDecoration(
                hintText: 'Search medicine, pharmacy...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE0E6ED)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = _filters[i] == _filter;
                  return ChoiceChip(
                    label: Text(_filters[i]),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFFEFF3F8),
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    onSelected: (_) => setState(() => _filter = _filters[i]),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nearby Pharmacies',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                TextButton(
                  onPressed: () => setState(() => _filter = 'All'),
                  child: const Text('See All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            if (_searchCtrl.text.trim().isNotEmpty)
              InkWell(
                onTap: () => _openMedicineSearch(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.medication, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search "${_searchCtrl.text.trim()}" in medicines',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: pharmacies.isEmpty
                  ? const Center(child: Text('No pharmacies found'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: pharmacies.length,
                      itemBuilder: (_, i) => _PharmacyCard(
                        pharmacy: pharmacies[i],
                        onOrder: () => _openMedicineSearch(pharmacyName: pharmacies[i].name),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PharmacyCard extends StatelessWidget {
  final Pharmacy pharmacy;
  final VoidCallback onOrder;

  const _PharmacyCard({required this.pharmacy, required this.onOrder});

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFFE8F5EE),
      child: const Icon(Icons.local_pharmacy, color: _kGreen, size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = pharmacy.isOpen ? _kGreen : const Color(0xFFE53935);
    final path = pharmacy.imagePath;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF3)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: path == null
                ? _placeholder()
                : Image.asset(
                    path,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pharmacy.name,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text('${pharmacy.distanceKm} km  •  ',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(pharmacy.statusText,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFB300)),
                    const SizedBox(width: 3),
                    Text('${pharmacy.rating} (${pharmacy.reviews})',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: pharmacy.isOpen ? onOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Order', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => callNumber(context, pharmacy.phone),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Call',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
