// lib/services/live_tracking_service.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/live_tracking_models.dart';
import 'firebase_sms_service.dart';

class LiveTrackingService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PolylinePoints _polylinePoints = PolylinePoints();
  
  static const String _googleDirectionsApiKey = 'AIzaSyD-pS3jWAyGHwuQKLeOmwws0ZpHcX5_8-w';
  static const String _trackingCollection = 'live_tracking';
  static const String _eventsCollection = 'tracking_events';
  
  LiveTrackingData? _currentTracking;
  List<TrackingEvent> _trackingEvents = [];
  StreamSubscription<DocumentSnapshot>? _trackingSubscription;
  StreamSubscription<QuerySnapshot>? _eventsSubscription;
  Timer? _simulationTimer;
  
  LiveTrackingData? get currentTracking => _currentTracking;
  List<TrackingEvent> get trackingEvents => _trackingEvents;
  bool get isTracking => _currentTracking != null;
  
  /// Initialize live tracking for a booking
  Future<void> initializeTracking({
    required String bookingId,
    required String customerId,
    required LatLng customerLocation,
    required String providerId,
    required ProviderInfo providerInfo,
    required String customerName,
    required String customerPhone,
    required String serviceName,
    LatLng? sourceLocation,
  }) async {
    try {
      debugPrint('📍 Initializing live tracking for booking: $bookingId');
      
      // Create initial tracking data
      _currentTracking = LiveTrackingData(
        bookingId: bookingId,
        customerId: customerId,
        providerId: providerId,
        customerLocation: customerLocation,
        providerLocation: sourceLocation ?? _getRandomNearbyLocation(customerLocation),
        routePoints: [],
        status: TrackingStatus.assigned,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        providerName: providerInfo.name,
        providerPhone: providerInfo.phone,
        providerPhoto: providerInfo.photo,
        vehicleType: providerInfo.vehicleType ?? 'Agricultural Vehicle',
        vehicleNumber: providerInfo.vehicleNumber ?? 'AGRI-1234',
        customerName: customerName,
        customerPhone: customerPhone,
        serviceName: serviceName,
      );
      
      // Save to Firestore
      await _firestore.collection(_trackingCollection).doc(bookingId).set(
        _currentTracking!.toMap(),
      );
      
      // Create initial tracking event
      await _addTrackingEvent(
        bookingId: bookingId,
        status: TrackingStatus.assigned,
        description: 'Service provider assigned to your booking',
        location: _currentTracking!.providerLocation,
      );
      
      // Get route from provider to customer
      await _calculateRoute();
      
      // Start real-time listeners
      await _startRealtimeUpdates(bookingId);
      
      // Start simulation for demo purposes
      _startSimulation();
      
      notifyListeners();
      
      debugPrint('✅ Live tracking initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing live tracking: $e');
      throw Exception('Failed to initialize live tracking: $e');
    }
  }
  
  /// Start real-time updates from Firestore
  Future<void> _startRealtimeUpdates(String bookingId) async {
    // Listen to tracking data changes
    _trackingSubscription = _firestore
        .collection(_trackingCollection)
        .doc(bookingId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _currentTracking = LiveTrackingData.fromMap(snapshot.data()!);
        notifyListeners();
      }
    });
    
    // Listen to tracking events
    _eventsSubscription = _firestore
        .collection(_eventsCollection)
        .where('bookingId', isEqualTo: bookingId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _trackingEvents = snapshot.docs
          .map((doc) => TrackingEvent.fromMap(doc.data()))
          .toList();
      notifyListeners();
    });
  }
  
  /// Calculate route from provider to customer using Google Directions API
  Future<void> _calculateRoute() async {
    if (_currentTracking == null) return;
    
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${_currentTracking!.providerLocation.latitude},${_currentTracking!.providerLocation.longitude}'
          '&destination=${_currentTracking!.customerLocation.latitude},${_currentTracking!.customerLocation.longitude}'
          '&key=$_googleDirectionsApiKey',
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final legs = route['legs'][0];
          
          // Extract route points
          final polylinePoints = _polylinePoints.decodePolyline(
            route['overview_polyline']['points'],
          );
          
          final routeCoordinates = polylinePoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
          
          // Calculate distance and duration
          final distance = legs['distance']['value'] / 1000; // Convert to km
          final duration = Duration(seconds: legs['duration']['value']);
          
          // Update tracking data
          _currentTracking = _currentTracking!.copyWith(
            routePoints: routeCoordinates,
            distanceRemaining: distance,
            estimatedTimeOfArrival: duration,
            lastUpdated: DateTime.now(),
          );
          
          // Update in Firestore
          await _updateTrackingData();
          
          debugPrint('🛣️ Route calculated: ${distance.toStringAsFixed(2)} km, ${duration.inMinutes} min');
        }
      }
    } catch (e) {
      debugPrint('❌ Error calculating route: $e');
      // Fallback: create straight line route
      await _createFallbackRoute();
    }
  }
  
  /// Create fallback straight-line route if API fails
  Future<void> _createFallbackRoute() async {
    if (_currentTracking == null) return;
    
    final start = _currentTracking!.providerLocation;
    final end = _currentTracking!.customerLocation;
    
    // Create simple straight line with intermediate points
    final routePoints = <LatLng>[];
    final steps = 20;
    
    for (int i = 0; i <= steps; i++) {
      final lat = start.latitude + (end.latitude - start.latitude) * i / steps;
      final lng = start.longitude + (end.longitude - start.longitude) * i / steps;
      routePoints.add(LatLng(lat, lng));
    }
    
    // Calculate approximate distance (straight line)
    final distance = Geolocator.distanceBetween(
      start.latitude, start.longitude,
      end.latitude, end.longitude,
    ) / 1000; // Convert to km
    
    // Estimate time (assuming 30 km/h average speed for agricultural vehicles)
    final estimatedTime = Duration(minutes: ((distance / 30) * 60).round());
    
    _currentTracking = _currentTracking!.copyWith(
      routePoints: routePoints,
      distanceRemaining: distance,
      estimatedTimeOfArrival: estimatedTime,
      lastUpdated: DateTime.now(),
    );
    
    await _updateTrackingData();
  }
  
  /// Update provider location (called by provider app)
  Future<void> updateProviderLocation(LatLng newLocation) async {
    if (_currentTracking == null) return;
    
    _currentTracking = _currentTracking!.copyWith(
      providerLocation: newLocation,
      lastUpdated: DateTime.now(),
    );
    
    await _updateTrackingData();
  }
  
  /// Update tracking status
  Future<void> updateTrackingStatus(TrackingStatus status, {String? description}) async {
    if (_currentTracking == null) return;
    
    _currentTracking = _currentTracking!.copyWith(
      status: status,
      lastUpdated: DateTime.now(),
    );
    
    await _updateTrackingData();
    
    // Add tracking event
    await _addTrackingEvent(
      bookingId: _currentTracking!.bookingId,
      status: status,
      description: description ?? _getStatusDescription(status),
      location: _currentTracking!.providerLocation,
    );
    
    // Send SMS notification for important status updates
    await _sendStatusUpdateSMS(status);
  }
  
  /// Add tracking event
  Future<void> _addTrackingEvent({
    required String bookingId,
    required TrackingStatus status,
    required String description,
    LatLng? location,
  }) async {
    final event = TrackingEvent(
      id: '${bookingId}_${status.toString()}_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      status: status,
      timestamp: DateTime.now(),
      description: description,
      location: location,
    );
    
    await _firestore.collection(_eventsCollection).doc(event.id).set(event.toMap());
  }
  
  /// Update tracking data in Firestore
  Future<void> _updateTrackingData() async {
    if (_currentTracking == null) return;
    
    await _firestore
        .collection(_trackingCollection)
        .doc(_currentTracking!.bookingId)
        .update(_currentTracking!.toMap());
  }
  
  /// Get status description
  String _getStatusDescription(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.assigned:
        return 'Service provider has been assigned';
      case TrackingStatus.on_way:
        return 'Service provider is on the way';
      case TrackingStatus.arriving:
        return 'Service provider is arriving soon';
      case TrackingStatus.in_progress:
        return 'Service is in progress';
      case TrackingStatus.completed:
        return 'Service has been completed';
      case TrackingStatus.cancelled:
        return 'Service has been cancelled';
    }
  }
  
  /// Start simulation for demo purposes
  void _startSimulation() {
    if (_currentTracking == null || _currentTracking!.routePoints.isEmpty) return;
    
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_currentTracking == null || _currentTracking!.status == TrackingStatus.completed) {
        timer.cancel();
        return;
      }
      
      // Simulate provider movement along route
      await _simulateProviderMovement();
    });
  }
  
  /// Simulate provider movement along route
  Future<void> _simulateProviderMovement() async {
    if (_currentTracking == null || _currentTracking!.routePoints.isEmpty) return;
    
    final routePoints = _currentTracking!.routePoints;
    final currentLocation = _currentTracking!.providerLocation;
    
    // Find next point in route
    LatLng? nextPoint;
    double minDistance = double.infinity;
    
    for (int i = 0; i < routePoints.length; i++) {
      final point = routePoints[i];
      final distance = Geolocator.distanceBetween(
        currentLocation.latitude, currentLocation.longitude,
        point.latitude, point.longitude,
      );
      
      if (distance < minDistance && distance > 50) { // 50m threshold
        minDistance = distance;
        nextPoint = point;
      }
    }
    
    if (nextPoint != null) {
      // Move provider towards next point
      final newLocation = _interpolateLocation(currentLocation, nextPoint, 0.1);
      
      await updateProviderLocation(newLocation);
      
      // Update remaining distance and ETA
      await _updateProgress();
      
      // Check if arrived
      final distanceToCustomer = Geolocator.distanceBetween(
        newLocation.latitude, newLocation.longitude,
        _currentTracking!.customerLocation.latitude,
        _currentTracking!.customerLocation.longitude,
      );
      
      if (distanceToCustomer < 100) { // 100m threshold
        await updateTrackingStatus(TrackingStatus.arriving,
          description: 'Service provider has arrived at your location',
        );
        
        // Complete service after some time
        Timer(const Duration(seconds: 10), () async {
          await updateTrackingStatus(TrackingStatus.completed,
            description: 'Service has been completed successfully',
          );
        });
      } else if (_currentTracking!.status == TrackingStatus.assigned) {
        await updateTrackingStatus(TrackingStatus.on_way);
      }
    }
  }
  
  /// Interpolate between two locations
  LatLng _interpolateLocation(LatLng start, LatLng end, double fraction) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * fraction,
      start.longitude + (end.longitude - start.longitude) * fraction,
    );
  }
  
  /// Update progress (distance and ETA)
  Future<void> _updateProgress() async {
    if (_currentTracking == null) return;
    
    final distanceToCustomer = Geolocator.distanceBetween(
      _currentTracking!.providerLocation.latitude,
      _currentTracking!.providerLocation.longitude,
      _currentTracking!.customerLocation.latitude,
      _currentTracking!.customerLocation.longitude,
    ) / 1000; // Convert to km
    
    // Estimate remaining time (assuming 30 km/h average speed)
    final remainingTime = Duration(minutes: ((distanceToCustomer / 30) * 60).round());
    
    _currentTracking = _currentTracking!.copyWith(
      distanceRemaining: distanceToCustomer,
      estimatedTimeOfArrival: remainingTime,
      lastUpdated: DateTime.now(),
    );
    
    await _updateTrackingData();
  }
  
  /// Get random nearby location for demo
  LatLng _getRandomNearbyLocation(LatLng center) {
    final random = Random();
    final radius = 0.01; // Approximately 1km radius
    
    final lat = center.latitude + (random.nextDouble() - 0.5) * radius * 2;
    final lng = center.longitude + (random.nextDouble() - 0.5) * radius * 2;
    
    return LatLng(lat, lng);
  }
  
  /// Stop tracking
  Future<void> stopTracking() async {
    _simulationTimer?.cancel();
    await _trackingSubscription?.cancel();
    await _eventsSubscription?.cancel();
    
    _currentTracking = null;
    _trackingEvents = [];
    
    notifyListeners();
    
    debugPrint('🛑 Live tracking stopped');
  }
  
  /// Get formatted ETA
  String getFormattedETA() {
    if (_currentTracking?.estimatedTimeOfArrival == null) return 'Calculating...';
    
    final eta = _currentTracking!.estimatedTimeOfArrival!;
    if (eta.inMinutes > 60) {
      return '${(eta.inMinutes / 60).floor()}h ${eta.inMinutes % 60}min';
    } else {
      return '${eta.inMinutes} min';
    }
  }
  
  /// Get formatted distance
  String getFormattedDistance() {
    if (_currentTracking?.distanceRemaining == null) return 'Calculating...';
    
    final distance = _currentTracking!.distanceRemaining!;
    if (distance < 1) {
      return '${(distance * 1000).round()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
  
  /// Send SMS notification for status updates
  Future<void> _sendStatusUpdateSMS(TrackingStatus status) async {
    if (_currentTracking == null) return;
    
    try {
      switch (status) {
        case TrackingStatus.on_way:
          await FirebaseSMSService.sendProviderOnWaySMS(
            farmerName: _currentTracking!.customerName ?? 'Farmer',
            farmerPhone: _currentTracking!.customerPhone ?? '',
            providerName: _currentTracking!.providerName ?? 'Service Provider',
            estimatedTime: getFormattedETA(),
          );
          break;
          
        case TrackingStatus.completed:
          await FirebaseSMSService.sendServiceCompletionSMS(
            farmerName: _currentTracking!.customerName ?? 'Farmer',
            farmerPhone: _currentTracking!.customerPhone ?? '',
            serviceName: _currentTracking!.serviceName ?? 'Service',
            bookingId: _currentTracking!.bookingId,
          );
          break;
          
        case TrackingStatus.arriving:
          // Send "Arriving Soon" SMS
          await _sendArrivingSoonSMS();
          break;
          
        default:
          // No SMS for other statuses
          break;
      }
    } catch (e) {
      debugPrint('❌ Error sending status update SMS: $e');
      // Don't fail the tracking if SMS fails
    }
  }
  
  /// Send "Arriving Soon" SMS
  Future<void> _sendArrivingSoonSMS() async {
    if (_currentTracking == null) return;
    
    final message = '''
🌾 AgriCare - Provider Arriving Soon! 🌾

Dear ${_currentTracking!.customerName},

Your service provider will arrive within 5-10 minutes:

👨‍🌾 Provider: ${_currentTracking!.providerName}
📋 Service: ${_currentTracking!.serviceName}
🆔 Booking ID: ${_currentTracking!.bookingId}
⏰ ETA: 5-10 minutes

📍 Please be ready at your location with any necessary materials.

📞 The provider will call you upon arrival.

Thank you for choosing AgriCare!
🌱 Growing Together, Harvesting Success 🌱
    ''';
    
    await FirebaseSMSService.sendSMS(
      phone: _currentTracking!.customerPhone ?? '',
      message: message,
    );
  }
  
  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
