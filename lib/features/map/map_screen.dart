import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../models/house.dart';
import 'anonymous_report_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  Position? _userPosition;
  bool _isLoadingLocation = false;
  String? _locationError;
  bool _isRetrying = false;
  int _retryCountdown = 0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    final position = await _locationService.getCurrentPosition();
    
    if (position == null) {
      setState(() {
        _userPosition = null;
        _isLoadingLocation = false;
        _locationError = 'Unable to get your location. Please check permissions and try again.';
      });
      return;
    }
    
    setState(() {
      _userPosition = position;
      _isLoadingLocation = false;
      _locationError = null;
    });
  }

  Future<void> _retryLocation() async {
    setState(() {
      _isRetrying = true;
      _retryCountdown = 10;
      _locationError = null;
    });

    // Countdown from 10 to 0
    for (int i = 10; i > 0; i--) {
      if (!mounted || !_isRetrying) break;
      
      setState(() {
        _retryCountdown = i;
      });
      
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted || !_isRetrying) return;

    setState(() {
      _retryCountdown = 0;
      _isRetrying = false;
    });

    // Now attempt to get location
    await _getUserLocation();
  }

  void _cancelRetry() {
    setState(() {
      _isRetrying = false;
      _retryCountdown = 0;
    });
  }

  void _openAnonymousReport() {
    if (_locationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fix location error first'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _retryLocation,
          ),
        ),
      );
      return;
    }

    if (_userPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Getting your location...'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnonymousReportScreen(
          userPosition: _userPosition!,
        ),
      ),
    );
  }

  bool _hasHousesInWalkingDistance(List<House> houses) {
    if (_userPosition == null) return false;

    return houses.any((house) => _locationService.isWithinWalkingDistance(
          _userPosition!.latitude,
          _userPosition!.longitude,
          house.latitude,
          house.longitude,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TreatTracker - Halloween Map'),
        backgroundColor: Colors.orange,
        actions: [
          if (_userPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _getUserLocation,
              tooltip: 'Refresh location',
            ),
        ],
      ),
      body: StreamBuilder<List<House>>(
        stream: firestoreService.getParticipatingHouses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allHouses = snapshot.data ?? [];
          final hasNearbyHouses = _hasHousesInWalkingDistance(allHouses);

          return Column(
            children: [
              // Location error banner with retry
              if (_locationError != null && !_isRetrying)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.shade100,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_off, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationError!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _retryLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Retry countdown banner
              if (_isRetrying)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade100,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Localising...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Retrying in $_retryCountdown seconds',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _cancelRetry,
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              
              // Location status banner
              if (_isLoadingLocation && !_isRetrying)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blue.shade100,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Getting your location...'),
                    ],
                  ),
                )
              else if (_userPosition != null && !hasNearbyHouses)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange.shade100,
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No houses in your walking area yet!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Help build the community map by reporting houses around you.',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _openAnonymousReport,
                        icon: const Icon(Icons.add_location),
                        label: const Text('Report Nearby Houses'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

              // Map placeholder
              Expanded(
                child: allHouses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.house_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No participating houses yet',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            if (_userPosition != null)
                              ElevatedButton.icon(
                                onPressed: _openAnonymousReport,
                                icon: const Icon(Icons.add),
                                label: const Text('Be the first to report!'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // TODO: Replace with actual Google Maps widget
                          Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: Stack(
                              children: [
                                const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.map,
                                          size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        'Interactive map coming soon',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_userPosition != null)
                                  Positioned(
                                    bottom: 16,
                                    right: 16,
                                    child: FloatingActionButton.small(
                                      onPressed: _openAnonymousReport,
                                      backgroundColor: Colors.orange,
                                      child: const Icon(Icons.add_location),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // House list
                          Expanded(
                            child: ListView.builder(
                              itemCount: allHouses.length,
                              itemBuilder: (context, index) {
                                final house = allHouses[index];
                                final isNearby = _userPosition != null &&
                                    _locationService.isWithinWalkingDistance(
                                      _userPosition!.latitude,
                                      _userPosition!.longitude,
                                      house.latitude,
                                      house.longitude,
                                    );

                                // Determine trust level color
                                Color cardColor;
                                Color iconColor;
                                String trustLabel;
                                
                                if (house.isAnonymousReport) {
                                  if (house.reportCount >= 5) {
                                    cardColor = Colors.green.shade50;
                                    iconColor = Colors.green;
                                    trustLabel = 'High confidence';
                                  } else if (house.reportCount >= 3) {
                                    cardColor = Colors.lightGreen.shade50;
                                    iconColor = Colors.lightGreen.shade700;
                                    trustLabel = 'Medium confidence';
                                  } else {
                                    cardColor = Colors.yellow.shade50;
                                    iconColor = Colors.orange.shade700;
                                    trustLabel = 'Low confidence';
                                  }
                                } else {
                                  // Owner verified
                                  cardColor = Colors.green.shade100;
                                  iconColor = Colors.green.shade800;
                                  trustLabel = 'Owner verified';
                                }

                                if (isNearby) {
                                  cardColor = Colors.orange.shade100;
                                }

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  color: cardColor,
                                  child: ListTile(
                                    leading: Icon(
                                      house.isAnonymousReport 
                                          ? Icons.groups 
                                          : Icons.verified_user,
                                      color: iconColor,
                                      size: 32,
                                    ),
                                    title: Text(house.address),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (house.lightsOn)
                                              const Padding(
                                                padding: EdgeInsets.only(right: 8),
                                                child: Icon(Icons.lightbulb, 
                                                    size: 16, color: Colors.amber),
                                              ),
                                            if (house.halloweenDecorations)
                                              const Padding(
                                                padding: EdgeInsets.only(right: 8),
                                                child: Icon(Icons.celebration, 
                                                    size: 16, color: Colors.orange),
                                              ),
                                            Text(trustLabel,
                                                style: const TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                        if (house.notes != null)
                                          Text(house.notes!),
                                        if (house.isAnonymousReport)
                                          Text(
                                            '${house.reportCount} report${house.reportCount > 1 ? 's' : ''}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isNearby)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Nearby',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.celebration,
                                            color: Colors.orange),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _userPosition != null
          ? FloatingActionButton.extended(
              onPressed: _openAnonymousReport,
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Report Houses'),
            )
          : null,
    );
  }
}
