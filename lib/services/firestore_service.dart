import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/house.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _housesCollection = 'houses';

  // Get all participating houses (public view)
  Stream<List<House>> getParticipatingHouses() {
    return _db
        .collection(_housesCollection)
        .where('isParticipating', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => House.fromFirestore(doc)).toList());
  }

  // Get houses within a specific area (for map zoom level)
  Stream<List<House>> getHousesInArea({
    required double centerLat,
    required double centerLon,
    required double radiusMeters,
  }) {
    // Approximate lat/lon delta for the radius
    // 1 degree latitude ≈ 111km
    final latDelta = radiusMeters / 111000;
    final lonDelta = radiusMeters / (111000 * 0.7); // Approximate adjustment for longitude

    return _db
        .collection(_housesCollection)
        .where('latitude', isGreaterThan: centerLat - latDelta)
        .where('latitude', isLessThan: centerLat + latDelta)
        .where('isParticipating', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      // Filter by longitude in memory (Firestore doesn't support multiple range queries)
      return snapshot.docs
          .map((doc) => House.fromFirestore(doc))
          .where((house) =>
              house.longitude >= centerLon - lonDelta &&
              house.longitude <= centerLon + lonDelta)
          .toList();
    });
  }

  // Get user's houses
  Stream<List<House>> getUserHouses(String userId) {
    return _db
        .collection(_housesCollection)
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => House.fromFirestore(doc)).toList());
  }

  // Add or update house
  Future<void> saveHouse(House house) async {
    try {
      if (house.id.isEmpty) {
        // Create new house
        await _db.collection(_housesCollection).add(house.toMap());
      } else {
        // Update existing house
        await _db.collection(_housesCollection).doc(house.id).set(
              house.toMap(),
              SetOptions(merge: true),
            );
      }
    } catch (e) {
      print('Error saving house: $e');
      rethrow;
    }
  }

  // Report house anonymously
  Future<void> reportHouseAnonymously({
    required String address,
    required double latitude,
    required double longitude,
    required bool isParticipating,
    bool lightsOn = true,
    bool halloweenDecorations = false,
  }) async {
    try {
      // Check if house already exists at this location
      final existing = await _db
          .collection(_housesCollection)
          .where('address', isEqualTo: address)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // House exists - increment report count
        final doc = existing.docs.first;
        final house = House.fromFirestore(doc);
        
        await _db.collection(_housesCollection).doc(doc.id).update({
          'isParticipating': isParticipating,
          'reportCount': house.reportCount + 1,
          'lightsOn': lightsOn,
          'halloweenDecorations': halloweenDecorations,
          'lastUpdated': Timestamp.now(),
        });
      } else {
        // Create new anonymous report
        final house = House(
          id: '',
          address: address,
          latitude: latitude,
          longitude: longitude,
          isParticipating: isParticipating,
          ownerId: '', // Empty for anonymous
          lastUpdated: DateTime.now(),
          isAnonymousReport: true,
          reportCount: 1,
          lightsOn: lightsOn,
          halloweenDecorations: halloweenDecorations,
        );
        
        await _db.collection(_housesCollection).add(house.toMap());
      }
    } catch (e) {
      print('Error reporting house anonymously: $e');
      rethrow;
    }
  }

  // Delete house
  Future<void> deleteHouse(String houseId) async {
    try {
      await _db.collection(_housesCollection).doc(houseId).delete();
    } catch (e) {
      print('Error deleting house: $e');
      rethrow;
    }
  }

  // Update participation status
  Future<void> updateParticipationStatus(
      String houseId, bool isParticipating) async {
    try {
      await _db.collection(_housesCollection).doc(houseId).update({
        'isParticipating': isParticipating,
        'lastUpdated': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating participation: $e');
      rethrow;
    }
  }
}

