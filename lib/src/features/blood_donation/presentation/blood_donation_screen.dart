import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/donor.dart';
import 'blood_request_screen.dart';
import 'donor_list_screen.dart';

// AppColors eke 'danger' nathi nisa local color eka (red)
const Color _danger = Color(0xFFE53935);

class BloodDonationScreen extends StatefulWidget {
  const BloodDonationScreen({super.key});

  @override
  State<BloodDonationScreen> createState() => _BloodDonationScreenState();
}
      
class _BloodDonationScreenState extends State<BloodDonationScreen> {
  int _tab = 0; // 0 = Find Donors, 1 = Post Request
  String _group = 'A+';
  DonorFilter _filter = const DonorFilter();

  List<Donor> get _donors => sampleDonors.where((d) {
        if (d.bloodGroup != _group) return false;
        if (_filter.onlyAvailable && !d.isAvailable) return false;
        return d.distanceKm <= _filter.maxDistanceKm;
      }).toList()
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

  Future<void> _openFilter() async {
    final result = await showDonorFilterSheet(context, _filter);
    if (result != null) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: const [
            Text('Blood Donation',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 12, color: _danger),
                SizedBox(width: 2),
                Text('Colombo, Sri Lanka',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(child: _tab == 0 ? _buildFindDonors() : const BloodRequestForm()),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    Widget tab(String label, int index) {
      final selected = _tab == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: selected ? Border.all(color: AppColors.primary) : null,
            ),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  )),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(children: [tab('Find Donors', 0), const SizedBox(width: 8), tab('Post Request', 1)]),
    );
  }

  Widget _buildFindDonors() {
    final donors = _donors;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: bloodGroups.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final g = bloodGroups[i];
              final selected = g == _group;
              return ChoiceChip(
                label: Text(g),
                selected: selected,
                showCheckmark: false,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
                onSelected: (_) => setState(() => _group = g),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        _MapPlaceholder(donorCount: donors.length),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('${donors.length} donors found near you',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _openFilter,
              icon: const Icon(Icons.tune, size: 16),
              label: const Text('Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (donors.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('No donors found for this blood group',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          )
        else
          for (final d in donors.take(3))
            DonorCard(
              donor: d,
              onCall: () => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Calling ${d.name}...'))),
            ),
        if (donors.length > 3)
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DonorListScreen(initialBloodGroup: _group)),
            ),
            child: const Text('View all donors'),
          ),
      ],
    );
  }
}



class _MapPlaceholder extends StatelessWidget {
  final int donorCount;
  const _MapPlaceholder({required this.donorCount});

  @override
  Widget build(BuildContext context) {
    const pinPositions = [
      Offset(0.22, 0.25), Offset(0.7, 0.2), Offset(0.15, 0.62), Offset(0.82, 0.68), Offset(0.4, 0.8),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 190,
        child: LayoutBuilder(builder: (context, c) {
          return Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
              for (final p in pinPositions.take(donorCount.clamp(0, pinPositions.length)))
                Positioned(
                  left: p.dx * c.maxWidth - 14,
                  top: p.dy * c.maxHeight - 28,
                  child: const Icon(Icons.location_on, color: _danger, size: 30),
                ),
              Positioned(
                left: c.maxWidth * 0.5 - 9,
                top: c.maxHeight * 0.5 - 9,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8EEF3));
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;
    final thin = Paint()
      ..color = Colors.white70
      ..strokeWidth = 3;
    for (double x = 30; x < size.width; x += 70) {
      canvas.drawLine(Offset(x, 0), Offset(x + 20, size.height), thin);
    }
    for (double y = 20; y < size.height; y += 55) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 15), thin);
    }
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.55), road);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.6, size.height), road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
