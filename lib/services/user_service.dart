// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user type ('farmer', 'vendor', or null)
  static Future<String?> getCurrentUserType() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['userType'] as String?;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }

  /// Check if current user is a vendor
  static Future<bool> isCurrentUserVendor() async {
    final userType = await getCurrentUserType();
    return userType == 'vendor';
  }

  /// Check if current user is a farmer
  static Future<bool> isCurrentUserFarmer() async {
    final userType = await getCurrentUserType();
    return userType == 'farmer';
  }

  /// Get all users of a specific type
  static Future<QuerySnapshot> getUsersByType(String userType) async {
    return await _firestore
        .collection('users')
        .where('userType', isEqualTo: userType)
        .orderBy('createdAt', descending: true)
        .get();
  }

  /// Get all farmers
  static Future<QuerySnapshot> getAllFarmers() async {
    return await getUsersByType('farmer');
  }

  /// Get all vendors
  static Future<QuerySnapshot> getAllVendors() async {
    return await getUsersByType('vendor');
  }

  /// Search users by name, email, or vendor-specific fields
  static Future<QuerySnapshot> searchUsers(String searchTerm) async {
    return await _firestore
        .collection('users')
        .where('searchTerms', arrayContains: searchTerm.toLowerCase())
        .orderBy('createdAt', descending: true)
        .get();
  }

  /// Get vendor by licence number
  static Future<DocumentSnapshot?> getVendorByLicenceNumber(String licenceNumber) async {
    final snapshot = await _firestore
        .collection('users')
        .where('licenceNumber', isEqualTo: licenceNumber)
        .where('userType', isEqualTo: 'vendor')
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    }
    return null;
  }

  /// Get vendor by RC number
  static Future<DocumentSnapshot?> getVendorByRCNumber(String rcNumber) async {
    final snapshot = await _firestore
        .collection('users')
        .where('rcNumber', isEqualTo: rcNumber)
        .where('userType', isEqualTo: 'vendor')
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    }
    return null;
  }

  /// Get user statistics
  static Future<Map<String, int>> getUserStatistics() async {
    final farmersSnapshot = await getAllFarmers();
    final vendorsSnapshot = await getAllVendors();
    
    return {
      'totalFarmers': farmersSnapshot.docs.length,
      'totalVendors': vendorsSnapshot.docs.length,
      'totalUsers': farmersSnapshot.docs.length + vendorsSnapshot.docs.length,
    };
  }

  /// Update user profile
  static Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('users').doc(user.uid).update({
      ...data,
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get user profile by UID
  static Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  /// Get current user profile
  static Future<DocumentSnapshot> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    
    return await getUserProfile(user.uid);
  }

  /// Stream of current user type changes
  static Stream<String?> currentUserTypeStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data()?['userType'] as String?);
  }

  /// Stream of all farmers
  static Stream<QuerySnapshot> farmersStream() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'farmer')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream of all vendors
  static Stream<QuerySnapshot> vendorsStream() {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: 'vendor')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
