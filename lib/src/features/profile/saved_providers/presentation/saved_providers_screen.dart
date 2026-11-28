import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../caregiver/data/caregiver_model.dart';

class SavedProvidersScreen extends StatelessWidget {
  const SavedProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Providers'), centerTitle: true),
      body: user == null
          ? const Center(child: Text('Please log in to view saved providers.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('saved_providers')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load saved providers.'),
                  );
                }

                final savedDocs = snapshot.data?.docs ?? [];

                if (savedDocs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No saved providers yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Save your favourite caregivers to see them here.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedDocs.length,
                  itemBuilder: (context, index) {
                    final savedData = savedDocs[index].data();
                    final caregiverId =
                        savedData['caregiverId']?.toString() ?? '';

                    return FutureBuilder<
                      DocumentSnapshot<Map<String, dynamic>>
                    >(
                      future: FirebaseFirestore.instance
                          .collection('caregivers')
                          .doc(caregiverId)
                          .get(),
                      builder: (context, caregiverSnapshot) {
                        if (caregiverSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Card(
                            child: ListTile(
                              leading: CircularProgressIndicator(),
                              title: Text('Loading provider...'),
                            ),
                          );
                        }

                        if (!caregiverSnapshot.hasData ||
                            !caregiverSnapshot.data!.exists) {
                          return const SizedBox.shrink();
                        }

                        final caregiver = Caregiver.fromMap(
                          caregiverSnapshot.data!.id,
                          caregiverSnapshot.data!.data()!,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              caregiver.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${caregiver.role}\n'
                              'Rating: ${caregiver.rating}  •  '
                              'Rs. ${caregiver.pricePerHour}/hour',
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              tooltip: 'Remove from saved providers',
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('saved_providers')
                                    .doc(savedDocs[index].id)
                                    .delete();

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Provider removed from saved list.',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
