import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/house.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isParticipating = true;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveHouse() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    final house = House(
      id: '',
      address: _addressController.text.trim(),
      latitude: 0.0, // TODO: Get from geocoding
      longitude: 0.0, // TODO: Get from geocoding
      isParticipating: _isParticipating,
      ownerId: authService.currentUser!.uid,
      lastUpdated: DateTime.now(),
      notes: _notesController.text.trim(),
    );

    try {
      await firestoreService.saveHouse(house);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('House saved successfully!')),
        );
        _addressController.clear();
        _notesController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Houses'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Participating in Halloween'),
                    value: _isParticipating,
                    onChanged: (value) {
                      setState(() {
                        _isParticipating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveHouse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Add House'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<House>>(
              stream: firestoreService.getUserHouses(authService.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final houses = snapshot.data ?? [];

                if (houses.isEmpty) {
                  return const Center(
                    child: Text('No houses added yet'),
                  );
                }

                return ListView.builder(
                  itemCount: houses.length,
                  itemBuilder: (context, index) {
                    final house = houses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          house.isParticipating
                              ? Icons.home
                              : Icons.home_outlined,
                          color: house.isParticipating
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        title: Text(house.address),
                        subtitle: house.notes != null
                            ? Text(house.notes!)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: house.isParticipating,
                              onChanged: (value) {
                                firestoreService.updateParticipationStatus(
                                    house.id, value);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                firestoreService.deleteHouse(house.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
