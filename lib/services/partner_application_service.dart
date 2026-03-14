// lib/services/partner_application_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PartnerApplication {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String experience;
  final List<String> services;
  final String vehicleType;
  final String vehicleNumber;
  final String bankAccountNumber;
  final String ifscCode;
  final String accountHolderName;
  final String aadharNumber;
  final String panNumber;
  final String referralCode;
  final String additionalInfo;
  final DateTime applicationDate;
  final String status; // pending, approved, rejected
  final String? userId;

  PartnerApplication({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.experience,
    required this.services,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.accountHolderName,
    required this.aadharNumber,
    required this.panNumber,
    required this.referralCode,
    required this.additionalInfo,
    required this.applicationDate,
    required this.status,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'experience': experience,
      'services': services,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'accountHolderName': accountHolderName,
      'aadharNumber': aadharNumber,
      'panNumber': panNumber,
      'referralCode': referralCode,
      'additionalInfo': additionalInfo,
      'applicationDate': applicationDate.toIso8601String(),
      'status': status,
      'userId': userId,
    };
  }

  factory PartnerApplication.fromMap(Map<String, dynamic> map) {
    return PartnerApplication(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      experience: map['experience'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      vehicleType: map['vehicleType'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      bankAccountNumber: map['bankAccountNumber'] ?? '',
      ifscCode: map['ifscCode'] ?? '',
      accountHolderName: map['accountHolderName'] ?? '',
      aadharNumber: map['aadharNumber'] ?? '',
      panNumber: map['panNumber'] ?? '',
      referralCode: map['referralCode'] ?? '',
      additionalInfo: map['additionalInfo'] ?? '',
      applicationDate: DateTime.parse(map['applicationDate']),
      status: map['status'] ?? 'pending',
      userId: map['userId'],
    );
  }
}

class PartnerApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'partner_applications';

  /// Submit a new partner application
  Future<String> submitApplication(PartnerApplication application) async {
    try {
      debugPrint('📝 Submitting partner application for: ${application.fullName}');
      
      final docRef = await _firestore.collection(_collection).add(application.toMap());
      
      debugPrint('✅ Partner application submitted successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error submitting partner application: $e');
      rethrow;
    }
  }

  /// Get all partner applications (for admin)
  Future<List<PartnerApplication>> getAllApplications() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('applicationDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PartnerApplication.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching partner applications: $e');
      return [];
    }
  }

  /// Get applications by user ID
  Future<List<PartnerApplication>> getApplicationsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('applicationDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PartnerApplication.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching user applications: $e');
      return [];
    }
  }

  /// Update application status (for admin)
  Future<void> updateApplicationStatus(String applicationId, String status) async {
    try {
      await _firestore.collection(_collection).doc(applicationId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      debugPrint('✅ Application status updated: $applicationId -> $status');
    } catch (e) {
      debugPrint('❌ Error updating application status: $e');
      rethrow;
    }
  }

  /// Check if user has already applied
  Future<bool> hasUserApplied(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking user application: $e');
      return false;
    }
  }

  /// Get application by ID
  Future<PartnerApplication?> getApplicationById(String applicationId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(applicationId).get();
      
      if (doc.exists) {
        return PartnerApplication.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching application: $e');
      return null;
    }
  }
}