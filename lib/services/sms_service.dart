// lib/services/sms_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class SMSService {
  // Using Twilio API for SMS (you can replace with any SMS service)
  static const String _twilioAccountSid = 'YOUR_TWILIO_ACCOUNT_SID';
  static const String _twilioAuthToken = 'YOUR_TWILIO_AUTH_TOKEN';
  static const String _twilioPhoneNumber = 'YOUR_TWILIO_PHONE_NUMBER';
  
  // Alternative: Use Fast2SMS for Indian numbers (more affordable)
  static const String _fast2smsApiKey = 'YOUR_FAST2SMS_API_KEY'; // Replace with your actual API key
  
  /// Send SMS using Twilio (International)
  static Future<bool> sendSMSWithTwilio({
    required String to,
    required String message,
  }) async {
    try {
      final basicAuth = 'Basic ${base64.encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'))}';
      
      final response = await http.post(
        Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': to,
          'From': _twilioPhoneNumber,
          'Body': message,
        },
      );
      
      if (response.statusCode == 201) {
        print('✅ SMS sent successfully via Twilio to $to');
        return true;
      } else {
        print('❌ Failed to send SMS via Twilio: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending SMS via Twilio: $e');
      return false;
    }
  }
  
  /// Send SMS using Fast2SMS (India - more affordable)
  static Future<bool> sendSMSWithFast2SMS({
    required String to,
    required String message,
  }) async {
    try {
      // Remove country code if present (Fast2SMS expects 10-digit numbers)
      String phoneNumber = to.replaceAll(RegExp(r'[^0-9]'), '');
      if (phoneNumber.length == 11 && phoneNumber.startsWith('91')) {
        phoneNumber = phoneNumber.substring(2);
      }
      
      final response = await http.post(
        Uri.parse('https://www.fast2sms.com/dev/bulkV2'),
        headers: {
          'authorization': _fast2smsApiKey,
        },
        body: {
          'sender_id': 'FTWSMS',
          'message': message,
          'language': 'english',
          'route': 'v3',
          'numbers': phoneNumber,
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['return'] == true) {
          print('✅ SMS sent successfully via Fast2SMS to $to');
          return true;
        } else {
          print('❌ Failed to send SMS via Fast2SMS: ${responseData['message']}');
          return false;
        }
      } else {
        print('❌ Failed to send SMS via Fast2SMS: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending SMS via Fast2SMS: $e');
      return false;
    }
  }
  
  /// Send booking confirmation SMS
  static Future<bool> sendBookingConfirmationSMS({
    required String farmerName,
    required String farmerPhone,
    required String serviceName,
    required String bookingId,
    required String bookingDate,
    required String providerName,
    required DateTime estimatedArrival,
  }) async {
    final message = _generateBookingMessage(
      farmerName: farmerName,
      serviceName: serviceName,
      bookingId: bookingId,
      bookingDate: bookingDate,
      providerName: providerName,
      estimatedArrival: estimatedArrival,
    );
    
    // Try Fast2SMS first (better for Indian numbers, more affordable)
    bool sent = await sendSMSWithFast2SMS(
      to: farmerPhone,
      message: message,
    );
    
    // Fallback to Twilio if Fast2SMS fails
    if (!sent) {
      sent = await sendSMSWithTwilio(
        to: farmerPhone,
        message: message,
      );
    }
    
    return sent;
  }
  
  /// Generate booking confirmation message
  static String _generateBookingMessage({
    required String farmerName,
    required String serviceName,
    required String bookingId,
    required String bookingDate,
    required String providerName,
    required DateTime estimatedArrival,
  }) {
    final formattedDate = _formatDate(bookingDate);
    final formattedTime = _formatTime(estimatedArrival);
    
    return '''
🌾 AgriCare - Service Booking Confirmed! 🌾

Dear $farmerName,

Your service booking has been confirmed:

📋 Service: $serviceName
🆔 Booking ID: $bookingId
📅 Date: $formattedDate
⏰ Estimated Arrival: $formattedTime
👨‍🌾 Service Provider: $providerName

📍 Our service provider will reach your location soon.
📞 Please keep your phone available for calls.

For any queries, contact: +91XXXXXXXXXX

Thank you for choosing AgriCare!
🌱 Growing Together, Harvesting Success 🌱
    ''';
  }
  
  /// Send service completion SMS
  static Future<bool> sendServiceCompletionSMS({
    required String farmerName,
    required String farmerPhone,
    required String serviceName,
    required String bookingId,
  }) async {
    final message = '''
🌾 AgriCare - Service Completed! 🌾

Dear $farmerName,

Your service has been successfully completed:

📋 Service: $serviceName
🆔 Booking ID: $bookingId
✅ Status: Completed

We hope our service was helpful! 
Please share your feedback to help us improve.

📞 For any follow-up queries: +91XXXXXXXXXX

Thank you for trusting AgriCare!
🌱 Growing Together, Harvesting Success 🌱
    ''';
    
    // Try Fast2SMS first
    bool sent = await sendSMSWithFast2SMS(
      to: farmerPhone,
      message: message,
    );
    
    // Fallback to Twilio
    if (!sent) {
      sent = await sendSMSWithTwilio(
        to: farmerPhone,
        message: message,
      );
    }
    
    return sent;
  }
  
  /// Send provider on the way SMS
  static Future<bool> sendProviderOnWaySMS({
    required String farmerName,
    required String farmerPhone,
    required String providerName,
    required String estimatedTime,
  }) async {
    final message = '''
🌾 AgriCare - Provider On The Way! 🌾

Dear $farmerName,

Good news! Your service provider is on the way:

👨‍🌾 Provider: $providerName
⏰ Estimated Arrival: $estimatedTime
📍 Please be ready at your location

📞 The provider will call you upon arrival.

Thank you for choosing AgriCare!
🌱 Growing Together, Harvesting Success 🌱
    ''';
    
    // Try Fast2SMS first
    bool sent = await sendSMSWithFast2SMS(
      to: farmerPhone,
      message: message,
    );
    
    // Fallback to Twilio
    if (!sent) {
      sent = await sendSMSWithTwilio(
        to: farmerPhone,
        message: message,
      );
    }
    
    return sent;
  }
  
  /// Format date for SMS
  static String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
  
  /// Format time for SMS
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// Send test SMS (for development)
  static Future<bool> sendTestSMS({
    required String to,
    String? customMessage,
  }) async {
    final message = customMessage ?? '''
🧪 AgriCare - Test SMS 🧪

This is a test message from AgriCare SMS service.

If you receive this, SMS integration is working correctly! 🎉

Time: ${DateTime.now().toString()}
    ''';
    
    return await sendSMSWithFast2SMS(
      to: to,
      message: message,
    );
  }
}
