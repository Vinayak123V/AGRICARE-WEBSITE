// lib/models/live_tracking_models.dart

import 'package:google_maps_flutter/google_maps_flutter.dart';

enum TrackingStatus {
  assigned,      // Service provider assigned
  on_way,        // Provider is on the way
  arriving,      // Provider is arriving (nearby)
  in_progress,   // Service in progress
  completed,     // Service completed
  cancelled      // Service cancelled
}

class LiveTrackingData {
  final String bookingId;
  final String customerId;
  final String providerId;
  final LatLng customerLocation;
  final LatLng providerLocation;
  final List<LatLng> routePoints;
  final TrackingStatus status;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final double? distanceRemaining;
  final Duration? estimatedTimeOfArrival;

  // Provider information
  final String? providerName;
  final String? providerPhone;
  final String? providerPhoto;
  final String? vehicleType;
  final String? vehicleNumber;

  // Customer information for SMS
  final String? customerName;
  final String? customerPhone;
  final String? serviceName;

  LiveTrackingData({
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.customerLocation,
    required this.providerLocation,
    required this.routePoints,
    required this.status,
    required this.createdAt,
    required this.lastUpdated,
    this.distanceRemaining,
    this.estimatedTimeOfArrival,
    this.providerName,
    this.providerPhone,
    this.providerPhoto,
    this.vehicleType,
    this.vehicleNumber,
    this.customerName,
    this.customerPhone,
    this.serviceName,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'providerId': providerId,
      'customerLocation': {
        'latitude': customerLocation.latitude,
        'longitude': customerLocation.longitude,
      },
      'providerLocation': {
        'latitude': providerLocation.latitude,
        'longitude': providerLocation.longitude,
      },
      'routePoints': routePoints.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'estimatedTimeOfArrival': estimatedTimeOfArrival?.inMinutes,
      'distanceRemaining': distanceRemaining,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'providerPhoto': providerPhoto,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceName': serviceName,
    };
  }

  factory LiveTrackingData.fromMap(Map<String, dynamic> map) {
    return LiveTrackingData(
      bookingId: map['bookingId'],
      customerId: map['customerId'],
      providerId: map['providerId'],
      customerLocation: LatLng(
        map['customerLocation']['latitude'],
        map['customerLocation']['longitude'],
      ),
      providerLocation: LatLng(
        map['providerLocation']['latitude'],
        map['providerLocation']['longitude'],
      ),
      routePoints: (map['routePoints'] as List).map((point) => LatLng(
        point['latitude'],
        point['longitude'],
      )).toList(),
      status: TrackingStatus.values.firstWhere(
        (status) => status.toString() == map['status'],
        orElse: () => TrackingStatus.assigned,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      estimatedTimeOfArrival: map['estimatedTimeOfArrival'] != null
          ? Duration(minutes: map['estimatedTimeOfArrival'])
          : null,
      distanceRemaining: map['distanceRemaining']?.toDouble(),
      providerName: map['providerName'],
      providerPhone: map['providerPhone'],
      providerPhoto: map['providerPhoto'],
      vehicleType: map['vehicleType'],
      vehicleNumber: map['vehicleNumber'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      serviceName: map['serviceName'],
    );
  }

  LiveTrackingData copyWith({
    LatLng? providerLocation,
    List<LatLng>? routePoints,
    TrackingStatus? status,
    DateTime? lastUpdated,
    Duration? estimatedTimeOfArrival,
    double? distanceRemaining,
    String? providerName,
    String? providerPhone,
    String? providerPhoto,
    String? vehicleType,
    String? vehicleNumber,
    String? customerName,
    String? customerPhone,
    String? serviceName,
  }) {
    return LiveTrackingData(
      bookingId: bookingId,
      customerId: customerId,
      providerId: providerId,
      customerLocation: customerLocation,
      providerLocation: providerLocation ?? this.providerLocation,
      routePoints: routePoints ?? this.routePoints,
      status: status ?? this.status,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      estimatedTimeOfArrival: estimatedTimeOfArrival ?? this.estimatedTimeOfArrival,
      distanceRemaining: distanceRemaining ?? this.distanceRemaining,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      providerPhoto: providerPhoto ?? this.providerPhoto,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceName: serviceName ?? this.serviceName,
    );
  }
}

class TrackingEvent {
  final String id;
  final String bookingId;
  final TrackingStatus status;
  final DateTime timestamp;
  final String? description;
  final LatLng? location;

  TrackingEvent({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.timestamp,
    this.description,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'status': status.toString(),
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'location': location != null ? {
        'latitude': location!.latitude,
        'longitude': location!.longitude,
      } : null,
    };
  }

  factory TrackingEvent.fromMap(Map<String, dynamic> map) {
    return TrackingEvent(
      id: map['id'],
      bookingId: map['bookingId'],
      status: TrackingStatus.values.firstWhere(
        (status) => status.toString() == map['status'],
        orElse: () => TrackingStatus.assigned,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      description: map['description'],
      location: map['location'] != null ? LatLng(
        map['location']['latitude'],
        map['location']['longitude'],
      ) : null,
    );
  }
}

class ProviderInfo {
  final String id;
  final String name;
  final String phone;
  final String? photo;
  final String? vehicleType;
  final String? vehicleNumber;
  final double rating;
  final int completedServices;

  ProviderInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.photo,
    this.vehicleType,
    this.vehicleNumber,
    required this.rating,
    required this.completedServices,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photo': photo,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'rating': rating,
      'completedServices': completedServices,
    };
  }

  factory ProviderInfo.fromMap(Map<String, dynamic> map) {
    return ProviderInfo(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      photo: map['photo'],
      vehicleType: map['vehicleType'],
      vehicleNumber: map['vehicleNumber'],
      rating: map['rating']?.toDouble() ?? 0.0,
      completedServices: map['completedServices'] ?? 0,
    );
  }
}
