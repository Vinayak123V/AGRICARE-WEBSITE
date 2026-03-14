// lib/services/mock_database_service.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_storage_service.dart';

class Booking {
  final String id;
  final String userId;
  final String serviceName;
  final String subServiceName;
  final String price;
  final String name;
  final String phone;
  final String address;
  final String date;
  final String status;
  final DateTime bookedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.serviceName,
    required this.subServiceName,
    required this.price,
    required this.name,
    required this.phone,
    required this.address,
    required this.date,
    required this.status,
    required this.bookedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'serviceName': serviceName,
      'subServiceName': subServiceName,
      'price': price,
      'name': name,
      'phone': phone,
      'address': address,
      'date': date,
      'status': status,
      'bookedAt': bookedAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['userId'],
      serviceName: map['serviceName'],
      subServiceName: map['subServiceName'],
      price: map['price'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      date: map['date'],
      status: map['status'],
      bookedAt: DateTime.parse(map['bookedAt']),
    );
  }
}

class UserNotification {
  final String id;
  final String userId;
  final String message;
  final DateTime timestamp;
  final bool read;

  UserNotification({
    required this.id,
    required this.userId,
    required this.message,
    required this.timestamp,
    required this.read,
  });
}

class MockDatabaseService extends ChangeNotifier {
  final Map<String, List<Booking>> _userBookings = {};
  final Map<String, List<UserNotification>> _userNotifications = {};
  final Map<String, Map<String, dynamic>> _userProfiles = {};
  
  // Cache for user statistics
  final Map<String, Map<String, int>> _userStats = {};

  // Bookings
  Future<Booking> createBooking({
    required String userId,
    required String serviceName,
    required String subServiceName,
    required String price,
    required String name,
    required String phone,
    required String address,
    required String date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Reduced delay for faster response

    // Create a farmer-friendly document ID using name + timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final farmerNameId = '${name.toLowerCase().replaceAll(' ', '_')}_$timestamp';
    final docRef = FirebaseFirestore.instance.collection('bookings').doc(farmerNameId);
    final bookingId = docRef.id;

    final booking = Booking(
      id: bookingId,
      userId: userId,
      serviceName: serviceName,
      subServiceName: subServiceName,
      price: price,
      name: name,
      phone: phone,
      address: address,
      date: date,
      status: 'Pending',
      bookedAt: DateTime.now(),
    );

    if (!_userBookings.containsKey(userId)) {
      _userBookings[userId] = [];
    }
    _userBookings[userId]!.add(booking);

    // Save to local storage immediately for persistence
    await LocalStorageService.saveBookings(userId, _userBookings[userId]!);

    // Persist booking to Firebase Firestore backend
    try {
      final bookingData = booking.toMap();
      // Add farmer-friendly fields for better identification
      bookingData['farmerName'] = name; // Keep original name
      bookingData['farmerId'] = farmerNameId; // Farmer-friendly document ID
      bookingData['displayName'] = '$name - $subServiceName'; // Combined display name
      // Use server timestamp in addition to local bookedAt for reliable ordering
      bookingData['bookedAtServer'] = FieldValue.serverTimestamp();

      // Use the document reference to set the data
      await docRef.set(bookingData);

      debugPrint('✅ Booking stored in Firestore with id: $bookingId');
    } catch (e) {
      debugPrint('❌ Failed to store booking in Firestore: $e');
      // Don't re-throw - we have local storage as backup
      debugPrint('📱 Booking saved to local storage as backup');
    }

    // Create notification
    await _createNotification(
      userId: userId,
      message: 'Your booking for $subServiceName ($serviceName) has been confirmed. We will contact you soon.',
    );

    notifyListeners();
    return booking;
  }

  List<Booking> getUserBookings(String userId) {
    return _userBookings[userId] ?? [];
  }

  Future<void> cancelBooking(String userId, String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_userBookings.containsKey(userId)) {
      final booking = _userBookings[userId]!.firstWhere(
        (b) => b.id == bookingId,
        orElse: () => throw Exception('Booking not found'),
      );

      _userBookings[userId]!.removeWhere((b) => b.id == bookingId);

      await _createNotification(
        userId: userId,
        message: 'Your booking for ${booking.subServiceName} has been cancelled.',
      );

      notifyListeners();
    }
  }

