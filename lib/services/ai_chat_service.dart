// lib/services/ai_chat_service.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? userId;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      message: map['message'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['userId'],
    );
  }
}

class AIChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'chat_messages';
  
  // Agriculture and app-related knowledge base
  final Map<String, List<String>> _knowledgeBase = {
    // Agriculture Questions
    'soil': [
      'Soil testing helps determine nutrient levels, pH, and organic matter content.',
      'For healthy soil, maintain pH between 6.0-7.5 for most crops.',
      'Add organic compost regularly to improve soil structure and fertility.',
      'Test your soil every 2-3 years for optimal crop management.',
    ],
    'fertilizer': [
      'NPK fertilizers provide Nitrogen (N), Phosphorus (P), and Potassium (K).',
      'Apply fertilizers based on soil test results and crop requirements.',
      'Organic fertilizers release nutrients slowly and improve soil health.',
      'Over-fertilization can harm plants and pollute groundwater.',
    ],
    'irrigation': [
      'Drip irrigation saves 30-50% water compared to flood irrigation.',
      'Water early morning or evening to reduce evaporation losses.',
      'Check soil moisture before watering - overwatering can damage roots.',
      'Install moisture sensors for efficient water management.',
    ],
    'pest': [
      'Integrated Pest Management (IPM) combines biological and chemical controls.',
      'Use neem oil as a natural pesticide for organic farming.',
      'Regular crop monitoring helps detect pest problems early.',
      'Beneficial insects like ladybugs help control harmful pests naturally.',
    ],
    'crop': [
      'Crop rotation helps prevent soil depletion and pest buildup.',
      'Choose crop varieties suitable for your local climate and soil.',
      'Plant cover crops during off-season to improve soil health.',
      'Diversified cropping reduces risk and improves farm income.',
    ],
    'weather': [
      'Monitor weather forecasts for planning farming activities.',
      'Protect crops from extreme weather using mulching and covers.',
      'Adjust irrigation schedules based on rainfall predictions.',
      'Use weather data to optimize planting and harvesting times.',
    ],
    
    // App-related Questions
    'booking': [
      'To book a service: Select service → Choose sub-service → Fill details → Confirm booking.',
      'You can track your booking status in the Profile section.',
      'Payment can be made online via Razorpay or Cash on Delivery.',
      'Service providers will contact you before arriving at your location.',
    ],
    'payment': [
      'We accept online payments through Razorpay (cards, UPI, wallets).',
      'Cash on Delivery is available for all services.',
      'Payment is calculated automatically based on area, quantity, or distance.',
      'You will receive payment confirmation via SMS and app notification.',
    ],
    'profile': [
      'Update your profile by clicking Edit Profile in the navigation menu.',
      'You can upload a profile photo from camera, gallery, or URL.',
      'Your booking history is saved and accessible in the Profile section.',
      'Profile information is used for service bookings and communication.',
    ],
    'services': [
      'We offer 8 main categories: Soil Testing, Ploughing, Cultivation, Fertilizers, Borewell, Irrigation, Transport, and Contract Farming.',
      'Each service has different pricing: area-based, person-based, or distance-based.',
      'Service providers are verified and trained professionals.',
      'All services come with quality assurance and customer support.',
    ],
    'partner': [
      'Become a partner by clicking "Being Partner" and filling the application form.',
      'Partners need experience in agricultural services and valid documentation.',
      'We provide training, insurance coverage, and fair payment terms.',
      'Partner applications are reviewed within 2-3 business days.',
    ],
  };

  /// Get AI response for user message
  Future<String> getAIResponse(String userMessage) async {
    try {
      debugPrint('🤖 Processing user message: $userMessage');
      
      // Convert to lowercase for better matching
      final message = userMessage.toLowerCase();
      
      // Check for greetings
      if (_isGreeting(message)) {
        return _getGreetingResponse();
      }
      
      // Check for app-specific questions
      String? appResponse = _getAppSpecificResponse(message);
      if (appResponse != null) {
        return appResponse;
      }
      
      // Check agriculture knowledge base
      String? agricultureResponse = _getAgricultureResponse(message);
      if (agricultureResponse != null) {
        return agricultureResponse;
      }
      
      // Try to get response from external AI API (if available)
      String? externalResponse = await _getExternalAIResponse(userMessage);
      if (externalResponse != null) {
        return externalResponse;
      }
      
      // Default helpful response
      return _getDefaultResponse();
      
    } catch (e) {
      debugPrint('❌ Error getting AI response: $e');
      return 'I apologize, but I\'m having trouble processing your request right now. Please try again or contact our support team for assistance.';
    }
  }

  bool _isGreeting(String message) {
    final greetings = ['hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening', 'namaste'];
    return greetings.any((greeting) => message.contains(greeting));
  }

  String _getGreetingResponse() {
    final responses = [
      'Hello! Welcome to AgriCare Support. I\'m here to help you with agriculture and app-related questions. How can I assist you today?',
      'Hi there! I\'m your AgriCare AI assistant. Feel free to ask me about farming techniques, our services, or how to use the app.',
      'Namaste! I\'m here to help you with all your agricultural and app queries. What would you like to know?',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  String? _getAppSpecificResponse(String message) {
    // Booking related
    if (message.contains('book') || message.contains('service') || message.contains('order')) {
      if (message.contains('how')) {
        return '📱 To book a service:\n\n1. Select a service category (Ploughing, Soil Testing, etc.)\n2. Choose the specific sub-service\n3. Fill in your details (name, phone, address, date)\n4. Review the calculated price\n5. Confirm your booking\n\nYou\'ll receive a confirmation and the service provider will contact you before arrival. Track your booking in "My Bookings"!';
      }
      return _getRandomResponse(_knowledgeBase['booking']!);
    }
    
    // Payment related
    if (message.contains('pay') || message.contains('money') || message.contains('cost') || message.contains('price')) {
      if (message.contains('how') || message.contains('method')) {
        return '💰 Payment Methods:\n\n✅ Online Payment (Razorpay)\n   • Credit/Debit Cards\n   • UPI (Google Pay, PhonePe, etc.)\n   • Net Banking\n   • Wallets\n\n✅ Cash on Delivery\n   • Pay directly to service provider\n\nPrices are calculated automatically based on:\n• Area (for ploughing, cultivation)\n• Quantity (for fertilizers, pesticides)\n• Distance (for transport)\n• Duration (for contract farming)';
      }
      return _getRandomResponse(_knowledgeBase['payment']!);
    }
    
    // Profile related
    if (message.contains('profile') || message.contains('account') || message.contains('photo')) {
      if (message.contains('update') || message.contains('edit') || message.contains('change')) {
        return '👤 To update your profile:\n\n1. Open the menu (☰) from top-left\n2. Tap "Edit Profile"\n3. Update your information:\n   • Name\n   • Phone number\n   • Profile photo (camera/gallery/URL)\n4. Save changes\n\nYour profile info is used for bookings and communication with service providers.';
      }
      return _getRandomResponse(_knowledgeBase['profile']!);
    }
    
    // Services related
    if (message.contains('service') && (message.contains('what') || message.contains('which') || message.contains('offer'))) {
      return '🚜 AgriCare Services:\n\n1. 🧪 Soil Testing - Lab analysis & recommendations\n2. 🚜 Ploughing - Land preparation services\n3. 🌱 Cultivation - Crop cultivation support\n4. 🌾 Fertilizers - Quality fertilizer supply\n5. 💧 Borewell - Drilling & maintenance\n6. 💦 Irrigation - System installation\n7. 🚚 Transport - Farm produce transport\n8. 🤝 Contract Farming - Partnership programs\n\nEach service has verified providers and quality assurance!';
    }
    
    // Partner related
    if (message.contains('partner') || message.contains('join') || message.contains('work with')) {
      if (message.contains('how') || message.contains('become')) {
        return '🤝 Become an AgriCare Partner:\n\n1. Click "Being Partner" in the menu\n2. Fill the application form:\n   • Personal details\n   • Service expertise\n   • Experience & qualifications\n   • Documentation\n3. Submit application\n4. Our team reviews (2-3 days)\n5. Get verified and start earning!\n\nBenefits:\n✅ Regular work opportunities\n✅ Fair payment terms\n✅ Training & support\n✅ Insurance coverage';
      }
      return _getRandomResponse(_knowledgeBase['partner']!);
    }
    
    return null;
  }

  String? _getAgricultureResponse(String message) {
    // Soil related
    if (message.contains('soil')) {
      if (message.contains('test') || message.contains('check')) {
        return '🧪 Soil Testing:\n\nWhy test soil?\n• Know nutrient levels (N, P, K)\n• Check pH balance\n• Measure organic matter\n• Get fertilizer recommendations\n\nHow to test:\n1. Book our Soil Testing service\n2. We collect samples from your field\n3. Lab analysis (2-3 days)\n4. Receive detailed report with recommendations\n\nTest every 2-3 years for best results!';
      }
      if (message.contains('improve') || message.contains('fertility')) {
        return '🌱 Improve Soil Fertility:\n\n1. Add organic compost regularly\n2. Practice crop rotation\n3. Use green manure crops\n4. Maintain proper pH (6.0-7.5)\n5. Avoid over-tilling\n6. Add bio-fertilizers\n7. Mulch to retain moisture\n\nHealthy soil = Healthy crops!';
      }
      return _getRandomResponse(_knowledgeBase['soil']!);
    }
    
    // Fertilizer related
    if (message.contains('fertilizer') || message.contains('nutrient')) {
      if (message.contains('which') || message.contains('what') || message.contains('type')) {
        return '🌾 Fertilizer Types:\n\n1. NPK Fertilizers\n   • N (Nitrogen) - Leaf growth\n   • P (Phosphorus) - Root development\n   • K (Potassium) - Overall health\n\n2. Organic Fertilizers\n   • Compost\n   • Vermicompost\n   • Green manure\n   • Bio-fertilizers\n\n3. Micronutrients\n   • Zinc, Iron, Boron, etc.\n\nChoose based on soil test results!';
      }
      return _getRandomResponse(_knowledgeBase['fertilizer']!);
    }
    
    // Irrigation related
    if (message.contains('water') || message.contains('irrigation') || message.contains('irrigate')) {
      if (message.contains('how') || message.contains('method') || message.contains('system')) {
        return '💧 Irrigation Methods:\n\n1. Drip Irrigation ⭐\n   • Saves 30-50% water\n   • Direct to roots\n   • Best for vegetables\n\n2. Sprinkler System\n   • Good for large fields\n   • Uniform coverage\n\n3. Flood Irrigation\n   • Traditional method\n   • High water use\n\nTips:\n✅ Water early morning/evening\n✅ Check soil moisture first\n✅ Use moisture sensors\n✅ Mulch to reduce evaporation';
      }
      return _getRandomResponse(_knowledgeBase['irrigation']!);
    }
    
    // Pest related
    if (message.contains('pest') || message.contains('insect') || message.contains('bug') || message.contains('disease')) {
      if (message.contains('control') || message.contains('prevent') || message.contains('natural')) {
        return '🐛 Natural Pest Control:\n\n1. Neem Oil\n   • Organic pesticide\n   • Safe for plants\n   • Effective against many pests\n\n2. Beneficial Insects\n   • Ladybugs eat aphids\n   • Praying mantis\n   • Parasitic wasps\n\n3. Cultural Practices\n   • Crop rotation\n   • Remove infected plants\n   • Proper spacing\n   • Regular monitoring\n\n4. Biological Control\n   • Bacillus thuringiensis (Bt)\n   • Trichoderma for diseases\n\nIPM = Best approach!';
      }
      return _getRandomResponse(_knowledgeBase['pest']!);
    }
    
    // Crop related
    if (message.contains('crop') || message.contains('plant') || message.contains('grow') || message.contains('farm')) {
      if (message.contains('rotation')) {
        return '🔄 Crop Rotation Benefits:\n\n1. Prevents soil depletion\n2. Breaks pest cycles\n3. Reduces disease buildup\n4. Improves soil structure\n5. Increases biodiversity\n\nExample rotation:\nYear 1: Legumes (add nitrogen)\nYear 2: Leafy vegetables\nYear 3: Root vegetables\nYear 4: Fruiting crops\n\nRotate families, not just crops!';
      }
      return _getRandomResponse(_knowledgeBase['crop']!);
    }
    
    // Weather related
    if (message.contains('weather') || message.contains('rain') || message.contains('forecast')) {
      return '🌤️ Weather & Farming:\n\nUse our Weather Forecast feature:\n1. Check 7-day forecast\n2. Plan farming activities\n3. Adjust irrigation schedules\n4. Protect crops from extreme weather\n\nTips:\n✅ Don\'t irrigate before rain\n✅ Harvest before heavy rain\n✅ Use mulch in hot weather\n✅ Cover crops during frost\n\nStay updated with weather alerts!';
    }
    
    return null;
  }

  String _getRandomResponse(List<String> responses) {
    return responses[DateTime.now().millisecond % responses.length];
  }

  Future<String?> _getExternalAIResponse(String message) async {
    // This would integrate with external AI APIs like OpenAI, Gemini, etc.
    // For now, return null to use local knowledge base
    return null;
  }

  String _getDefaultResponse() {
    final responses = [
      'I\'d be happy to help! Could you please be more specific about what you\'d like to know? I can assist with agriculture techniques, app features, booking services, or general farming questions.',
      'I\'m here to help with agriculture and app-related questions. You can ask me about soil management, crop care, irrigation, pest control, or how to use AgriCare services.',
      'Feel free to ask me about:\n• Farming techniques and best practices\n• How to book and use our services\n• Payment and pricing information\n• Profile and account management\n• Becoming a partner\n\nWhat would you like to know?',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  /// Save chat message to Firebase
  Future<void> saveChatMessage(ChatMessage message) async {
    try {
      await _firestore.collection(_collection).add(message.toMap());
      debugPrint('💾 Chat message saved: ${message.message.substring(0, 30)}...');
    } catch (e) {
      debugPrint('❌ Error saving chat message: $e');
    }
  }

  /// Get chat history for user
  Future<List<ChatMessage>> getChatHistory(String userId, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatMessage.fromMap({...doc.data(), 'id': doc.id}))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching chat history: $e');
      return [];
    }
  }

  /// Clear chat history for user
  Future<void> clearChatHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      
      debugPrint('🗑️ Chat history cleared for user: $userId');
    } catch (e) {
      debugPrint('❌ Error clearing chat history: $e');
    }
  }

  /// Get suggested questions
  List<String> getSuggestedQuestions() {
    return [
      'How do I book a service?',
      'What payment methods do you accept?',
      'How to improve soil fertility?',
      'Best irrigation practices?',
      'How to control pests naturally?',
      'What services do you offer?',
      'How to become a partner?',
      'How to update my profile?',
    ];
  }
}