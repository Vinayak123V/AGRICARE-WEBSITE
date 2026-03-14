// lib/widgets/live_tracking_map.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/live_tracking_models.dart';
import '../../services/live_tracking_service.dart';
import 'tracking_timeline.dart';

class LiveTrackingMap extends StatefulWidget {
  final String bookingId;
  final String serviceName;
  final String customerAddress;
  final String customerId;
  final String sourceLocation;

  const LiveTrackingMap({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.customerAddress,
    required this.customerId,
    this.sourceLocation = 'BAGALKOT',
  });

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  final LiveTrackingService _trackingService = LiveTrackingService();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  BitmapDescriptor? _providerMarkerIcon;
  BitmapDescriptor? _customerMarkerIcon;
  BitmapDescriptor? _vehicleMarkerIcon;
  
  late AnimationController _pulseController;
  late AnimationController _routeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _routeAnimation;
  
  bool _isLoading = true;
  bool _isMapReady = false;
  bool _showTimeline = false;
  String _errorMessage = '';

  // Convert location name to LatLng coordinates
  LatLng _getLocationFromName(String locationName) {
    switch (locationName.toUpperCase()) {
      case 'BAGALKOT':
        return const LatLng(16.18, 75.7); // BAGALKOT coordinates (16.18°N, 75.7°E)
      case 'BENGALURU':
        return const LatLng(12.9716, 77.5946);
      case 'MUMBAI':
        return const LatLng(19.0760, 72.8777);
      case 'DELHI':
        return const LatLng(28.7041, 77.1025);
      default:
        return const LatLng(16.18, 75.7); // Default to BAGALKOT (16.18°N, 75.7°E)
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _createCustomMarkers();
    _initializeTracking();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _routeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _routeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _routeController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _createCustomMarkers() async {
    try {
      // Try to load custom tractor icon
      _vehicleMarkerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(64, 64)),
        'assets/images/tractor_marker.png',
      );
      
      _providerMarkerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/provider_marker.png',
      );
      
      _customerMarkerIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/customer_marker.png',
      );
    } catch (e) {
      debugPrint('⚠️ Error creating custom markers: $e');
      // Create custom tractor icon using Flutter's built-in icons
      _vehicleMarkerIcon = await _createTractorMarkerIcon();
      _providerMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _customerMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  Future<BitmapDescriptor> _createTractorMarkerIcon() async {
    try {
      // Create a custom tractor icon using Flutter widgets
      return await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(64, 64)),
        'assets/images/tractor_icon.png',
      );
    } catch (e) {
      // Fallback to agriculture icon with green color
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  Future<void> _initializeTracking() async {
    try {
      // Get customer location from address
      final customerLocation = await _getLocationFromAddress(widget.customerAddress);
      
      // Get source location from name
      final sourceLocation = _getLocationFromName(widget.sourceLocation);
      
      // Initialize tracking if not already done
      if (_trackingService.isTracking == false) {
        await _trackingService.initializeTracking(
          bookingId: widget.bookingId,
          customerId: widget.customerId,
          customerLocation: customerLocation,
          sourceLocation: sourceLocation,
          providerId: 'provider_001',
          providerInfo: ProviderInfo(
            id: 'provider_001',
            name: 'Ramesh Kumar',
            phone: '+919876543210',
            photo: 'https://picsum.photos/seed/provider1/200/200.jpg',
            vehicleType: 'Tractor',
            vehicleNumber: 'AGRI-1234',
            rating: 4.8,
            completedServices: 156,
          ),
          customerName: 'Customer', // Will be updated from actual data
          customerPhone: '+919876543210', // Will be updated from actual data
          serviceName: widget.serviceName,
        );
      }
      setState(() {
        _isLoading = false;
      });
      
      // Listen to tracking updates
      _trackingService.addListener(_onTrackingUpdated);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initializing tracking: $e';
      });
    }
  }

  Future<LatLng> _getLocationFromAddress(String address) async {
    try {
      // For demo purposes, return a fixed location
      // In production, use geocoding API
      return const LatLng(20.5937, 78.9629); // Default to India center
    } catch (e) {
      debugPrint('Error getting location from address: $e');
      return const LatLng(20.5937, 78.9629);
    }
  }

  void _onTrackingUpdated() {
    if (_trackingService.currentTracking != null && _isMapReady) {
      _updateMapElements();
      _animateCameraToProvider();
    }
  }

  void _updateMapElements() {
    final tracking = _trackingService.currentTracking!;
    
    setState(() {
      _markers = {
        // Tractor/Provider marker (animated with tractor icon)
        Marker(
          markerId: MarkerId('provider_${tracking.bookingId}'),
          position: tracking.providerLocation,
          icon: _vehicleMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: '🚜 ${tracking.providerName ?? 'Service Provider'}',
            snippet: '${tracking.vehicleType ?? 'Tractor'} • ${tracking.vehicleNumber ?? 'AGRI-1234'}',
          ),
          anchor: const Offset(0.5, 0.5),
          rotation: _calculateBearing(tracking),
        ),
        
        // Customer marker with home icon
        Marker(
          markerId: MarkerId('customer_${tracking.bookingId}'),
          position: tracking.customerLocation,
          icon: _customerMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: '🏠 Your Location',
            snippet: widget.customerAddress,
          ),
          anchor: const Offset(0.5, 0.5),
        ),
      };
      
      // Enhanced route polyline with gradient effect
      if (tracking.routePoints.isNotEmpty) {
        _polylines = {
          Polyline(
            polylineId: PolylineId('route_${tracking.bookingId}'),
            points: tracking.routePoints,
            color: const Color(0xFF047857),
            width: 6,
            patterns: [PatternItem.dash(15), PatternItem.gap(8)],
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
          // Add a thinner white line on top for better visibility
          Polyline(
            polylineId: PolylineId('route_overlay_${tracking.bookingId}'),
            points: tracking.routePoints,
            color: Colors.white,
            width: 2,
            patterns: [PatternItem.dash(10), PatternItem.gap(5)],
          ),
        };
      }
    });
  }

  double _calculateBearing(LiveTrackingData tracking) {
    // Calculate bearing based on movement direction
    if (tracking.routePoints.length < 2) return 0.0;
    
    final currentPos = tracking.providerLocation;
    LatLng? nextPoint;
    
    // Find the next point in route
    for (final point in tracking.routePoints) {
      final distance = _calculateDistance(currentPos, point);
      if (distance > 0.001) { // 100m threshold
        nextPoint = point;
        break;
      }
    }
    
    if (nextPoint == null) return 0.0;
    
    // Calculate bearing from current position to next point
    final lat1 = currentPos.latitude * (3.14159 / 180);
    final lat2 = nextPoint.latitude * (3.14159 / 180);
    final deltaLng = (nextPoint.longitude - currentPos.longitude) * (3.14159 / 180);
    
    final y = sin(deltaLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);
    
    final bearing = atan2(y, x) * (180 / 3.14159);
    return (bearing + 360) % 360;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final lat1Rad = point1.latitude * (3.14159 / 180);
    final lat2Rad = point2.latitude * (3.14159 / 180);
    final deltaLatRad = (point2.latitude - point1.latitude) * (3.14159 / 180);
    final deltaLngRad = (point2.longitude - point1.longitude) * (3.14159 / 180);
    
    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  void _animateCameraToProvider() async {
    if (_mapController == null || _trackingService.currentTracking == null) return;
    
    final providerLocation = _trackingService.currentTracking!.providerLocation;
    
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: providerLocation,
          zoom: 15.0,
          tilt: 45.0,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _isMapReady = true;
    
    debugPrint('✅ Google Map created successfully');
    
    // Initial map setup
    if (_trackingService.currentTracking != null) {
      _updateMapElements();
      _animateCameraToProvider();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Tracking - ${widget.serviceName}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showTimeline ? Icons.map : Icons.timeline),
            onPressed: () {
              setState(() {
                _showTimeline = !_showTimeline;
              });
            },
            tooltip: _showTimeline ? 'Show Map' : 'Show Timeline',
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _animateCameraToProvider,
            tooltip: 'Center on Provider',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text('Initializing live tracking...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                )
              : _showTimeline
                  ? _buildTimelineView()
                  : _buildMapView(),
    );
  }

  Widget _buildMapView() {
    return Column(
      children: [
        // Status and ETA Card
        _buildStatusCard(),
        
        // Map
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _trackingService.currentTracking?.providerLocation ?? 
                         const LatLng(20.5937, 78.9629),
                  zoom: 15.0,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
                trafficEnabled: true,
                onTap: (LatLng position) {
                  debugPrint('📍 Map tapped at: ${position.latitude}, ${position.longitude}');
                },
              ),
              
              // Provider Info Card
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _buildProviderInfoCard(),
              ),
              
              // Floating Action Buttons
              Positioned(
                bottom: 100,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'contact',
                      onPressed: _contactProvider,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.phone, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'share',
                      onPressed: _shareTracking,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.share, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Bottom Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildTimelineView() {
    return Column(
      children: [
        // Status and ETA Card
        _buildStatusCard(),
        
        // Timeline
        Expanded(
          child: SingleChildScrollView(
            child: TrackingTimeline(events: _trackingService.trackingEvents),
          ),
        ),
        
        // Bottom Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildStatusCard() {
    return AnimatedBuilder(
      animation: _trackingService,
      builder: (context, child) {
        final tracking = _trackingService.currentTracking;
        if (tracking == null) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getStatusText(tracking.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Icon(
                          _getStatusIcon(tracking.status),
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        _trackingService.getFormattedETA(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'ETA',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.directions, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        _trackingService.getFormattedDistance(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Distance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProviderInfoCard() {
    final tracking = _trackingService.currentTracking;
    if (tracking == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Provider Photo with online indicator
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF047857),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: tracking.providerPhoto != null
                          ? NetworkImage(tracking.providerPhoto!)
                          : null,
                      child: tracking.providerPhoto == null
                          ? Text(
                              tracking.providerName?.substring(0, 1).toUpperCase() ?? 'P',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                      backgroundColor: const Color(0xFF047857),
                    ),
                  ),
                  // Online indicator
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Provider Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tracking.providerName ?? 'Service Provider',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              const Text(
                                '4.8',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '156 services completed',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF047857).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.agriculture,
                                color: Color(0xFF047857),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '🚜 ${tracking.vehicleType ?? 'Tractor'}',
                                style: const TextStyle(
                                  color: Color(0xFF047857),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tracking.vehicleNumber ?? 'AGRI-1234',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status Indicator with animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: tracking.status == TrackingStatus.on_way ? _pulseAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(tracking.status),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(tracking.status).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(tracking.status),
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getStatusText(tracking.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Progress bar for ETA
          if (tracking.status == TrackingStatus.on_way || tracking.status == TrackingStatus.arriving)
            Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Arriving in ${_trackingService.getFormattedETA()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF047857),
                      ),
                    ),
                    Text(
                      _trackingService.getFormattedDistance(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _calculateProgress(tracking),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF047857)),
                  minHeight: 6,
                ),
              ],
            ),
        ],
      ),
    );
  }

  double _calculateProgress(LiveTrackingData tracking) {
    if (tracking.distanceRemaining == null) return 0.0;
    
    // Assume initial distance was 10km for demo
    const initialDistance = 10.0;
    final remaining = tracking.distanceRemaining!;
    
    return ((initialDistance - remaining) / initialDistance).clamp(0.0, 1.0);
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _contactProvider,
              icon: const Icon(Icons.phone),
              label: const Text('Call Provider'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _openDirections,
              icon: const Icon(Icons.directions),
              label: const Text('Directions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _shareTracking,
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.assigned:
        return 'Provider Assigned';
      case TrackingStatus.on_way:
        return 'On The Way';
      case TrackingStatus.arriving:
        return 'Arriving Soon';
      case TrackingStatus.in_progress:
        return 'Service In Progress';
      case TrackingStatus.completed:
        return 'Service Completed';
      case TrackingStatus.cancelled:
        return 'Service Cancelled';
    }
  }

  IconData _getStatusIcon(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.assigned:
        return Icons.assignment_ind;
      case TrackingStatus.on_way:
        return Icons.directions_car;
      case TrackingStatus.arriving:
        return Icons.near_me;
      case TrackingStatus.in_progress:
        return Icons.handyman;
      case TrackingStatus.completed:
        return Icons.check_circle;
      case TrackingStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.assigned:
        return Colors.blue;
      case TrackingStatus.on_way:
        return Colors.orange;
      case TrackingStatus.arriving:
        return Colors.deepOrange;
      case TrackingStatus.in_progress:
        return Colors.purple;
      case TrackingStatus.completed:
        return Colors.green;
      case TrackingStatus.cancelled:
        return Colors.red;
    }
  }

  Future<void> _contactProvider() async {
    final tracking = _trackingService.currentTracking;
    if (tracking?.providerPhone != null) {
      final url = 'tel:${tracking!.providerPhone}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  Future<void> _openDirections() async {
    final tracking = _trackingService.currentTracking;
    if (tracking != null) {
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${tracking.customerLocation.latitude},${tracking.customerLocation.longitude}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _shareTracking() async {
    final tracking = _trackingService.currentTracking;
    if (tracking != null) {
      // Share tracking link (in production, create actual sharing URL)
      final shareText = 'Track my service: ${widget.serviceName}\nProvider: ${tracking.providerName}\nETA: ${_trackingService.getFormattedETA()}';
      
      // In production, use share package
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sharing: $shareText')),
      );
    }
  }

  @override
  void dispose() {
    _trackingService.removeListener(_onTrackingUpdated);
    _trackingService.stopTracking();
    _pulseController.dispose();
    _routeController.dispose();
    super.dispose();
  }
}
