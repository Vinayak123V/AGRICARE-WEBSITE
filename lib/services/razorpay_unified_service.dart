// lib/services/razorpay_unified_service.dart

import 'package:flutter/foundation.dart';
import 'razorpay_service.dart';
import 'razorpay_web_service.dart';

class RazorpayUnifiedService {
  late RazorpayService? _mobileService;
  late RazorpayWebService? _webService;
  
  Function(dynamic)? onSuccess;
  Function(dynamic)? onFailure;
  Function(dynamic)? onExternalWallet;

  RazorpayUnifiedService() {
    if (kIsWeb) {
      debugPrint('🌐 Initializing Razorpay for Web');
      _webService = RazorpayWebService();
      _webService!.initialize();
      _webService!.onSuccess = (response) {
        debugPrint('✅ Web payment success');
        if (onSuccess != null) {
          onSuccess!(response);
        }
      };
      _webService!.onFailure = (response) {
        debugPrint('❌ Web payment failure');
        if (onFailure != null) {
          onFailure!(response);
        }
      };
      _mobileService = null;
    } else {
      debugPrint('📱 Initializing Razorpay for Mobile');
      _mobileService = RazorpayService();
      _mobileService!.onSuccess = (response) {
        debugPrint('✅ Mobile payment success');
        if (onSuccess != null) {
          onSuccess!(response);
        }
      };
      _mobileService!.onFailure = (response) {
        debugPrint('❌ Mobile payment failure');
        if (onFailure != null) {
          onFailure!(response);
        }
      };
      _mobileService!.onExternalWallet = (response) {
        debugPrint('💳 External wallet selected');
        if (onExternalWallet != null) {
          onExternalWallet!(response);
        }
      };
      _webService = null;
    }
  }

  /// Open Razorpay checkout (works on both web and mobile)
  Future<void> openCheckout({
    required double amount,
    required String name,
    required String phone,
    required String email,
    required String description,
    required String bookingId,
    required String serviceName,
  }) async {
    debugPrint('🚀 Opening unified Razorpay checkout...');
    debugPrint('   Platform: ${kIsWeb ? "Web Browser" : "Mobile App"}');
    debugPrint('   Amount: ₹$amount');

    if (kIsWeb && _webService != null) {
      await _webService!.openCheckout(
        amount: amount,
        name: name,
        phone: phone,
        email: email,
        description: description,
        bookingId: bookingId,
        serviceName: serviceName,
      );
    } else if (!kIsWeb && _mobileService != null) {
      await _mobileService!.openCheckout(
        amount: amount,
        name: name,
        phone: phone,
        email: email,
        description: description,
        bookingId: bookingId,
        serviceName: serviceName,
      );
    } else {
      debugPrint('❌ No appropriate service available');
      if (onFailure != null) {
        onFailure!({
          'code': 1,
          'description': 'Payment service not available for this platform',
        });
      }
    }
  }

  /// Verify payment (works on both web and mobile)
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    debugPrint('🔐 Verifying payment on ${kIsWeb ? "web" : "mobile"}...');

    if (kIsWeb && _webService != null) {
      return await _webService!.verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
    } else if (!kIsWeb && _mobileService != null) {
      return await _mobileService!.verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
    }

    debugPrint('❌ No verification service available');
    return false;
  }

  /// Get platform info
  String getPlatformInfo() {
    return kIsWeb ? 'Web Browser (Chrome/Firefox/Safari)' : 'Mobile App (Android/iOS)';
  }

  /// Check if platform supports Razorpay
  bool isPlatformSupported() {
    return true; // Both web and mobile are now supported
  }

  void dispose() {
    if (_mobileService != null) {
      _mobileService!.dispose();
    }
    // Web service doesn't need disposal
  }
}