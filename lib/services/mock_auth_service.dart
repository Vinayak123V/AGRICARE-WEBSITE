// lib/services/mock_auth_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class MockUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  MockUser({required this.uid, required this.email, this.displayName, this.photoUrl});
}

class MockAuthService extends ChangeNotifier {
  MockUser? _currentUser;
  final Map<String, Map<String, dynamic>> _users = {};
  final StreamController<AuthState> _authStateController = StreamController<AuthState>.broadcast();

  MockUser? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Stream<AuthState> get authStateChanges => _authStateController.stream;

  // Constructor to add demo users
  MockAuthService() {
    _initializeDemoUsers();
    _emitAuthState();
  }

  void _emitAuthState() {
    _authStateController.add(AuthState(
      isAuthenticated: isAuthenticated,
      user: _currentUser?.email,
    ));
  }

  void _initializeDemoUsers() {
    // Add demo farmer user
    _users['farmer@demo.com'] = {
      'uid': 'demo_farmer_001',
      'email': 'farmer@demo.com',
      'password': 'farmer123',
      'name': 'Demo Farmer',
      'userType': 'farmer',
    };

    // Add demo vendor user
    _users['vendor@demo.com'] = {
      'uid': 'demo_vendor_001',
      'email': 'vendor@demo.com',
      'password': 'vendor123',
      'name': 'Demo Vendor',
      'userType': 'vendor',
    };
    
    debugPrint('✅ Demo users initialized:');
    debugPrint('   Farmer: farmer@demo.com / farmer123');
    debugPrint('   Vendor: vendor@demo.com / vendor123');
  }

  // Register new user
  Future<MockUser> register({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay

    // Check if user already exists
    if (_users.containsKey(email.toLowerCase())) {
      throw Exception('email-already-in-use');
    }

    // Validate password
    if (password.length < 6) {
      throw Exception('weak-password');
    }

    // Create user
    final uid = 'mock_${DateTime.now().millisecondsSinceEpoch}';
    _users[email.toLowerCase()] = {
      'uid': uid,
      'email': email,
      'password': password,
      'name': name,
      'userType': userType,
    };

    _currentUser = MockUser(
      uid: uid,
      email: email,
      displayName: name,
      photoUrl: null,
    );

    notifyListeners();
    return _currentUser!;
  }

  // Login user
  Future<MockUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay

    final userEmail = email.toLowerCase();

    // Check if user exists
    if (!_users.containsKey(userEmail)) {
      throw Exception('user-not-found');
    }

    // Check password
    if (_users[userEmail]!['password'] != password) {
      throw Exception('wrong-password');
    }

    // Login successful
    final userData = _users[userEmail]!;
    _currentUser = MockUser(
      uid: userData['uid'],
      email: userData['email'],
      displayName: userData['name'],
      photoUrl: null,
    );

    notifyListeners();
    return _currentUser!;
  }

  // Logout
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    notifyListeners();
    _emitAuthState();
  }

  // Get user data
  Map<String, dynamic>? getUserData(String email) {
    return _users[email.toLowerCase()];
  }

  // Update display name
  Future<void> updateDisplayName(String name) async {
    if (_currentUser != null) {
      _currentUser = MockUser(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: name,
        photoUrl: _currentUser!.photoUrl,
      );
      notifyListeners();
      _emitAuthState();
    }
  }

  // Update profile photo URL (demo only, stored in memory)
  Future<void> updatePhotoUrl(String url) async {
    if (_currentUser != null) {
      _currentUser = MockUser(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: _currentUser!.displayName,
        photoUrl: url,
      );
      notifyListeners();
      _emitAuthState();
    }
  }
}
