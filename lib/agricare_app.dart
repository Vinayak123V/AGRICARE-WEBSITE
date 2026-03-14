// lib/agricare_app.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_functions/cloud_functions.dart';

// Models
import 'models/models.dart';
import 'models/live_tracking_models.dart';

// Data
import 'data/services_data.dart';

// UI & widgets
import 'widgets/ui/header.dart';
import 'widgets/service/service_grid.dart';
import 'widgets/ui/notification_widget.dart';
import 'widgets/service/service_modal.dart';
import 'widgets/ui/app_drawer.dart';
import 'widgets/services/weather_forecast.dart';
import 'widgets/auth/mock_auth_screen.dart';
import 'widgets/user/user_bookings_screen.dart';
import 'widgets/ui/footer.dart';
import 'widgets/ui/language_switcher.dart';
import 'widgets/ui/navigation_bar.dart' as ui_nav;
import 'widgets/feedback/public_feedback_section.dart';
import 'widgets/service/provider_list_section.dart';
import 'widgets/booking/booking_location_map.dart';
import 'widgets/tracking/live_tracking_map.dart';
import 'widgets/service/feedback_section.dart';
import 'widgets/auth/firebase_auth_screen.dart';
import 'widgets/pages/about_page.dart';
import 'widgets/pages/services_page.dart';
import 'widgets/pages/feedback_page.dart';
import 'widgets/pages/partner_page.dart';
import 'widgets/pages/contact_page.dart';
import 'widgets/pages/edit_profile_page.dart';
import 'widgets/booking/service_detail_screen.dart';
import 'widgets/services/ai_crop_manager_form.dart';
import 'widgets/chat/support_chat_screen.dart';

// Services
import 'services/mock_auth_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/mock_database_service.dart';
import 'services/language_provider.dart';
import 'services/app_localizations.dart';
import 'services/firebase_sms_service.dart';
import 'services/live_tracking_service.dart';
import 'services/direct_sms_service.dart';
import 'services/razorpay_unified_service.dart';

// Razorpay
import 'package:razorpay_flutter/razorpay_flutter.dart';

// -----------------------------------------------
// Top-level enum (must be outside classes)
// -----------------------------------------------
enum PaymentMethod { qr, upi, cod }

class AgriCareApp extends StatefulWidget {
  final bool useFirebaseAuth;

  const AgriCareApp({super.key, this.useFirebaseAuth = false});

  @override
  State<AgriCareApp> createState() => _AgriCareAppState();
}

class _AgriCareAppState extends State<AgriCareApp> {
  late final dynamic _authService;
  final MockDatabaseService _databaseService = MockDatabaseService();
  final LanguageProvider _languageProvider = LanguageProvider();

  @override
  void initState() {
    super.initState();
    if (widget.useFirebaseAuth) {
      _authService = FirebaseAuthService();
      debugPrint('✅ Using Firebase Authentication Service');
    } else {
      _authService = MockAuthService();
      debugPrint('✅ Using Mock Authentication Service');
    }
    _authService.addListener(_onAuthChanged);
    _languageProvider.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    _languageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriCare',
      debugShowCheckedModeBanner: false,
      locale: _languageProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageProvider.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF1FDF0),
      ),
      home: widget.useFirebaseAuth
          ? StreamBuilder<AuthState>(
              stream: (_authService as FirebaseAuthService).authStateChanges,
              initialData: AuthState(isAuthenticated: false, user: null),
              builder: (context, snapshot) {
                final authState =
                    snapshot.data ?? AuthState(isAuthenticated: false, user: null);

                debugPrint(
                    '🔐 Firebase auth state: isAuthenticated=${authState.isAuthenticated}, user=${authState.user}');

                if (authState.isAuthenticated) {
                  return AgriCareHome(
                    authService: _authService,
                    databaseService: _databaseService,
                    languageProvider: _languageProvider,
                  );
                } else {
                  return FirebaseAuthScreen(
                    authService: _authService as FirebaseAuthService,
                    showNotification: (message, [type = 'info']) {
                      debugPrint('[$type] $message');
                    },
                  );
                }
              },
            )
          : (_authService.isAuthenticated
              ? AgriCareHome(
                  authService: _authService,
                  databaseService: _databaseService,
                  languageProvider: _languageProvider,
                )
              : MockAuthScreen(
                  authService: _authService as MockAuthService,
                  showNotification: (message, [type = 'info']) {
                    debugPrint('[$type] $message');
                  },
                )),
    );
  }
}

class AgriCareHome extends StatefulWidget {
  final dynamic authService;
  final MockDatabaseService databaseService;
  final LanguageProvider languageProvider;

  const AgriCareHome({
    super.key,
    required this.authService,
    required this.databaseService,
    required this.languageProvider,
  });

  @override
  State<AgriCareHome> createState() => _AgriCareHomeState();
}

class _AgriCareHomeState extends State<AgriCareHome> {
  Service? selectedService;
  Map<String, String> bookingDetails = {
    'name': '',
    'phone': '',
    'address': '',
    'date': '',
  };
  NotificationState notification = NotificationState();
  String _currentPage = 'home';
  bool _isBooking = false;

