// lib/services/razorpay_service.dart

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'razorpay_backend_service.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;
  Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment Success: ${response.paymentId}');
    if (onSuccess != null) {
      onSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Error: ${response.code} - ${response.message}');
    if (onFailure != null) {
      onFailure!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💳 External Wallet: ${response.walletName}');
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  /// Open Razorpay checkout with proper backend integration
  Future<void> openCheckout({
    required double amount,
    required String name,
    required String phone,
    required String email,
    required String description,
    required String bookingId,
    required String serviceName,
  }) async {
    debugPrint('🚀 Opening Razorpay checkout...');
    debugPrint('   Amount: ₹$amount (${(amount * 100).toInt()} paise)');
    debugPrint('   Name: $name');
    debugPrint('   Phone: $phone');
    debugPrint('   Email: $email');
    debugPrint('   Description: $description');
    debugPrint('   Booking ID: $bookingId');
    debugPrint('   Platform: ${kIsWeb ? "Web" : "Mobile"}');

    // Check if running on web
    if (kIsWeb) {
      debugPrint('⚠️ Razorpay does not work on web platform!');
      debugPrint('📱 Please test on Android or iOS device/emulator');
      
      // Simulate payment error for web
      if (onFailure != null) {
        onFailure!(PaymentFailureResponse(
          0,
          'Razorpay is not supported on web. Please test on Android/iOS device.',
          null,
        ));
      }
      return;
    }

    try {
      // Step 1: Create order on backend for security
      debugPrint('🏦 Creating secure order on backend...');
      final orderResponse = await RazorpayBackendService.createOrderForBooking(
        bookingId: bookingId,
        amount: amount,
        customerName: name,
        customerPhone: phone,
        serviceName: serviceName,
      );

      if (orderResponse == null) {
        debugPrint('❌ Failed to create order on backend');
        if (onFailure != null) {
          onFailure!(PaymentFailureResponse(
            1,
            'Failed to create payment order. Please try again.',
            null,
          ));
        }
        return;
      }

      final razorpayOrderId = orderResponse['id'];
      debugPrint('✅ Backend order created: $razorpayOrderId');

      // Step 2: Open Razorpay checkout with the order ID
      var options = {
        'key': 'rzp_test_RpjqLQfGM5jazI', // Your actual Razorpay test key
        'amount': orderResponse['amount'], // Amount from backend (in paise)
        'currency': orderResponse['currency'],
        'name': 'AgriCare - Agricultural Services',
        'description': description,
        'order_id': razorpayOrderId, // Secure order ID from backend
        'prefill': {
          'contact': phone,
          'email': email,
          'name': name,
        },
        'theme': {
          'color': '#10B981', // AgriCare green color
        },
        'modal': {
          'ondismiss': () {
            debugPrint('❌ Payment cancelled by user');
          }
        },
        'notes': {
          'booking_id': bookingId,
          'service_name': serviceName,
          'app_name': 'AgriCare',
        }
      };

      debugPrint('✅ Opening Razorpay with secure order...');
      _razorpay.open(options);
      debugPrint('✅ Razorpay.open() called successfully');
      
    } catch (e) {
      debugPrint('❌ Error in payment process: $e');
      if (onFailure != null) {
        onFailure!(PaymentFailureResponse(
          1,
          'Payment initialization failed: $e',
          null,
        ));
      }
    }
  }

  /// Verify payment after successful payment
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    debugPrint('🔐 Verifying payment...');
    
    // Verify signature for security
    final isValid = RazorpayBackendService.verifyPaymentSignature(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
    );

    if (isValid) {
      debugPrint('✅ Payment verification successful!');
      
      // Optionally fetch payment details for additional verification
      final paymentDetails = await RazorpayBackendService.getPaymentDetails(paymentId);
      if (paymentDetails != null) {
        debugPrint('💳 Payment Method: ${paymentDetails['method']}');
        debugPrint('💰 Amount Paid: ₹${paymentDetails['amount'] / 100}');
        debugPrint('📅 Payment Date: ${paymentDetails['created_at']}');
      }
      
      return true;
    } else {
      debugPrint('❌ Payment verification failed!');
      return false;
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
