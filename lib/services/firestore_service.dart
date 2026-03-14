// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final String servicesCollection = 'services';
  final String bookingsCollection = 'bookings';

  // Get all services
  Stream<List<Service>> getServices() {
    return _firestore
        .collection(servicesCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _serviceFromFirestore(data);
      }).toList();
    });
  }

  // Get a single service by ID
  Future<Service?> getService(String serviceId) async {
    try {
      final doc = await _firestore.collection(servicesCollection).doc(serviceId).get();
      if (doc.exists) {
        return _serviceFromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting service: $e');
      return null;
    }
  }

  // Add a new service
  Future<void> addService(Service service) async {
    try {
      final docRef = _firestore.collection(servicesCollection).doc();
      await docRef.set(_serviceToMap(service, docRef.id));
    } catch (e) {
      debugPrint('Error adding service: $e');
      rethrow;
    }
  }

  // Update a service
  Future<void> updateService(String serviceId, Service service) async {
    try {
      await _firestore
          .collection(servicesCollection)
          .doc(serviceId)
          .update(_serviceToMap(service, serviceId));
    } catch (e) {
      debugPrint('Error updating service: $e');
      rethrow;
    }
  }

  // Delete a service
  Future<void> deleteService(String serviceId) async {
    try {
      await _firestore.collection(servicesCollection).doc(serviceId).delete();
    } catch (e) {
      debugPrint('Error deleting service: $e');
      rethrow;
    }
  }

  // Convert Service model to Firestore document
  Map<String, dynamic> _serviceToMap(Service service, String docId) {
    return {
      'id': docId,
      'name': service.name,
      'icon': service.icon,
      'description': service.description,
      'subServices': service.subServices
          .map((sub) => {
                'name': sub.name,
                'price': sub.price,
              })
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Convert Firestore document to Service model
  Service _serviceFromFirestore(Map<String, dynamic> data) {
    return Service(
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'assets/icons/default_service.png',
      description: data['description'] ?? '',
      subServices: (data['subServices'] as List<dynamic>?)
              ?.map((sub) => SubService(
                    name: sub['name'] ?? '',
                    price: sub['price'] ?? '0',
                    id: sub['id'], // Include id if available
                  ))
              .toList() ??
          [],
    );
  }
}