  // Notifications
  Future<void> _createNotification({
    required String userId,
    required String message,
  }) async {
    final notificationId = 'NOT${DateTime.now().millisecondsSinceEpoch}';
    final notification = UserNotification(
      id: notificationId,
      userId: userId,
      message: message,
      timestamp: DateTime.now(),
      read: false,
    );

    if (!_userNotifications.containsKey(userId)) {
      _userNotifications[userId] = [];
    }
    _userNotifications[userId]!.insert(0, notification);
    notifyListeners();

    // Optionally persist notification to Firestore for backend processing
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .set({
        'id': notification.id,
        'userId': notification.userId,
        'message': notification.message,
        'timestamp': Timestamp.fromDate(notification.timestamp),
        'read': notification.read,
      }, SetOptions(merge: true));

      debugPrint('✅ Notification stored in Firestore with id: $notificationId');
    } catch (e) {
      debugPrint('❌ Failed to store notification in Firestore: $e');
    }
  }

  List<UserNotification> getUserNotifications(String userId) {
    return _userNotifications[userId] ?? [];
  }

  int getUnreadNotificationCount(String userId) {
    if (!_userNotifications.containsKey(userId)) return 0;
    return _userNotifications[userId]!.where((n) => !n.read).length;
  }

  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    if (_userNotifications.containsKey(userId)) {
      final index = _userNotifications[userId]!.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _userNotifications[userId]![index];
        _userNotifications[userId]![index] = UserNotification(
          id: notification.id,
          userId: notification.userId,
          message: notification.message,
          timestamp: notification.timestamp,
          read: true,
        );
        notifyListeners();
      }
    }
  }

  // User Profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? phone,
    String? address,
    String? farmSize,
    String? cropType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_userProfiles.containsKey(userId)) {
      _userProfiles[userId] = {};
    }

    if (displayName != null) _userProfiles[userId]!['displayName'] = displayName;
    if (phone != null) _userProfiles[userId]!['phone'] = phone;
    if (address != null) _userProfiles[userId]!['address'] = address;
    if (farmSize != null) _userProfiles[userId]!['farmSize'] = farmSize;
    if (cropType != null) _userProfiles[userId]!['cropType'] = cropType;

    notifyListeners();
  }

  Map<String, dynamic>? getUserProfile(String userId) {
    return _userProfiles[userId];
  }

  // Statistics
  Map<String, int> getBookingStats(String userId) {
    final bookings = getUserBookings(userId);
    return {
      'total': bookings.length,
      'pending': bookings.where((b) => b.status == 'Pending').length,
      'completed': bookings.where((b) => b.status == 'Completed').length,
      'cancelled': bookings.where((b) => b.status == 'Cancelled').length,
    };
  }

  // Service-wise booking count
  Map<String, int> getServiceUsageStats(String userId) {
    final bookings = getUserBookings(userId);
    final Map<String, int> serviceCount = {};

    for (var booking in bookings) {
      serviceCount[booking.serviceName] = (serviceCount[booking.serviceName] ?? 0) + 1;
    }

    return serviceCount;
  }

  // Recent bookings
  List<Booking> getRecentBookings(String userId, {int limit = 5}) {
    final bookings = getUserBookings(userId);
    bookings.sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
    return bookings.take(limit).toList();
  }

  // Get user booking statistics
  Map<String, int> getUserBookingStats(String userId) {
    if (_userStats.containsKey(userId)) {
      return _userStats[userId]!;
    }
    
    final bookings = getUserBookings(userId);
    final stats = {
      'total': bookings.length,
      'pending': bookings.where((b) => b.status == 'Pending').length,
      'completed': bookings.where((b) => b.status == 'Completed').length,
      'cancelled': bookings.where((b) => b.status == 'Cancelled').length,
    };
    
    _userStats[userId] = stats;
    return stats;
  }

  // Load user data from Firestore and local storage (persistent storage)
  Future<void> loadUserDataFromFirestore(String userId) async {
    try {
      debugPrint('📥 ========================================');
      debugPrint('📥 Loading user data for user: $userId');
      debugPrint('📥 ========================================');
      
      // First, load from local storage for immediate availability
      final localBookings = await LocalStorageService.loadBookings(userId);
      if (localBookings.isNotEmpty) {
        _userBookings[userId] = localBookings;
        debugPrint('✅ Loaded ${localBookings.length} bookings from LOCAL STORAGE');
        for (var booking in localBookings) {
          debugPrint('   📦 ${booking.subServiceName} - ${booking.status} - ${booking.date}');
        }
        notifyListeners(); // Update UI immediately
      } else {
        debugPrint('📭 No bookings found in local storage');
      }
      
      // Then try to load from Firestore for sync
      try {
        debugPrint('🔄 Syncing bookings from FIRESTORE...');
        final bookingsSnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .orderBy('bookedAtServer', descending: true)
            .get();
        
        debugPrint('📊 Firestore returned ${bookingsSnapshot.docs.length} bookings');
        
        final List<Booking> firestoreBookings = [];
        for (final doc in bookingsSnapshot.docs) {
          try {
            final data = doc.data();
            data['id'] = doc.id; // Ensure ID is set
            final booking = Booking.fromMap(data);
            firestoreBookings.add(booking);
            debugPrint('   ✅ Loaded: ${booking.subServiceName} (${doc.id})');
          } catch (e) {
            debugPrint('   ❌ Error parsing booking ${doc.id}: $e');
          }
        }
        
        if (firestoreBookings.isNotEmpty) {
          _userBookings[userId] = firestoreBookings;
          // Update local storage with latest data
          await LocalStorageService.saveBookings(userId, firestoreBookings);
          debugPrint('✅ Synced ${firestoreBookings.length} bookings from Firestore to local storage');
        } else {
          debugPrint('📭 No bookings found in Firestore for user: $userId');
        }
        
        debugPrint('📥 ========================================');
        debugPrint('📥 Final booking count: ${_userBookings[userId]?.length ?? 0}');
        debugPrint('📥 ========================================');
        
        // Load notifications
        final notificationsSnapshot = await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .limit(50)
            .get();
        
        final List<UserNotification> loadedNotifications = [];
        for (final doc in notificationsSnapshot.docs) {
          try {
            final data = doc.data();
            final notification = UserNotification(
              id: doc.id,
              userId: data['userId'],
              message: data['message'],
              timestamp: (data['timestamp'] as Timestamp).toDate(),
              read: data['read'] ?? false,
            );
            loadedNotifications.add(notification);
          } catch (e) {
            debugPrint('❌ Error parsing notification ${doc.id}: $e');
          }
        }
        
        if (loadedNotifications.isNotEmpty) {
          _userNotifications[userId] = loadedNotifications;
          debugPrint('✅ Loaded ${loadedNotifications.length} notifications from Firestore');
        }
        
      } catch (firestoreError) {
        debugPrint('⚠️ Firestore unavailable, using local storage: $firestoreError');
        // If Firestore fails, we already have local data loaded above
      }
      
      // Refresh stats cache
      _userStats.remove(userId);
      
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
    }
  }

  // Sync user data to Firestore (backup)
  Future<void> syncUserDataToFirestore(String userId) async {
    try {
      debugPrint('📤 Syncing user data to Firestore for user: $userId');
      
      final bookings = getUserBookings(userId);
      for (final booking in bookings) {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(booking.id)
            .set(booking.toMap(), SetOptions(merge: true));
      }
      
      debugPrint('✅ Synced ${bookings.length} bookings to Firestore');
      
    } catch (e) {
      debugPrint('❌ Error syncing user data to Firestore: $e');
    }
  }

  // Clear all user data (for testing/logout)
  void clearUserData(String userId) {
    _userBookings.remove(userId);
    _userNotifications.remove(userId);
    _userProfiles.remove(userId);
    _userStats.remove(userId);
    notifyListeners();
  }

  // Get all data (for debugging)
  void printAllData() {
    debugPrint('=== MockDatabaseService Data ===');
    debugPrint('Total Users with Bookings: ${_userBookings.length}');
    debugPrint('Total Users with Notifications: ${_userNotifications.length}');
    debugPrint('Total Users with Profiles: ${_userProfiles.length}');
    
    _userBookings.forEach((userId, bookings) {
      debugPrint('User $userId: ${bookings.length} bookings');
    });
  }
}
