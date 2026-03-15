// lib/services/profile_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage_service.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  UserProfile? _currentProfile;
  bool _isLoading = false;
  String? _profileImageBase64;

  UserProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get profileImageBase64 => _profileImageBase64;

  // Initialize profile for user
  Future<void> initializeProfile(String userId, String email, String displayName) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load existing profile
      final existingProfile = await LocalStorageService.loadUserProfile(userId);
      
      if (existingProfile != null) {
        _currentProfile = UserProfile.fromMap(existingProfile);
        debugPrint('✅ Loaded existing profile for user: $userId');
      } else {
        // Create new profile with registration details
        _currentProfile = UserProfile(
          userId: userId,
          email: email,
          displayName: displayName,
          fullName: displayName,
          phoneNumber: '',
          address: '',
          profileImageUrl: '',
          dateOfBirth: null,
          gender: '',
          occupation: '',
          farmSize: '',
          cropTypes: [],
          registrationDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          isVerified: false,
          preferences: ProfilePreferences(),
        );
        
        await saveProfile();
        debugPrint('✅ Created new profile for user: $userId');
      }
      
      // Load profile image if exists
      await _loadProfileImage(userId);
      
    } catch (e) {
      debugPrint('❌ Error initializing profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save profile to local storage
  Future<void> saveProfile() async {
    if (_currentProfile == null) return;

    try {
      // Update the lastUpdated timestamp using copyWith
      _currentProfile = _currentProfile!.copyWith();
      await LocalStorageService.saveUserProfile(
        _currentProfile!.userId,
        _currentProfile!.toMap(),
      );
      
      // Save profile image separately if exists
      if (_profileImageBase64 != null) {
        await _saveProfileImage(_currentProfile!.userId, _profileImageBase64!);
      }
      
      notifyListeners();
      debugPrint('✅ Profile saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving profile: $e');
      throw Exception('Failed to save profile');
    }
  }

  // Update profile fields
  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? occupation,
    String? farmSize,
    List<String>? cropTypes,
  }) async {
    if (_currentProfile == null) return;

    try {
      _currentProfile = _currentProfile!.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        profileImageUrl: profileImageUrl,
        dateOfBirth: dateOfBirth,
        gender: gender,
        occupation: occupation,
        farmSize: farmSize,
        cropTypes: cropTypes,
      );

      await saveProfile();
      debugPrint('✅ Profile updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      throw Exception('Failed to update profile');
    }
  }

  // Upload profile image from device
  Future<String?> uploadProfileImage({bool fromCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        _profileImageBase64 = base64Encode(imageBytes);
        
        // Update profile with local image reference
        if (_currentProfile != null) {
          _currentProfile = _currentProfile!.copyWith(
            profileImageUrl: 'local_image_${DateTime.now().millisecondsSinceEpoch}',
          );
          await saveProfile();
        }
        
        notifyListeners();
        debugPrint('✅ Profile image uploaded successfully');
        return _profileImageBase64;
      }
    } catch (e) {
      debugPrint('❌ Error uploading profile image: $e');
      throw Exception('Failed to upload image');
    }
    return null;
  }

  // Set profile image from URL
  Future<void> setProfileImageUrl(String imageUrl) async {
    if (_currentProfile == null) return;

    try {
      _currentProfile = _currentProfile!.copyWith(profileImageUrl: imageUrl);
      _profileImageBase64 = null; // Clear local image when using URL
      await saveProfile();
      notifyListeners();
      debugPrint('✅ Profile image URL set successfully');
    } catch (e) {
      debugPrint('❌ Error setting profile image URL: $e');
      throw Exception('Failed to set image URL');
    }
  }

  // Get profile image (base64 or URL)
  String? getProfileImageSource() {
    if (_profileImageBase64 != null) {
      return 'data:image/jpeg;base64,$_profileImageBase64';
    }
    return _currentProfile?.profileImageUrl?.isNotEmpty == true 
        ? _currentProfile!.profileImageUrl 
        : null;
  }

  // Private methods
  Future<void> _loadProfileImage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _profileImageBase64 = prefs.getString('profile_image_$userId');
    } catch (e) {
      debugPrint('❌ Error loading profile image: $e');
    }
  }

  Future<void> _saveProfileImage(String userId, String base64Image) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_$userId', base64Image);
    } catch (e) {
      debugPrint('❌ Error saving profile image: $e');
    }
  }

  // Clear profile data
  Future<void> clearProfile() async {
    _currentProfile = null;
    _profileImageBase64 = null;
    notifyListeners();
  }

  // Validate profile completeness
  double getProfileCompleteness() {
    if (_currentProfile == null) return 0.0;

    int completedFields = 0;
    int totalFields = 8;

    if (_currentProfile!.fullName.isNotEmpty) completedFields++;
    if (_currentProfile!.phoneNumber.isNotEmpty) completedFields++;
    if (_currentProfile!.address.isNotEmpty) completedFields++;
    if (_currentProfile!.profileImageUrl.isNotEmpty || _profileImageBase64 != null) completedFields++;
    if (_currentProfile!.dateOfBirth != null) completedFields++;
    if (_currentProfile!.gender.isNotEmpty) completedFields++;
    if (_currentProfile!.occupation.isNotEmpty) completedFields++;
    if (_currentProfile!.farmSize.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }
}

