import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;

class LocationService {
  // Average walking speed in km/h
  static const double walkingSpeed = 5.0;
  
  // Calculate radius for 1 hour of walking (in meters)
  static double get oneHourWalkingRadius => (walkingSpeed * 1000);

  /// Check if location services are enabled and permissions are granted
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current device position
  /// Returns null if location cannot be obtained
  /// Prints detailed error messages for debugging
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled. Please enable location services.');
        return null;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      print('Current location permission: $permission');
      
      if (permission == LocationPermission.denied) {
        print('Requesting location permission...');
        permission = await Geolocator.requestPermission();
        print('Permission after request: $permission');
        
        if (permission == LocationPermission.denied) {
          print('Location permission denied by user');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission permanently denied. User must enable in settings.');
        return null;
      }

      print('Attempting to get current position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Location request timed out after 30 seconds');
          throw Exception('Location request timed out');
        },
      );
      
      print('Successfully obtained position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('Error getting current position: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Check if a point is within walking distance (1 hour)
  bool isWithinWalkingDistance(
    double userLat,
    double userLon,
    double houseLat,
    double houseLon,
  ) {
    final distance = calculateDistance(userLat, userLon, houseLat, houseLon);
    return distance <= oneHourWalkingRadius;
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      return formatAddress(place);
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  /// Get coordinates from address (geocoding)
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;
      return locations.first;
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }

  /// Format a Placemark into a readable address
  String formatAddress(Placemark place) {
    List<String> parts = [];

    if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
      parts.add(place.subThoroughfare!);
    }

    if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
      parts.add(place.thoroughfare!);
    }

    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }

    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }

    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      parts.add(place.postalCode!);
    }

    return parts.join(', ');
  }

  /// Generate nearby addresses around a location
  /// This creates a grid of points around the user's location
  Future<List<NearbyAddress>> generateNearbyAddresses(
    Position userPosition, {
    int radiusMeters = 200, // Search within 200m
    int gridPoints = 8, // Number of points to check around user
  }) async {
    List<NearbyAddress> addresses = [];

    // Generate points in a circle around user
    for (int i = 0; i < gridPoints; i++) {
      final angle = (2 * math.pi * i) / gridPoints;
      
      // Calculate offset in lat/lon (approximately)
      // 1 degree latitude ≈ 111km
      final latOffset = (radiusMeters / 111000) * math.cos(angle);
      final lonOffset = (radiusMeters / (111000 * math.cos(userPosition.latitude * math.pi / 180))) * math.sin(angle);

      final lat = userPosition.latitude + latOffset;
      final lon = userPosition.longitude + lonOffset;

      // Get address for this point
      final address = await getAddressFromCoordinates(lat, lon);
      
      if (address != null) {
        final distance = calculateDistance(
          userPosition.latitude,
          userPosition.longitude,
          lat,
          lon,
        );

        addresses.add(NearbyAddress(
          address: address,
          latitude: lat,
          longitude: lon,
          distanceMeters: distance.round(),
        ));
      }

      // Small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Remove duplicates based on address
    final uniqueAddresses = <String, NearbyAddress>{};
    for (var addr in addresses) {
      if (!uniqueAddresses.containsKey(addr.address)) {
        uniqueAddresses[addr.address] = addr;
      }
    }

    // Sort by distance
    final result = uniqueAddresses.values.toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    return result;
  }

  /// Get Street View image URL for an address
  String getStreetViewUrl(
    double latitude,
    double longitude,
    String apiKey, {
    int width = 400,
    int height = 300,
  }) {
    return 'https://maps.googleapis.com/maps/api/streetview?'
        'size=${width}x$height'
        '&location=$latitude,$longitude'
        '&key=$apiKey'
        '&fov=90'
        '&pitch=0';
  }
}

/// Model for nearby addresses
class NearbyAddress {
  final String address;
  final double latitude;
  final double longitude;
  final int distanceMeters;

  NearbyAddress({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });

  String get distanceText {
    if (distanceMeters < 1000) {
      return '$distanceMeters m';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
  }
}
