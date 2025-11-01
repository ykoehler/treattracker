import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  final String id;
  final String address;
  final double latitude;
  final double longitude;
  final bool isParticipating;
  final String ownerId; // Empty string for anonymous reports
  final DateTime lastUpdated;
  final String? notes;
  final bool isAnonymousReport; // True if reported by anonymous user
  final int reportCount; // Number of people who reported this house
  final bool lightsOn; // Whether lights are on at the house
  final bool halloweenDecorations; // Whether house has Halloween decorations

  House({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isParticipating,
    required this.ownerId,
    required this.lastUpdated,
    this.notes,
    this.isAnonymousReport = false,
    this.reportCount = 1,
    this.lightsOn = true,
    this.halloweenDecorations = false,
  });

  factory House.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return House(
      id: doc.id,
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      isParticipating: data['isParticipating'] ?? false,
      ownerId: data['ownerId'] ?? '',
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      notes: data['notes'],
      isAnonymousReport: data['isAnonymousReport'] ?? false,
      reportCount: data['reportCount'] ?? 1,
      lightsOn: data['lightsOn'] ?? true,
      halloweenDecorations: data['halloweenDecorations'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isParticipating': isParticipating,
      'ownerId': ownerId,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'notes': notes,
      'isAnonymousReport': isAnonymousReport,
      'reportCount': reportCount,
      'lightsOn': lightsOn,
      'halloweenDecorations': halloweenDecorations,
    };
  }

  /// Create a copy with updated fields
  House copyWith({
    String? id,
    String? address,
    double? latitude,
    double? longitude,
    bool? isParticipating,
    String? ownerId,
    DateTime? lastUpdated,
    String? notes,
    bool? isAnonymousReport,
    int? reportCount,
    bool? lightsOn,
    bool? halloweenDecorations,
  }) {
    return House(
      id: id ?? this.id,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isParticipating: isParticipating ?? this.isParticipating,
      ownerId: ownerId ?? this.ownerId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
      isAnonymousReport: isAnonymousReport ?? this.isAnonymousReport,
      reportCount: reportCount ?? this.reportCount,
      lightsOn: lightsOn ?? this.lightsOn,
      halloweenDecorations: halloweenDecorations ?? this.halloweenDecorations,
    );
  }
}

