import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/firestore_service.dart';

class AnonymousReportScreen extends StatefulWidget {
  final Position userPosition;

  const AnonymousReportScreen({
    super.key,
    required this.userPosition,
  });

  @override
  State<AnonymousReportScreen> createState() => _AnonymousReportScreenState();
}

class _AnonymousReportScreenState extends State<AnonymousReportScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  
  bool _lightsOn = true;
  bool _halloweenDecorations = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _streetNumberController.dispose();
    _streetNameController.dispose();
    super.dispose();
  }

  String _buildFullAddress() {
    final number = _streetNumberController.text.trim();
    final street = _streetNameController.text.trim();
    
    if (number.isEmpty || street.isEmpty) return '';
    
    return '$number $street';
  }

  String _getStreetViewUrl() {
    final address = _buildFullAddress();
    if (address.isEmpty) {
      // Show user's current location
      return _locationService.getStreetViewUrl(
        widget.userPosition.latitude,
        widget.userPosition.longitude,
        'YOUR_API_KEY',
      );
    }
    
    // Use address-based Street View
    return 'https://maps.googleapis.com/maps/api/streetview?size=600x400&location=${Uri.encodeComponent(address)}&key=YOUR_API_KEY';
  }

  Future<void> _submitReport() async {
    final address = _buildFullAddress();
    
    if (address.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both street number and street name';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    try {
      // For now, use approximate location (user's position)
      // In production, you'd geocode the address to get exact coordinates
      await firestoreService.reportHouseAnonymously(
        address: address,
        latitude: widget.userPosition.latitude,
        longitude: widget.userPosition.longitude,
        isParticipating: true,
        lightsOn: _lightsOn,
        halloweenDecorations: _halloweenDecorations,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎃 House reported! Thank you!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit report: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a House'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Report a House',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the address of a house giving out candy. Use the Street View to confirm you have the right house.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Street View Image
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 250,
                    color: Colors.grey.shade300,
                    child: Image.network(
                      _getStreetViewUrl(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.streetview, size: 64, color: Colors.grey.shade600),
                              const SizedBox(height: 8),
                              Text(
                                'Street View Preview',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Enter address to see house',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Address Input
            Text(
              'House Address',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _streetNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Number',
                      hintText: '123',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _streetNameController,
                    decoration: const InputDecoration(
                      labelText: 'Street Name',
                      hintText: 'Main Street',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            
            if (_buildFullAddress().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Full address: ${_buildFullAddress()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: 32),

            // House Details
            Text(
              'House Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('Lights are on'),
                      ],
                    ),
                    subtitle: const Text('House has lights on'),
                    value: _lightsOn,
                    onChanged: (value) {
                      setState(() {
                        _lightsOn = value;
                      });
                    },
                    activeColor: Colors.amber,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Row(
                      children: [
                        Icon(Icons.celebration, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Halloween decorations'),
                      ],
                    ),
                    subtitle: const Text('House has Halloween decorations'),
                    value: _halloweenDecorations,
                    onChanged: (value) {
                      setState(() {
                        _halloweenDecorations = value;
                      });
                    },
                    activeColor: Colors.orange,
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitReport,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSubmitting ? 'Submitting...' : 'Report House'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
