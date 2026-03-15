// lib/services/razorpay_backend_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class RazorpayBackendService {
  // Your Razorpay API credentials
  static const String _keyId = 'rzp_test_RpjqLQfGM5jazI';
  static const String _keySecret = '6SG5IGh9N1YydbcTpbMmX9Ty';
  
  // Razorpay API endpoints
  static const String _baseUrl = 'https://api.razorpay.com/v1';
  static const String _ordersEndpoint = '$_baseUrl/orders';
  static const String _paymentsEndpoint = '$_baseUrl/payments';

  /// Create a Razorpay order on the backend
  /// This is required for secure payment processing
  static Future<Map<String, dynamic>?> createOrder({
    required double amount,
    required String currency,
    required String receipt,
    Map<String, dynamic>? notes,
  }) async {
    try {
      debugPrint('🏦 Creating Razorpay order...');
      debugPrint('   Amount: ₹$amount');
      debugPrint('   Currency: $currency');
      debugPrint('   Receipt: $receipt');

      // Convert amount to paise (smallest currency unit)
      final amountInPaise = (amount * 100).toInt();

      // Prepare order data
      final orderData = {
        'amount': amountInPaise,
        'currency': currency,
        'receipt': receipt,
        'notes': notes ?? {},
      };

      // Create authorization header
      final credentials = base64Encode(utf8.encode('$_keyId:$_keySecret'));
      final headers = {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
      };

      debugPrint('📡 Sending request to Razorpay API...');
      
      // Make API request
      final response = await http.post(
        Uri.parse(_ordersEndpoint),
        headers: headers,
        body: jsonEncode(orderData),
      );

      debugPrint('📨 Response status: ${response.statusCode}');
      debugPrint('📨 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final orderResponse = jsonDecode(response.body);
        debugPrint('✅ Order created successfully!');
        debugPrint('   Order ID: ${orderResponse['id']}');
        debugPrint('   Amount: ₹${orderResponse['amount'] / 100}');
        debugPrint('   Status: ${orderResponse['status']}');
        
        return orderResponse;
      } else {
        debugPrint('❌ Failed to create order');
        debugPrint('   Status: ${response.statusCode}');
        debugPrint('   Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception creating order: $e');
      return null;
    }
  }

  /// Verify payment signature for security
  /// This ensures the payment is genuine and not tampered with
  static bool verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    try {
      debugPrint('🔐 Verifying payment signature...');
      debugPrint('   Order ID: $orderId');
      debugPrint('   Payment ID: $paymentId');
      debugPrint('   Signature: $signature');

      // Create the expected signature
      final message = '$orderId|$paymentId';
      final key = utf8.encode(_keySecret);
      final messageBytes = utf8.encode(message);
      
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(messageBytes);
      final expectedSignature = digest.toString();

      debugPrint('   Expected: $expectedSignature');
      debugPrint('   Received: $signature');

      final isValid = expectedSignature == signature;
      debugPrint(isValid ? '✅ Signature verified!' : '❌ Invalid signature!');
      
      return isValid;
    } catch (e) {
      debugPrint('❌ Error verifying signature: $e');
      return false;
    }
  }

  /// Fetch payment details from Razorpay
  static Future<Map<String, dynamic>?> getPaymentDetails(String paymentId) async {
    try {
      debugPrint('📋 Fetching payment details for: $paymentId');

      final credentials = base64Encode(utf8.encode('$_keyId:$_keySecret'));
      final headers = {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$_paymentsEndpoint/$paymentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final paymentData = jsonDecode(response.body);
        debugPrint('✅ Payment details fetched successfully');
        debugPrint('   Status: ${paymentData['status']}');
        debugPrint('   Method: ${paymentData['method']}');
        debugPrint('   Amount: ₹${paymentData['amount'] / 100}');
        
        return paymentData;
      } else {
        debugPrint('❌ Failed to fetch payment details');
        debugPrint('   Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception fetching payment details: $e');
      return null;
    }
  }

  /// Generate a unique receipt ID for the order
  static String generateReceiptId(String bookingId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'AGRI_${bookingId.substring(0, 8)}_${timestamp}_$random';
  }

  /// Create order with booking details
  static Future<Map<String, dynamic>?> createOrderForBooking({
    required String bookingId,
    required double amount,
    required String customerName,
    required String customerPhone,
    required String serviceName,
  }) async {
    final receipt = generateReceiptId(bookingId);
    final notes = {
      'booking_id': bookingId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'service_name': serviceName,
      'app_name': 'AgriCare',
    };

    return await createOrder(
      amount: amount,
      currency: 'INR',
      receipt: receipt,
      notes: notes,
    );
  }

  /// Process refund (if needed)
  static Future<Map<String, dynamic>?> processRefund({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      debugPrint('💰 Processing refund...');
      debugPrint('   Payment ID: $paymentId');
      debugPrint('   Amount: ₹$amount');
      debugPrint('   Reason: ${reason ?? "Not specified"}');

      final refundData = {
        'amount': (amount * 100).toInt(), // Amount in paise
        'speed': 'normal',
        'notes': {
          'reason': reason ?? 'Customer request',
          'processed_by': 'AgriCare App',
        },
      };

      final credentials = base64Encode(utf8.encode('$_keyId:$_keySecret'));
      final headers = {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('$_paymentsEndpoint/$paymentId/refund'),
        headers: headers,
        body: jsonEncode(refundData),
      );

      if (response.statusCode == 200) {
        final refundResponse = jsonDecode(response.body);
        debugPrint('✅ Refund processed successfully!');
        debugPrint('   Refund ID: ${refundResponse['id']}');
        debugPrint('   Status: ${refundResponse['status']}');
        
        return refundResponse;
      } else {
        debugPrint('❌ Failed to process refund');
        debugPrint('   Status: ${response.statusCode}');
        debugPrint('   Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception processing refund: $e');
      return null;
    }
  }
}