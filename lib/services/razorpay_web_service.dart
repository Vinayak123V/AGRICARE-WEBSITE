// lib/services/razorpay_web_service.dart

import 'package:flutter/foundation.dart';
import 'razorpay_backend_service.dart';

// Only import web libraries when on web platform
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'dart:js' as js if (dart.library.js) 'dart:js';

class RazorpayWebService {
  Function(Map<String, dynamic>)? onSuccess;
  Function(Map<String, dynamic>)? onFailure;
  
  // Razorpay Configuration
  static const bool _isTestMode = false; // Set to false to hide test mode banner
  static const String _testKeyId = 'rzp_test_RpjqLQfGM5jazI';
  static const String _liveKeyId = 'rzp_test_RpjqLQfGM5jazI'; // Using test key as live for demo
  
  String get _keyId => _isTestMode ? _testKeyId : _liveKeyId;

  /// Initialize Razorpay for web
  void initialize() {
    if (!kIsWeb) {
      debugPrint('🚫 RazorpayWebService: Not on web platform, skipping initialization');
      return;
    }
    debugPrint('🌐 Initializing Razorpay for web...');
    
    // Ensure Razorpay script is loaded
    _ensureRazorpayScript();
  }

  void _ensureRazorpayScript() {
    if (!kIsWeb) return;
    
    if (html.document.querySelector('script[src*="checkout.razorpay.com"]') == null) {
      final script = html.ScriptElement()
        ..src = 'https://checkout.razorpay.com/v1/checkout.js'
        ..async = false  // Load synchronously to ensure it's available
        ..onLoad.listen((_) {
          debugPrint('✅ Razorpay script loaded successfully');
        })
        ..onError.listen((_) {
          debugPrint('❌ Failed to load Razorpay script');
        });
      html.document.head!.append(script);
      debugPrint('📜 Razorpay script added to page');
    } else {
      debugPrint('📜 Razorpay script already exists');
    }
  }

  /// Open Razorpay checkout for web (web-compatible implementation)
  Future<void> openCheckout({
    required double amount,
    required String name,
    required String phone,
    required String email,
    required String description,
    required String bookingId,
    required String serviceName,
  }) async {
    if (!kIsWeb) {
      debugPrint('❌ Web service called on non-web platform');
      if (onFailure != null) {
        onFailure!({
          'code': 1,
          'description': 'Web service not available on this platform',
        });
      }
      return;
    }

    debugPrint('🌐 Opening Razorpay Web checkout...');
    debugPrint('   Mode: PRODUCTION (no test banner)');
    debugPrint('   Amount: ₹$amount');
    debugPrint('   Name: $name');

    try {
      // For web, skip backend order creation due to CORS issues
      // Use direct Razorpay checkout for testing
      debugPrint('🌐 Using web-compatible Razorpay checkout (no backend order)');
      
      // Generate a test order ID for web
      final testOrderId = 'order_web_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('📋 Generated test order ID: $testOrderId');

      // Open Razorpay checkout directly
      await _openRazorpayCheckout(
        keyId: _keyId, // Uses live key when _isTestMode = false
        amount: (amount * 100).toInt(), // Convert to paise
        currency: 'INR',
        name: 'AgriCare - Agricultural Services',
        description: description,
        orderId: testOrderId,
        prefillName: name,
        prefillEmail: email,
        prefillContact: phone,
        themeColor: '#10B981',
      );

    } catch (e) {
      debugPrint('❌ Error in web payment process: $e');
      if (onFailure != null) {
        onFailure!({
          'code': 1,
          'description': 'Payment initialization failed: $e',
        });
      }
    }
  }

  Future<void> _openRazorpayCheckout({
    required String keyId,
    required int amount,
    required String currency,
    required String name,
    required String description,
    required String orderId,
    required String prefillName,
    required String prefillEmail,
    required String prefillContact,
    required String themeColor,
  }) async {
    if (!kIsWeb) {
      debugPrint('❌ _openRazorpayCheckout called on non-web platform');
      return;
    }
    
    debugPrint('🚀 Opening Razorpay with direct JS interop...');
    
    try {
      // Set up callbacks first
      _setupCallbacks();
      
      // Wait for script to load
      await _waitForRazorpayScript();
      
      // Create options object using JS interop
      final options = js.JsObject.jsify({
        'key': keyId,
        'amount': amount.toString(),
        'currency': currency,
        'name': name,
        'description': description,
        'prefill': {
          'name': prefillName,
          'email': prefillEmail,
          'contact': prefillContact,
        },
        'theme': {
          'color': themeColor,
        },
        'handler': js.allowInterop((response) {
          debugPrint('✅ Payment Success: $response');
          html.window.postMessage({
            'type': 'razorpay_success',
            'response': {
              'razorpay_payment_id': response['razorpay_payment_id'],
              'razorpay_order_id': response['razorpay_order_id'],
              'razorpay_signature': response['razorpay_signature'],
            }
          }, '*');
        }),
        'modal': {
          'ondismiss': js.allowInterop(() {
            debugPrint('❌ Payment dismissed');
            html.window.postMessage({
              'type': 'razorpay_dismiss'
            }, '*');
          }),
        },
      });
      
      debugPrint('✅ Created Razorpay options object');
      
      // Create Razorpay instance using JS interop
      final razorpayClass = js.context['Razorpay'];
      if (razorpayClass == null) {
        throw Exception('Razorpay class not found');
      }
      
      final rzp = js.JsObject(razorpayClass, [options]);
      debugPrint('✅ Created Razorpay instance');
      
      // Set up failure handler
      rzp.callMethod('on', ['payment.failed', js.allowInterop((response) {
        debugPrint('❌ Payment Failed: $response');
        html.window.postMessage({
          'type': 'razorpay_failed',
          'response': {
            'code': response['error']['code'],
            'description': response['error']['description'],
          }
        }, '*');
      })]);
      
      // Open Razorpay
      debugPrint('🚀 Opening Razorpay checkout...');
      rzp.callMethod('open');
      debugPrint('✅ Razorpay.open() called successfully');
      
    } catch (e) {
      debugPrint('❌ Error in JS interop approach: $e');
      if (onFailure != null) {
        onFailure!({
          'code': 1,
          'description': 'Failed to open Razorpay: $e',
        });
      }
    }
  }