class UserProfile {
  final String userId;
  final String email;
  final String displayName;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String profileImageUrl;
  final DateTime? dateOfBirth;
  final String gender;
  final String occupation;
  final String farmSize;
  final List<String> cropTypes;
  final DateTime registrationDate;
  final DateTime lastUpdated;
  final bool isVerified;
  final ProfilePreferences preferences;

  UserProfile({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.profileImageUrl,
    this.dateOfBirth,
    required this.gender,
    required this.occupation,
    required this.farmSize,
    required this.cropTypes,
    required this.registrationDate,
    required this.lastUpdated,
    required this.isVerified,
    required this.preferences,
  });

  UserProfile copyWith({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? occupation,
    String? farmSize,
    List<String>? cropTypes,
    bool? isVerified,
    ProfilePreferences? preferences,
  }) {
    return UserProfile(
      userId: userId,
      email: email,
      displayName: displayName,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      farmSize: farmSize ?? this.farmSize,
      cropTypes: cropTypes ?? this.cropTypes,
      registrationDate: registrationDate,
      lastUpdated: DateTime.now(),
      isVerified: isVerified ?? this.isVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'occupation': occupation,
      'farmSize': farmSize,
      'cropTypes': cropTypes,
      'registrationDate': registrationDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isVerified': isVerified,
      'preferences': preferences.toMap(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      gender: map['gender'] ?? '',
      occupation: map['occupation'] ?? '',
      farmSize: map['farmSize'] ?? '',
      cropTypes: List<String>.from(map['cropTypes'] ?? []),
      registrationDate: DateTime.parse(map['registrationDate']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      isVerified: map['isVerified'] ?? false,
      preferences: ProfilePreferences.fromMap(map['preferences'] ?? {}),
    );
  }
}

class ProfilePreferences {
  final bool notificationsEnabled;
  final bool emailUpdates;
  final bool smsUpdates;
  final String language;
  final String theme;

  ProfilePreferences({
    this.notificationsEnabled = true,
    this.emailUpdates = true,
    this.smsUpdates = false,
    this.language = 'en',
    this.theme = 'light',
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailUpdates': emailUpdates,
      'smsUpdates': smsUpdates,
      'language': language,
      'theme': theme,
    };
  }

  factory ProfilePreferences.fromMap(Map<String, dynamic> map) {
    return ProfilePreferences(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      emailUpdates: map['emailUpdates'] ?? true,
      smsUpdates: map['smsUpdates'] ?? false,
      language: map['language'] ?? 'en',
      theme: map['theme'] ?? 'light',
    );
  }
}