  final LiveTrackingService _liveTrackingService = LiveTrackingService();
  late RazorpayUnifiedService _razorpayService;

  String get userName {
    final user = widget.authService.currentUser;
    if (user == null) return "Guest";

    if (user is MockUser) {
      return user.displayName ?? user.email?.split('@').first ?? "Guest";
    } else {
      return user.displayName ?? user.email?.split('@').first ?? "Guest";
    }
  }

  String get userEmail {
    final user = widget.authService.currentUser;
    if (user == null) return "guest@agricare.com";

    if (user is MockUser) {
      return user.email;
    } else {
      return user.email ?? "guest@agricare.com";
    }
  }

  String get userId {
    final user = widget.authService.currentUser;
    if (user == null) return "";

    if (user is MockUser) {
      return user.uid;
    } else {
      return user.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.authService.addListener(_onAuthChanged);
    _razorpayService = RazorpayUnifiedService();
    _setupRazorpay();
    _loadUserDataIfAuthenticated();
  }

  void _loadUserDataIfAuthenticated() {
    if (widget.authService.isAuthenticated && userId.isNotEmpty) {
      _loadUserPersistentData();
    }
  }

  Future<void> _loadUserPersistentData() async {
    try {
      debugPrint('📥 Loading persistent data for user: $userId');
      await widget.databaseService.loadUserDataFromFirestore(userId);
      if (mounted) {
        setState(() {}); // Refresh UI with loaded data
      }
      debugPrint('✅ User data loaded successfully');
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
    }
  }

  Map<String, int> _getUserBookingStats() {
    if (userId.isEmpty) {
      return {'total': 0, 'pending': 0, 'completed': 0, 'cancelled': 0};
    }
    return widget.databaseService.getUserBookingStats(userId);
  }

  @override
  void dispose() {
    widget.authService.removeListener(_onAuthChanged);
    _razorpayService.dispose();
    super.dispose();
  }

  void _setupRazorpay() {
    _razorpayService.onSuccess = (dynamic response) async {
      debugPrint('✅ Payment Success Response: $response');
      
      String? paymentId;
      String? orderId;
      String? signature;
      
      // Handle both mobile and web responses
      if (kIsWeb) {
        // Web response format
        paymentId = response['razorpay_payment_id'];
        orderId = response['razorpay_order_id'];
        signature = response['razorpay_signature'];
      } else {
        // Mobile response format
        paymentId = response.paymentId;
        orderId = response.orderId;
        signature = response.signature;
      }

      debugPrint('   Payment ID: $paymentId');
      debugPrint('   Order ID: $orderId');
      debugPrint('   Signature: $signature');

      // Verify payment signature for security
      if (orderId != null && signature != null && paymentId != null) {
        final isVerified = await _razorpayService.verifyPayment(
          orderId: orderId,
          paymentId: paymentId,
          signature: signature,
        );

        if (isVerified) {
          showNotification(
            '✅ Payment successful and verified! Payment ID: $paymentId',
            'success',
          );
          debugPrint('✅ Payment verified successfully!');
          
          // Auto-close all dialogs and return to home after successful payment
          _autoCloseAfterPaymentSuccess();
          
        } else {
          showNotification(
            '⚠️ Payment received but verification failed. Please contact support.',
            'error',
          );
          debugPrint('❌ Payment verification failed!');
        }
      } else {
        showNotification(
          '✅ Payment successful! Payment ID: $paymentId',
          'success',
        );
        debugPrint('⚠️ Payment successful but missing verification data');
        
        // Auto-close all dialogs and return to home after successful payment
        _autoCloseAfterPaymentSuccess();
      }
    };

    _razorpayService.onFailure = (dynamic response) {
      debugPrint('❌ Payment Failure Response: $response');
      
      String errorMessage;
      int errorCode;
      
      // Handle both mobile and web responses
      if (kIsWeb) {
        // Web response format
        errorCode = response['code'] ?? 0;
        errorMessage = response['description'] ?? 'Payment failed';
      } else {
        // Mobile response format
        errorCode = response.code ?? 0;
        errorMessage = response.message ?? 'Payment failed';
      }
      
      showNotification(
        'Payment failed: $errorMessage',
        'error',
      );
      debugPrint('❌ Error Code: $errorCode');
      debugPrint('❌ Error Message: $errorMessage');
    };

    _razorpayService.onExternalWallet = (dynamic response) {
      // Only available on mobile
      if (!kIsWeb) {
        showNotification(
          'External wallet selected: ${response.walletName}',
          'info',
        );
        debugPrint('💳 Wallet Name: ${response.walletName}');
      }
    };
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
      // Load user data when authentication state changes
      if (widget.authService.isAuthenticated && userId.isNotEmpty) {
        _loadUserPersistentData();
      }
    }
  }