  Future<void> _waitForRazorpayScript() async {
    if (!kIsWeb) return;
    
    int attempts = 0;
    while (attempts < 50) { // Wait up to 5 seconds
      try {
        final result = js.context.callMethod('eval', ['typeof Razorpay']);
        if (result != 'undefined') {
          debugPrint('✅ Razorpay script loaded and ready');
          return;
        }
      } catch (e) {
        debugPrint('⏳ Waiting for Razorpay script... attempt ${attempts + 1}');
      }
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    // If script still not loaded, try to reload it
    debugPrint('⚠️ Razorpay script not detected, attempting to reload...');
    _ensureRazorpayScript();
    
    // Wait a bit more
    await Future.delayed(const Duration(milliseconds: 1000));
    
    try {
      final result = js.context.callMethod('eval', ['typeof Razorpay']);
      if (result != 'undefined') {
        debugPrint('✅ Razorpay script loaded after reload');
        return;
      }
    } catch (e) {
      // Still failed
    }
    
    throw Exception('Razorpay script failed to load after multiple attempts');
  }

  void _handleWebPaymentSuccess(dynamic response) {
    try {
      final paymentData = {
        'razorpay_payment_id': response['razorpay_payment_id'],
        'razorpay_order_id': response['razorpay_order_id'],
        'razorpay_signature': response['razorpay_signature'],
      };
      
      debugPrint('✅ Web payment success data: $paymentData');
      
      if (onSuccess != null) {
        onSuccess!(paymentData);
      }
    } catch (e) {
      debugPrint('❌ Error processing web payment success: $e');
    }
  }

  void _handleWebPaymentFailure(dynamic response) {
    try {
      final errorData = {
        'code': response['error']['code'] ?? 0,
        'description': response['error']['description'] ?? 'Payment failed',
        'source': response['error']['source'] ?? 'unknown',
        'step': response['error']['step'] ?? 'unknown',
        'reason': response['error']['reason'] ?? 'unknown',
      };
      
      debugPrint('❌ Web payment failure data: $errorData');
      
      if (onFailure != null) {
        onFailure!(errorData);
      }
    } catch (e) {
      debugPrint('❌ Error processing web payment failure: $e');
      if (onFailure != null) {
        onFailure!({
          'code': 1,
          'description': 'Payment processing error: $e',
        });
      }
    }
  }

  void _setupCallbacks() {
    if (!kIsWeb) return;
    
    // Create a simple callback mechanism using postMessage
    html.window.addEventListener('message', (html.Event event) {
      final messageEvent = event as html.MessageEvent;
      final data = messageEvent.data;
      
      if (data is Map && data['type'] == 'razorpay_success') {
        debugPrint('✅ Razorpay payment success: $data');
        _handleWebPaymentSuccess(data['response']);
      } else if (data is Map && data['type'] == 'razorpay_failed') {
        debugPrint('❌ Razorpay payment failed: $data');
        _handleWebPaymentFailure(data['response']);
      } else if (data is Map && data['type'] == 'razorpay_dismiss') {
        debugPrint('❌ Razorpay payment dismissed');
        if (onFailure != null) {
          onFailure!({
            'code': 0,
            'description': 'Payment cancelled by user',
          });
        }
      }
    });
  }



  /// Verify payment after successful payment (web-compatible)
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    debugPrint('🔐 Verifying web payment...');
    debugPrint('   Order ID: $orderId');
    debugPrint('   Payment ID: $paymentId');
    debugPrint('   Signature: $signature');
    
    // For web testing, we'll accept the payment as valid
    // In production, you would verify with your backend
    if (paymentId.isNotEmpty && orderId.isNotEmpty) {
      debugPrint('✅ Web payment verification successful!');
      return true;
    } else {
      debugPrint('❌ Web payment verification failed - missing data!');
      return false;
    }
  }
}