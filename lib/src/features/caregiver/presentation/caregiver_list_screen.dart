import 'package:flutter/material.dart';
import '../data/caregiver_model.dart';
import 'caregiver_profile_screen.dart';

class CaregiverListScreen extends StatefulWidget {
  const CaregiverListScreen({super.key});

  @override
  State<CaregiverListScreen> createState() => _CaregiverListScreenState();
}

class _CaregiverListScreenState extends State<CaregiverListScreen> {
  final List<String> _filters = ['All', 'Nurse', 'Home Care', 'Elder Care'];
  String _selected = 'All';
  String _query = '';

  List<Caregiver> get _results {
    return dummyCaregivers.where((c) {
      final matchSearch = c.name.toLowerCase().contains(_query.toLowerCase());
      final matchFilter = _selected == 'All' ||
          c.role.contains(_selected) ||
          c.tags.contains(_selected);
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver / Nurse Booking'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16),
                SizedBox(width: 4),
                Text('Colombo, Sri Lanka'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search caregivers, nurses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text(_filters[i]),
                selected: _selected == _filters[i],
                onSelected: (_) => setState(() => _selected = _filters[i]),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No caregivers found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (_, i) => _CaregiverCard(caregiver: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CaregiverCard extends StatelessWidget {
  final Caregiver caregiver;
  const _CaregiverCard({required this.caregiver});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CaregiverProfileScreen(caregiver: caregiver),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.person, color: scheme.primary, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caregiver.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(caregiver.role,
                            style: const TextStyle(color: Colors.grey)),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.amber),
                            Text(
                                ' ${caregiver.rating} (${caregiver.reviews} reviews)'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Icon(Icons.favorite_border, color: Colors.red),
                      Text(caregiver.distance,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: caregiver.tags
                    .map((t) => Chip(
                          label: Text(t, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}