  void showNotification(String message, [String type = 'success']) {
    if (!mounted) return;
    setState(() {
      notification = NotificationState(
        show: true,
        message: message,
        type: type,
      );
    });
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (!mounted) return;
      setState(() {
        notification = NotificationState();
      });
    });
  }

  void handleServiceClick(Service service) {
    setState(() {
      selectedService = service;
      bookingDetails = {'name': '', 'phone': '', 'address': '', 'date': ''};
    });
    _showServiceModal(context, service);
  }

  void handleCloseModal() {
    setState(() {
      selectedService = null;
    });
    Navigator.of(context).pop();
  }

  void handleInputChange(String key, String value) {
    setState(() {
      bookingDetails[key] = value;
    });
  }

  /// Navigation handler for top nav + AI Crop Manager route
  void _navigateTo(String page) {
    if (page == 'ai-crop-manager') {
      // ⬇️ OPEN THE FULL AI CROP MANAGER FORM SCREEN
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const AICropManagerScreen(),
        ),
      );
      return;
    }

    setState(() {
      _currentPage = page;
    });
  }

  Widget _getCurrentPage() {
    switch (_currentPage) {
      case 'services':
        return _buildServiceGrid();
      case 'feedback':
        return const FeedbackPage();
      case 'about':
        return const AboutPage();
      case 'partner':
        return PartnerPage(
          userId: userId,
          showNotification: showNotification,
        );
      case 'contact':
        return ContactPage();
      case 'book-service':
        return _buildServiceGrid();
      default:
        return _buildHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FDF0),
      drawer: AppDrawer(
        userName: userName,
        userEmail: userEmail,
        userId: userId,
        onProfileTap: () => _navigateToProfile(context),
        onBookingsTap: () => _navigateToBookings(context),
        onWeatherTap: () => _navigateToWeather(context),
        onChatTap: () => _navigateToChat(context),
        onLogoutTap: _handleLogout,
        authService: widget.authService,
        totalBookings: _getUserBookingStats()['total'],
        pendingBookings: _getUserBookingStats()['pending'],
      ),
      body: Column(
        children: [
          ui_nav.NavigationBar(
            onNavigate: _navigateTo,
            currentPage: _currentPage,
            languageProvider: widget.languageProvider,
            authService: widget.authService,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _getCurrentPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// HOME PAGE: hero + weather card + services + AI Crop Manager + feedback
  Widget _buildHomePage() {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 16.0),

        // "Why AgriCare" section (hero-style intro)
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE0F2F1),
                Color(0xFFBBF7D0),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final content = [
                // Left: image / illustration
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.asset(
                        'assets/images/why_agricare.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF047857),
                            child: const Center(
                              child: Icon(
                                Icons.agriculture,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24, height: 24),
                // Right: text content
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment:
                        isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loc.translate('why_agricare_title'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF14532D),
                            ),
                        textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.translate('why_agricare_body'),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF1F2933),
                        ),
                        textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loc.translate('why_agricare_points'),
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF374151),
                        ),
                        textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment:
                            isMobile ? Alignment.center : Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: () => _navigateTo('about'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF047857),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            loc.translate('read_more'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ];

              return isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        content[0],
                        const SizedBox(height: 16),
                        content[2],
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: content,
                    );
            },
          ),
        ),

        const SizedBox(height: 16.0),

        // Compact weather card on the top-right with interactive button
        Align(
          alignment: Alignment.topRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE0F2F1),
                      Color(0xFFCFFAFE),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF047857).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.cloud_outlined,
                        color: Color(0xFF047857),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            loc.translate('local_weather_card_title'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF14532D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.translate('local_weather_card_body'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToWeather(context),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(loc.translate('open')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF047857),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24.0),

        // Service cards
        ServiceGrid(onServiceClick: handleServiceClick),

        const SizedBox(height: 32.0),

        // AI Crop Manager banner under services
        _buildAICropManagerBanner(),

        const SizedBox(height: 32.0),

        FeedbackSection(showNotification: showNotification),
        const SizedBox(height: 32.0),
        PublicFeedbackSection(),
        const SizedBox(height: 48.0),
        const Footer(),
      ],
    );
  }

  Widget _buildServiceGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 16.0),
        ServiceGrid(onServiceClick: handleServiceClick),
        const SizedBox(height: 48.0),
        const Footer(),
      ],
    );
  }

  /// Small banner/card that opens the AI Crop Manager screen
  Widget _buildAICropManagerBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateTo('ai-crop-manager'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Crop Manager",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Get smart crop recommendations based on your soil and location.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOOKING, SMS, LIVE TRACKING & PAYMENT LOGIC
  // ---------------------------------------------------------------------------

  bool _isPloughingService(String serviceName) {
    final name = serviceName.toLowerCase();
    return name.contains('ploughing') || 
           name.contains('plough') ||
           name.contains('bullock') ||
           name.contains('rotavator') ||
           name.contains('harrow') ||
           name.contains('land leveling');
  }
  
  bool _isCultivationService(String serviceName) {
    final name = serviceName.toLowerCase();
    return name.contains('seed sowing') || 
           name.contains('transplanting') ||
           name.contains('weeding') ||
           name.contains('intercultivation') ||
           name.contains('mulching') ||
           name.contains('harvesting');
  }
  
  bool _isFertilizerService(String serviceName) {
    final name = serviceName.toLowerCase();
    return name.contains('fertilizer') || 
           name.contains('npk') ||
           name.contains('urea') ||
           name.contains('compost') ||
           name.contains('organic fertilizer');
  }
  
  bool _isPesticideService(String serviceName) {
    final name = serviceName.toLowerCase();
    return name.contains('pesticide') || 
           name.contains('insecticide') ||
           name.contains('fungicide') ||
           name.contains('herbicide') ||
           name.contains('bio-pesticide') ||
           name.contains('spraying');
  }
  
  bool _isTransportService(String serviceName) {
    final name = serviceName.toLowerCase();
    return name.contains('transport') || 
           name.contains('delivery') ||
           name.contains('transportation') ||
           name.contains('/km');
  }

  Future<void> handleBookingSubmit(SubService subService) async {
    if (_isBooking) return;

    setState(() {
      _isBooking = true;
    });

    if (!widget.authService.isAuthenticated) {
      showNotification("Please login to book services.", "error");
      setState(() {
        _isBooking = false;
      });
      return;
    }

    // Check service type for validation
    final isPloughingService = _isPloughingService(subService.name);
    final isCultivationService = _isCultivationService(subService.name);
    final isFertilizerService = _isFertilizerService(subService.name);
    final isPesticideService = _isPesticideService(subService.name);
    final isTransportService = _isTransportService(subService.name);
    
    if (bookingDetails['name']!.trim().isEmpty ||
        bookingDetails['phone']!.trim().isEmpty ||
        bookingDetails['address']!.trim().isEmpty ||
        bookingDetails['date']!.isEmpty ||
        (isPloughingService && (bookingDetails['area'] == null || bookingDetails['area']!.trim().isEmpty)) ||
        (isCultivationService && (bookingDetails['persons'] == null || bookingDetails['persons']!.trim().isEmpty || 
                                  bookingDetails['days'] == null || bookingDetails['days']!.trim().isEmpty)) ||
        ((isFertilizerService || isPesticideService) && (bookingDetails['selectedProduct'] == null || bookingDetails['selectedProduct']!.trim().isEmpty ||
                                                         bookingDetails['quantity'] == null || bookingDetails['quantity']!.trim().isEmpty)) ||
        (isTransportService && (bookingDetails['kilometers'] == null || bookingDetails['kilometers']!.trim().isEmpty))) {
      String errorMessage;
      if (isPloughingService) {
        errorMessage = "Please fill all the booking details including area.";
      } else if (isCultivationService) {
        errorMessage = "Please fill all the booking details including number of persons and days.";
      } else if (isFertilizerService || isPesticideService) {
        errorMessage = "Please fill all the booking details including product selection and quantity.";
      } else if (isTransportService) {
        errorMessage = "Please fill all the booking details including distance in kilometers.";
      } else {
        errorMessage = "Please fill all the booking details.";
      }
      
      showNotification(errorMessage, "error");
      setState(() {
        _isBooking = false;
      });
      return;
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(bookingDetails['phone']!.trim())) {
      showNotification("Please enter a valid 10-digit phone number.", "error");
      setState(() {
        _isBooking = false;
      });
      return;
    }

    try {
      final bookingUserId = userId;

      // Calculate final price based on service type
      String finalPrice;
      if (isPloughingService && bookingDetails['area'] != null) {
        // Ploughing services: area-based calculation
        final area = double.tryParse(bookingDetails['area']!) ?? 1.0;
        final ratePerAcre = double.tryParse(subService.price.replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0;
        final calculatedAmount = area * ratePerAcre;
        finalPrice = '₹${calculatedAmount.toStringAsFixed(0)}';
      } else if (isCultivationService && bookingDetails['persons'] != null && bookingDetails['days'] != null) {
        // Cultivation services: person × days × rate calculation
        final persons = double.tryParse(bookingDetails['persons']!) ?? 1.0;
        final days = double.tryParse(bookingDetails['days']!) ?? 1.0;
        final ratePerPersonPerDay = double.tryParse(subService.price.replaceAll(RegExp(r'[^\d]'), '')) ?? 500.0; // Default ₹500 per person per day
        final calculatedAmount = persons * days * ratePerPersonPerDay;
        finalPrice = '₹${calculatedAmount.toStringAsFixed(0)}';
      } else if ((isFertilizerService || isPesticideService) && bookingDetails['calculatedAmount'] != null) {
        // Fertilizer/Pesticide services: use calculated amount from form
        final calculatedAmount = double.tryParse(bookingDetails['calculatedAmount']!) ?? 0.0;
        finalPrice = '₹${calculatedAmount.toStringAsFixed(0)}';
      } else if (isTransportService && bookingDetails['kilometers'] != null) {
        // Transport services: kilometers × rate per km calculation
        final kilometers = double.tryParse(bookingDetails['kilometers']!) ?? 1.0;
        final ratePerKm = double.tryParse(subService.price.replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0;
        final calculatedAmount = kilometers * ratePerKm;
        finalPrice = '₹${calculatedAmount.toStringAsFixed(0)}';
      } else {
        // Use original price for other services
        finalPrice = subService.price;
      }

      final booking = await widget.databaseService.createBooking(
        userId: bookingUserId,
        serviceName: selectedService!.name,
        subServiceName: subService.name,
        price: finalPrice,
        name: bookingDetails['name']!.trim(),
        phone: bookingDetails['phone']!.trim(),
        address: bookingDetails['address']!.trim(),
        date: bookingDetails['date']!,
      );

      debugPrint('✅ Booking created successfully: ${booking.id}');

      // Show booking success popup with payment option
      _showBookingSuccessPopup(booking);

      // Show notification
      showNotification(
        'Booking confirmed! Booking ID: ${booking.id.substring(0, 8)}',
        'success',
      );

      // Send SMS in background
      await _sendBookingConfirmationSMS(booking);

      // Keep booking details for next booking (don't clear)
      // User can book multiple services with same details
      // Only clear if they want to change details

      // Don't close modal - let user book more services or close manually
      // handleCloseModal(); // Removed - modal stays open
    } catch (error) {
      debugPrint("❌ Error booking service: $error");
      String errorMessage = error.toString();
      if (errorMessage.contains('PERMISSION_DENIED')) {
        errorMessage =
            'Database permission denied. Please check your Firestore rules.';
      } else {
        errorMessage = 'Failed to book service. Please try again.';
      }
      showNotification(errorMessage, "error");
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }

  void _showServiceModal(BuildContext context, Service service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ServiceModal(
          service: service,
          isBooking: _isBooking,
          bookingDetails: bookingDetails,
          onInputChange: handleInputChange,
          onSubmit: handleBookingSubmit,
        );
      },
    ).then((_) {
      setState(() {
        selectedService = null;
      });
    });
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pop(context);
    if (!widget.authService.isAuthenticated) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          userName: userName,
          userEmail: userEmail,
          userId: userId,
          authService: widget.authService,
        ),
      ),
    );
  }

  void _navigateToBookings(BuildContext context) {
    Navigator.pop(context);
    if (!widget.authService.isAuthenticated) return;

    final bookingsUserId = userId;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserBookingsScreen(
          userId: bookingsUserId,
          databaseService: widget.databaseService,
        ),
      ),
    );
  }

  void _navigateToWeather(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Local Weather')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WeatherForecast(showNotification: showNotification),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.pop(context);
    
    // Open support chat for both authenticated and guest users
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SupportChatScreen(
          userId: widget.authService.isAuthenticated ? userId : null,
          userName: widget.authService.isAuthenticated ? userName : null,
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await widget.authService.logout();
      showNotification("Logged out successfully.", "success");
    } catch (e) {
      showNotification("Error during logout.", "error");
    }
  }

  Future<void> _showLiveTrackingMap(Booking booking) async {
    await _liveTrackingService.initializeTracking(
      bookingId: booking.id,
      customerId: booking.userId,
      customerLocation: const LatLng(12.9716, 77.5946),
      providerId: 'provider_001',
      providerInfo: ProviderInfo(
        id: 'provider_001',
        name: 'Ramesh Kumar',
        phone: '+919876543210',
        photo: 'https://picsum.photos/seed/provider1/200/200.jpg',
        vehicleType: 'Tractor',
        vehicleNumber: 'AGRI-1234',
        rating: 4.8,
        completedServices: 156,
      ),
      customerName: booking.name,
      customerPhone: booking.phone,
      serviceName: booking.subServiceName,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LiveTrackingMap(
          bookingId: booking.id,
          serviceName: booking.subServiceName,
          customerAddress: booking.address,
          customerId: booking.userId,
          sourceLocation: 'BAGALKOT',
        ),
      ),
    );
  }

  void _showBookingLocationMap(Booking booking) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookingLocationMap(
          address: booking.address,
          serviceName: booking.subServiceName,
          bookingId: booking.id,
        ),
      ),
    );
  }

  Future<void> _sendBookingConfirmationSMS(Booking booking) async {
    try {
      debugPrint('📱 Sending booking confirmation SMS to: ${booking.phone}');

      final estimatedArrival = DateTime.now().add(const Duration(hours: 2));

      final smsMessage = _generateBookingMessage(
        farmerName: booking.name,
        serviceName: booking.subServiceName,
        bookingId: booking.id,
        bookingDate: booking.date,
        providerName: 'Ramesh Kumar',
        estimatedArrival: estimatedArrival,
      );

      debugPrint('📄 SMS Message Preview:\n$smsMessage');
      debugPrint('📱 Phone Number: ${booking.phone}');

      bool smsSent = false;
      String smsMethod = 'none';

      // Try to send SMS directly via Firebase Cloud Functions
      try {
        debugPrint('🔥 Sending SMS directly via Firebase to ${booking.phone}...');
        
        // Call Firebase Cloud Function to send SMS
        final result = await FirebaseFunctions.instance
            .httpsCallable('sendSmsCallable')
            .call({
          'phone': booking.phone.trim(),
          'message': smsMessage,
        });

        if (result.data['success'] == true) {
          smsSent = true;
          smsMethod = 'Firebase Cloud Functions';
          debugPrint('✅ SMS sent successfully via Firebase');
          showNotification(
            'SMS sent to ${booking.phone}',
            'success',
          );
        } else {
          debugPrint('⚠️ Firebase SMS failed: ${result.data['error']}');
          throw Exception('Firebase SMS failed');
        }
      } catch (e) {
        debugPrint('⚠️ Firebase SMS error: $e');
        debugPrint('📱 Firebase Functions not deployed or configured');
        showNotification(
          'Booking confirmed! Deploy Firebase Functions to enable automatic SMS.',
          'info',
        );
      }

      // Show SMS preview popup
      _showSMSPopup(booking.phone, smsMessage, smsSent, smsMethod);

      // Log SMS attempt
      debugPrint('📊 SMS Summary:');
      debugPrint('   Phone: ${booking.phone}');
      debugPrint('   Sent: $smsSent');
      debugPrint('   Method: $smsMethod');
      debugPrint('   Message Length: ${smsMessage.length} characters');
      
    } catch (e) {
      debugPrint('❌ Error in SMS process: $e');
      showNotification('Booking confirmed! SMS preview in console.', 'info');
    }
  }

  String _generateBookingMessage({
    required String farmerName,
    required String serviceName,
    required String bookingId,
    required String bookingDate,
    required String providerName,
    required DateTime estimatedArrival,
  }) {
    final formattedDate = _formatDate(bookingDate);
    final shortBookingId = bookingId.substring(0, 8).toUpperCase();

    return '''
🌾 AgriCare - Booking Confirmation

Dear $farmerName,

Your booking has been successfully completed!

Service: $serviceName
Booking ID: $shortBookingId
Date: $formattedDate

Our service provider will contact you soon.

Thank you for choosing AgriCare!
🌱 Growing Together, Harvesting Success 🌱
''';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showBookingSuccessPopup(Booking booking) {
    final loc = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFF5F5F5),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 700, // Prevent overflow
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // Header with close button and auto-close timer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ploughing Services',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Auto-close in 30s',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Auto-close timer (invisible but functional)
                    Builder(
                      builder: (context) {
                        // Auto-close dialog after 30 seconds if no payment method is selected
                        Timer(const Duration(seconds: 30), () {
                          if (Navigator.of(ctx).canPop()) {
                            Navigator.of(ctx).pop();
                            showNotification(
                              'Booking confirmed! You can complete payment later from "My Bookings".',
                              'info',
                            );
                          }
                        });
                        return const SizedBox.shrink(); // Invisible widget
                      },
                    ),

                    // Success icon and message with animation
                    Container(
                      color: const Color(0xFFF5F5F5),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          // Animated success icon
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // Animated text
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Column(
                                    children: [
                                      const Text(
                                        '🎉 Booking Confirmed!',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2937),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Your ${booking.subServiceName} service has been successfully booked',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Booking details
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSimpleDetailRow('Service:', booking.subServiceName),
                          const SizedBox(height: 12),
                          _buildSimpleDetailRow('Booking ID:', booking.id.substring(0, 8).toUpperCase()),
                          const SizedBox(height: 12),
                          _buildSimpleDetailRow('Date:', booking.date),
                        ],
                      ),
                    ),

                    // Payment options section
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Choose Payment Method:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Pay Now button (Online Payment) - Enhanced
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF9800).withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          debugPrint('🔘 Pay Now (Online) button clicked!');
                                          debugPrint('   Booking ID: ${booking.id}');
                                          debugPrint('   Amount: ${booking.price}');
                                          Navigator.of(ctx).pop();
                                          _openDirectRazorpayPayment(booking);
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 24),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.payment_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Pay Now (Online)',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  booking.price,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Cash on Delivery button - Enhanced
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1200),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF10B981).withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          debugPrint('🔘 Cash on Delivery button clicked!');
                                          debugPrint('   Booking ID: ${booking.id}');
                                          debugPrint('   Amount: ${booking.price}');
                                          Navigator.of(ctx).pop();
                                          _processCashOnDelivery(booking);
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 24),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.payments_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Cash on Delivery',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  booking.price,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              const Icon(
                                                Icons.schedule_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          // Close and Track Service buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      // Don't close the service modal - user can book again
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF10B981),
                                      side: const BorderSide(color: Color(0xFF10B981)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Book Another',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      _showLiveTrackingMap(booking);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Track Service',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSimpleDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  void _showPaymentOptionsDialog(BuildContext parentContext, Booking booking) {
    PaymentMethod? selectedPaymentMethod;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount: ${booking.price}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment options with animations
                    _buildInteractivePaymentOption(
                      context: ctx,
                      title: 'QR Code Payment',
                      subtitle: 'Scan and pay using any UPI app',
                      icon: Icons.qr_code_2,
                      iconColor: const Color(0xFF3B82F6),
                      isSelected: selectedPaymentMethod == PaymentMethod.qr,
                      onTap: () {
                        setDialogState(() => selectedPaymentMethod = PaymentMethod.qr);
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildInteractivePaymentOption(
                      context: ctx,
                      title: 'UPI Payment',
                      subtitle: 'Pay using any UPI app',
                      icon: Icons.account_balance_wallet,
                      iconColor: const Color(0xFF8B5CF6),
                      isSelected: selectedPaymentMethod == PaymentMethod.upi,
                      onTap: () {
                        setDialogState(() => selectedPaymentMethod = PaymentMethod.upi);
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildInteractivePaymentOption(
                      context: ctx,
                      title: 'Cash on Delivery',
                      subtitle: 'Pay after service is completed',
                      icon: Icons.payments,
                      iconColor: const Color(0xFF10B981),
                      isSelected: selectedPaymentMethod == PaymentMethod.cod,
                      onTap: () {
                        setDialogState(() => selectedPaymentMethod = PaymentMethod.cod);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Pay Now Button with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: selectedPaymentMethod == null
                            ? null
                            : () {
                                switch (selectedPaymentMethod) {
                                  case PaymentMethod.qr:
                                    Navigator.of(ctx).pop();
                                    _processQRPayment(context, booking);
                                    break;
                                  case PaymentMethod.upi:
                                    Navigator.of(ctx).pop();
                                    _processUPIPayment(context, booking);
                                    break;
                                  case PaymentMethod.cod:
                                    Navigator.of(ctx).pop();
                                    _processCODPayment(context, booking);
                                    break;
                                  case null:
                                    break;
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPaymentMethod == null
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: selectedPaymentMethod == null ? 0 : 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedPaymentMethod == null
                                  ? Icons.lock_outline
                                  : Icons.check_circle_outline,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Proceed to Pay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Cancel button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text(
                          'I\'ll pay later',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInteractivePaymentOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(isSelected ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.0 : 0.8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // Payment processing functions
  // ----------------------------

  void _processQRPayment(BuildContext context, Booking booking) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Close loading dialog
    if (!mounted) return;
    Navigator.of(context).pop();

    // Show QR code dialog
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Scan to Pay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR Code Image - Replace with your actual QR code generation
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 80, color: Colors.blue[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Scan with any UPI app',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                booking.price,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Payment for ${booking.subServiceName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showPaymentSuccess(context, booking, 'QR Code');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: const Text('I\'ve Paid'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processUPIPayment(BuildContext context, Booking booking) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Close loading dialog
    if (!mounted) return;
    Navigator.of(context).pop();

    final upiUrl = 'upi://pay?pa=your_upi_id@okbizaxis&pn=AgriCare&am=${booking.price}&cu=INR';

    try {
      if (await canLaunchUrl(Uri.parse(upiUrl))) {
        final launched = await launchUrl(Uri.parse(upiUrl));
        if (!launched) {
          throw Exception('Could not launch UPI app');
        }

        // Show payment confirmation dialog
        bool? paymentConfirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Payment Confirmation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.payment,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please complete the payment in your UPI app and confirm below once done.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.price,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('I\'ve Paid'),
                ),
              ],
            );
          },
        );

        if (paymentConfirmed == true) {
          if (!mounted) return;
          _showPaymentSuccess(context, booking, 'UPI Payment');
        }
      } else {
        throw Exception('No UPI app found');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch UPI app')),
      );
    }
  }

  void _processRazorpayPayment(Booking booking) {
    debugPrint('💳 Processing Razorpay payment for ${booking.price}');
    debugPrint('📱 Platform: ${_razorpayService.getPlatformInfo()}');
    
    // Convert price string to double - remove currency symbols and parse
    String cleanPrice = booking.price.replaceAll(RegExp(r'[^\d.]'), '');
    double amount = double.tryParse(cleanPrice) ?? 100.0; // Default to 100 if parsing fails
    debugPrint('💰 Original price: ${booking.price}');
    debugPrint('💰 Clean price: $cleanPrice');
    debugPrint('💰 Amount parsed: ₹$amount');
    
    // Show interactive payment dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                kIsWeb ? Icons.web : Icons.phone_android,
                color: kIsWeb ? Colors.blue : Colors.green,
              ),
              const SizedBox(width: 8),
              const Text('Payment Gateway'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kIsWeb ? '🌐 Web Payment Ready!' : '📱 Mobile Payment Ready!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                kIsWeb 
                  ? 'Razorpay web checkout will open in a popup window.'
                  : 'Razorpay mobile checkout will open natively.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Payment Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text('Card: 4111 1111 1111 1111'),
                    const Text('Expiry: Any future date'),
                    const Text('CVV: Any 3 digits'),
                    const SizedBox(height: 8),
                    Text(
                      'Amount: ₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                debugPrint('🚀 Pay Now button clicked in dialog');
                debugPrint('💰 Amount to pay: ₹$amount');
                
                // Don't close dialog immediately, show loading
                Navigator.pop(ctx);
                
                // Show loading notification
                showNotification(
                  '🚀 Opening Razorpay checkout...',
                  'info',
                );
                
                // Small delay to ensure UI updates
                await Future.delayed(const Duration(milliseconds: 500));
                
                debugPrint('🚀 Calling _openRealRazorpayCheckout...');
                _openRealRazorpayCheckout(booking, amount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Pay Now'),
            ),
          ],
        );
      },
    );
  }

  void _openRealRazorpayCheckout(Booking booking, double amount) {
    debugPrint('✅ _openRealRazorpayCheckout called');
    debugPrint('   Amount: ₹$amount');
    debugPrint('   Booking ID: ${booking.id}');
    debugPrint('   Customer: ${booking.name}');
    debugPrint('   Phone: ${booking.phone}');
    debugPrint('   Email: $userEmail');
    debugPrint('   Platform: ${kIsWeb ? "Web" : "Mobile"}');
    
    try {
      // Open real Razorpay checkout
      debugPrint('🚀 Calling _razorpayService.openCheckout...');
      _razorpayService.openCheckout(
        amount: amount,
        name: booking.name,
        phone: booking.phone,
        email: userEmail,
        description: '${booking.subServiceName} - ${booking.date}',
        bookingId: booking.id,
        serviceName: booking.subServiceName,
      );
      debugPrint('✅ _razorpayService.openCheckout called successfully');
    } catch (e) {
      debugPrint('❌ Error in _openRealRazorpayCheckout: $e');
      showNotification(
        'Error opening payment: $e',
        'error',
      );
    }
  }

  void _processCODPayment(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Cash on Delivery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.money,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'You have chosen to pay ${booking.price} in cash when the service is completed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our service provider will collect the payment after completing the service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showPaymentSuccess(context, booking, 'Cash on Delivery');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  /// Simplified Cash on Delivery processing for booking success popup
  void _openDirectRazorpayPayment(Booking booking) {
    debugPrint('🚀 Opening Razorpay directly (no intermediate popup)');
    debugPrint('   Booking ID: ${booking.id}');
    debugPrint('   Amount: ${booking.price}');
    
    // Convert price string to double - remove currency symbols and parse
    String cleanPrice = booking.price.replaceAll(RegExp(r'[^\d.]'), '');
    double amount = double.tryParse(cleanPrice) ?? 100.0;
    debugPrint('💰 Original price: ${booking.price}');
    debugPrint('💰 Clean price: $cleanPrice');
    debugPrint('💰 Amount parsed: ₹$amount');
    
    // Show enhanced loading dialog
    _showPaymentLoadingDialog(booking, amount);
  }

  void _showPaymentLoadingDialog(Booking booking, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated loading icon
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 6.28, // 2π for full rotation
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.payment_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Initializing Payment Gateway',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Opening secure Razorpay checkout for ${booking.price}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                // Progress indicator
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    // Close loading dialog and open Razorpay after animation
    Future.delayed(const Duration(milliseconds: 1800), () {
      Navigator.of(context).pop(); // Close loading dialog
      debugPrint('🚀 Calling _openRealRazorpayCheckout directly...');
      _openRealRazorpayCheckout(booking, amount);
    });
  }

  void _processCashOnDelivery(Booking booking) {
    debugPrint('💰 Processing Cash on Delivery payment');
    debugPrint('   Booking ID: ${booking.id}');
    debugPrint('   Amount: ${booking.price}');
    
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.money,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cash on Delivery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Payment Method Selected',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You will pay ${booking.price} in cash when our service provider completes the work.',
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF6B7280),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Our service provider will contact you before arriving.',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                debugPrint('✅ Cash on Delivery confirmed for booking ${booking.id}');
                
                // Show success popup
                _showBookingSuccessMessage(booking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm COD',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show success message after Cash on Delivery confirmation
  void _showBookingSuccessMessage(Booking booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        // Auto-close this dialog after 3 seconds
        Timer(const Duration(seconds: 3), () {
          if (Navigator.of(ctx).canPop()) {
            Navigator.of(ctx).pop();
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Booking Successful!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ Your booking has been successfully completed!',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF065F46),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Service: ${booking.subServiceName}',
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Booking ID: ${booking.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payment: Cash on Delivery (${booking.price})',
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF6B7280),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Our service provider will contact you soon and collect payment after service completion.',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  showNotification(
                    'Booking confirmed! Service provider will contact you soon.',
                    'success',
                  );
                  
                  // Auto-close all dialogs and return to home after COD confirmation
                  _autoCloseAfterPaymentSuccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentSuccess(BuildContext context, Booking booking, String paymentMethod) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text('Payment Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                '${booking.price} paid successfully via $paymentMethod',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Booking ID: ${booking.id.substring(0, 8).toUpperCase()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your service request has been confirmed. Our team will contact you soon.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Navigate to booking details or home screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailScreen(booking: booking),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              child: const Text('View Booking'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, BuildContext? context, TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: valueStyle ?? TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.blue, size: 20)
            else
              const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSMSPopup(String phoneNumber, String message, bool wasSent, [String method = 'Unknown']) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                // Success Icon (smaller)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms,
                    color: Color(0xFF10B981),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title (smaller)
                Text(
                  wasSent ? 'SMS Sent!' : 'SMS Preview',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Phone number (compact)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone, size: 16, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Text(
                        phoneNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Message preview (compact)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.message, size: 14, color: Color(0xFF6B7280)),
                            SizedBox(width: 6),
                            Text(
                              'Message:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Info box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          wasSent
                              ? 'SMS sent via $method. Customer will receive the message shortly.'
                              : 'Your booking has been successfully completed! SMS preview shown above.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Close button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Got it!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Auto-close all dialogs and return to home after successful payment
  void _autoCloseAfterPaymentSuccess() {
    debugPrint('🔄 Auto-closing dialogs after payment success...');
    
    // Close any open dialogs and modals with a delay to show success message
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Close all dialogs by popping until we reach the main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // Clear selected service to close any open service modal
        setState(() {
          selectedService = null;
          bookingDetails = {'name': '', 'phone': '', 'address': '', 'date': ''};
        });
        
        debugPrint('✅ All dialogs closed, returned to home page');
        
        // Show final success message
        showNotification(
          '🎉 Booking completed successfully! Check "My Bookings" for details.',
          'success',
        );
      }
    });
  }
}

