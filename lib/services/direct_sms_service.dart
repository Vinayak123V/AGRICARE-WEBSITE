// lib/services/direct_sms_service.dart

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectSMSService {
  /// Send SMS by opening SMS app with pre-filled message
  static Future<bool> sendSMS({
    required String phone,
    required String message,
  }) async {
    try {
      debugPrint('📱 DirectSMSService: Opening SMS app for $phone');
      debugPrint('📄 Message: $message');

      // Clean phone number
      String cleanPhone = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
      
      // Ensure phone number has country code
      if (!cleanPhone.startsWith('+')) {
        if (cleanPhone.startsWith('91') && cleanPhone.length == 12) {
          cleanPhone = '+$cleanPhone';
        } else if (cleanPhone.length == 10) {
          cleanPhone = '+91$cleanPhone';
        }
      }

      debugPrint('📱 Formatted phone: $cleanPhone');

      // Create SMS URL
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: cleanPhone,
        queryParameters: {'body': message},
      );

      debugPrint('📱 SMS URI: $smsUri');

      // Launch SMS app
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        debugPrint('✅ SMS app opened successfully');
        return true;
      } else {
        debugPrint('❌ Cannot launch SMS app');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error opening SMS app: $e');
      return false;
    }
  }

  /// Send SMS by opening SMS app (same as sendSMS - using url_launcher)
  static Future<bool> sendSMSViaApp({
    required String phone,
    required String message,
  }) async {
    return await sendSMS(phone: phone, message: message);
  }

  /// Check if device can send SMS
  static Future<bool> checkSMSCapability() async {
    try {
      // Check if SMS scheme is supported
      final Uri testSmsUri = Uri(scheme: 'sms', path: '1234567890');
      bool canSend = await canLaunchUrl(testSmsUri);
      debugPrint('📱 SMS capability check: $canSend');
      return canSend;
    } catch (e) {
      debugPrint('⚠️ Error checking SMS capability: $e');
      return true; // Assume available on mobile devices
    }
  }

  /// Send booking confirmation SMS
  static Future<bool> sendBookingConfirmationSMS({
    required String farmerName,
    required String farmerPhone,
    required String serviceName,
    required String bookingId,
    required String bookingDate,
  }) async {
    final shortBookingId = bookingId.length > 8 
        ? bookingId.substring(0, 8).toUpperCase() 
        : bookingId.toUpperCase();

    final message = '''🌾 AgriCare - Booking Confirmation

Dear $farmerName,

Your booking has been successfully completed!

Service: $serviceName
Booking ID: $shortBookingId
Date: $bookingDate

Our service provider will contact you soon.

Thank you for choosing AgriCare!
🌱 Growing Together, Harvesting Success 🌱''';

    return await sendSMS(
      phone: farmerPhone,
      message: message,
    );
  }
}
