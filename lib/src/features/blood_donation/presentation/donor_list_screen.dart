import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../data/donor_location.dart';
import '../data/donor_repository.dart';
import '../models/donor.dart';

const Color _danger = Color(0xFFE53935);

// Opens the phone dialer with the donor's number
Future<void> callDonor(BuildContext context, Donor donor) async {
  var opened = false;
  try {
    opened = await launchUrl(Uri(scheme: 'tel', path: donor.phone));
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the phone app')),
    );
  }
}

class DonorFilter {
  final double maxDistanceKm;
  final bool onlyAvailable;
  const DonorFilter({this.maxDistanceKm = 15, this.onlyAvailable = false});
}

Future<DonorFilter?> showDonorFilterSheet(
    BuildContext context, DonorFilter current) {
  return showModalBottomSheet<DonorFilter>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FilterSheet(initial: current),
  );
}

class _FilterSheet extends StatefulWidget {
  final DonorFilter initial;
  const _FilterSheet({required this.initial});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _distance = widget.initial.maxDistanceKm;
  late bool _onlyAvailable = widget.initial.onlyAvailable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter Donors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Maximum distance: ${_distance.round()} km',
              style: const TextStyle(fontSize: 14)),
          Slider(
            value: _distance,
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _distance = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Available donors only'),
            value: _onlyAvailable,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _onlyAvailable = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, const DonorFilter()),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    DonorFilter(
                        maxDistanceKm: _distance, onlyAvailable: _onlyAvailable),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable donor card

class DonorCard extends StatelessWidget {
  final Donor donor;
  final VoidCallback? onCall;
  const DonorCard({super.key, required this.donor, this.onCall});

  @override
  Widget build(BuildContext context) {
    final available = donor.isAvailable;
    final km = donor.distanceKm;
    final distanceText = km != null
        ? '$km km away'
        : (donor.area.isNotEmpty ? donor.area : 'Distance unavailable');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            backgroundImage:
                donor.photoAsset != null ? AssetImage(donor.photoAsset!) : null,
            child: donor.photoAsset == null
                ? Text(
                    donor.name.isNotEmpty ? donor.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(donor.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(donor.bloodGroup,
                          style: const TextStyle(
                              color: _danger,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (donor.rating > 0) ...[
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(' ${donor.rating}',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(distanceText,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (available ? AppColors.success : AppColors.textSecondary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  available ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        available ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: available ? onCall : null,
                child: Icon(Icons.call,
                    size: 20,
                    color: available ? AppColors.primary : AppColors.border),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Full donor list screen

class DonorListScreen extends StatefulWidget {
  final String? initialBloodGroup;
  const DonorListScreen({super.key, this.initialBloodGroup});

  @override
  State<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  final _donorRepo = DonorRepository();
  late final Stream<List<Donor>> _donorStream = _donorRepo.watchDonors();

  late String? _group = widget.initialBloodGroup;
  DonorFilter _filter = const DonorFilter();
  String _query = '';
  Position? _position;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    final pos = await DonorLocation.currentPosition();
    if (!mounted) return;
    setState(() => _position = pos);
  }

  List<Donor> _applyFilters(List<Donor> all) {
    final list = DonorLocation.withDistance(all, _position).where((d) {
      if (_group != null && d.bloodGroup != _group) return false;
      if (_filter.onlyAvailable && !d.isAvailable) return false;
      final km = d.distanceKm;
      if (km != null && km > _filter.maxDistanceKm) return false;
      if (_query.isNotEmpty &&
          !d.name.toLowerCase().contains(_query.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    list.sort((a, b) => (a.distanceKm ?? double.infinity)
        .compareTo(b.distanceKm ?? double.infinity));
    return list;
  }

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
        title: const Text('Donor List',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search donors by name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('All', _group == null, () => setState(() => _group = null)),
                for (final g in bloodGroups)
                  _chip(g, _group == g, () => setState(() => _group = g)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Donor>>(
              stream: _donorStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load donors',
                        style: TextStyle(color: AppColors.textSecondary)),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = _applyFilters(snapshot.data!);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
                      child: Row(
                        children: [
                          Text('${results.length} donors found',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _openFilter,
                            icon: const Icon(Icons.tune, size: 16),
                            label: const Text('Filter'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: results.isEmpty
                          ? const Center(
                              child: Text('No donors match your filters',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: results.length,
                              itemBuilder: (_, i) => DonorCard(
                                donor: results[i],
                                onCall: () => callDonor(context, results[i]),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontSize: 13),
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        showCheckmark: false,
      ),
    );
  }
}