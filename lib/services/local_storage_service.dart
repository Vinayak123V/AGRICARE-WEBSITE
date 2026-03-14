// lib/services/local_storage_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mock_database_service.dart';

class LocalStorageService {
  static const String _bookingsKey = 'user_bookings';
  static const String _notificationsKey = 'user_notifications';
  static const String _userProfileKey = 'user_profile';

  // Save bookings to local storage
  static Future<void> saveBookings(String userId, List<Booking> bookings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = bookings.map((booking) => booking.toMap()).toList();
      final key = '${_bookingsKey}_$userId';
      await prefs.setString(key, jsonEncode(bookingsJson));
      debugPrint('✅ Saved ${bookings.length} bookings to local storage for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving bookings to local storage: $e');
    }
  }

  // Load bookings from local storage
  static Future<List<Booking>> loadBookings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_bookingsKey}_$userId';
      final bookingsString = prefs.getString(key);
      
      if (bookingsString != null) {
        final List<dynamic> bookingsJson = jsonDecode(bookingsString);
        final bookings = bookingsJson.map((json) => Booking.fromMap(json)).toList();
        debugPrint('✅ Loaded ${bookings.length} bookings from local storage for user: $userId');
        return bookings;
      }
    } catch (e) {
      debugPrint('❌ Error loading bookings from local storage: $e');
    }
    return [];
  }

  // Save user profile to local storage
  static Future<void> saveUserProfile(String userId, Map<String, dynamic> profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_userProfileKey}_$userId';
      await prefs.setString(key, jsonEncode(profile));
      debugPrint('✅ Saved user profile to local storage for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving user profile to local storage: $e');
    }
  }

  // Load user profile from local storage
  static Future<Map<String, dynamic>?> loadUserProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_userProfileKey}_$userId';
      final profileString = prefs.getString(key);
      
      if (profileString != null) {
        final profile = jsonDecode(profileString) as Map<String, dynamic>;
        debugPrint('✅ Loaded user profile from local storage for user: $userId');
        return profile;
      }
    } catch (e) {
      debugPrint('❌ Error loading user profile from local storage: $e');
    }
    return null;
  }

  // Clear all data for a user
  static Future<void> clearUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_bookingsKey}_$userId');
      await prefs.remove('${_notificationsKey}_$userId');
      await prefs.remove('${_userProfileKey}_$userId');
      debugPrint('✅ Cleared local storage data for user: $userId');
    } catch (e) {
      debugPrint('❌ Error clearing local storage data: $e');
    }
  }

  // Save app settings
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', jsonEncode(settings));
      debugPrint('✅ Saved app settings to local storage');
    } catch (e) {
      debugPrint('❌ Error saving app settings: $e');
    }
  }

  // Load app settings
  static Future<Map<String, dynamic>> loadAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString('app_settings');
      
      if (settingsString != null) {
        final settings = jsonDecode(settingsString) as Map<String, dynamic>;
        debugPrint('✅ Loaded app settings from local storage');
        return settings;
      }
    } catch (e) {
      debugPrint('❌ Error loading app settings: $e');
    }
    return {};
  }
}