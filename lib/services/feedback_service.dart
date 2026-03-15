// lib/services/feedback_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_localizations.dart';

class FeedbackService extends ChangeNotifier {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() {
    debugPrint('🏭 FeedbackService: Returning singleton instance ${_instance.hashCode}');
    return _instance;
  }
  FeedbackService._internal() {
    debugPrint('🏭 FeedbackService: Creating new singleton instance');
  }

  List<FeedbackData> _feedbacks = [];
  List<FeedbackData> _userFeedbacks = []; // Store user-added feedbacks separately

  // Initialize default feedbacks with localized data
  void initializeWithContext(BuildContext context) {
    final loc = AppLocalizations.of(context);
    _feedbacks = [
      // Keep 2 default feedbacks
      FeedbackData(
        id: '1',
        userName: loc.translate('sample_user_1'),
        serviceName: loc.translate('sample_service_1'),
        rating: 5,
        comment: loc.translate('sample_comment_1'),
        date: loc.translate('sample_date_1'),
        verified: true,
        helpful: 24,
      ),
      FeedbackData(
        id: '2',
        userName: loc.translate('sample_user_2'),
        serviceName: loc.translate('sample_service_2'),
        rating: 4,
        comment: loc.translate('sample_comment_2'),
        date: loc.translate('sample_date_2'),
        verified: true,
        helpful: 18,
      ),
      // Add user feedbacks
      ..._userFeedbacks,
    ];
    notifyListeners();
  }

  List<FeedbackData> get feedbacks => List.unmodifiable(_feedbacks);

  void addFeedback({
    required String userName,
    required String serviceName,
    required int rating,
    required String comment,
    required String feedbackType,
    BuildContext? context,
  }) {
    debugPrint('📝 Adding new feedback from: $userName');
    debugPrint('   Rating: $rating stars');
    debugPrint('   Type: $feedbackType');
    debugPrint('   Comment: ${comment.substring(0, comment.length > 50 ? 50 : comment.length)}...');
    
    final newFeedback = FeedbackData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: userName,
      serviceName: _getServiceNameFromType(feedbackType, context),
      rating: rating,
      comment: comment,
      date: 'Just now',
      verified: false, // New feedbacks are not verified initially
      helpful: 0,
    );

    // Add to user feedbacks and main feedbacks list
    _userFeedbacks.add(newFeedback);
    _feedbacks.add(newFeedback);
    
    debugPrint('✅ New feedback added successfully!');
    debugPrint('   Total feedbacks now: ${_feedbacks.length}');
    debugPrint('   New average rating: ${averageRating.toStringAsFixed(1)}');
    
    notifyListeners();
    debugPrint('🔔 Listeners notified of feedback change');
  }

  String _getServiceNameFromType(String feedbackType, [BuildContext? context]) {
    if (context != null) {
      final loc = AppLocalizations.of(context);
      switch (feedbackType) {
        case 'suggestion':
          return loc.translate('feedback_service_suggestion');
        case 'bug':
          return loc.translate('feedback_service_bug');
        case 'compliment':
          return loc.translate('feedback_service_compliment');
        case 'complaint':
          return loc.translate('feedback_service_complaint');
        case 'other':
          return loc.translate('feedback_service_other');
        default:
          return loc.translate('feedback_service_general');
      }
    }
    
    // Fallback to English if no context
    switch (feedbackType) {
      case 'suggestion':
        return 'Suggestion';
      case 'bug':
        return 'App Experience';
      case 'compliment':
        return 'Service Appreciation';
      case 'complaint':
        return 'Service Issue';
      case 'other':
        return 'Other Feedback';
      default:
        return 'General Service';
    }
  }

  void markHelpful(String feedbackId) {
    final feedback = _feedbacks.firstWhere((f) => f.id == feedbackId);
    feedback.helpful++;
    notifyListeners();
  }

  void clearAllFeedbacks() {
    _feedbacks.clear();
    notifyListeners();
  }

  int get totalFeedbacks => _feedbacks.length;
  double get averageRating {
    if (_feedbacks.isEmpty) return 0.0;
    final totalRating = _feedbacks.fold(0, (sum, feedback) => sum + feedback.rating);
    return totalRating / _feedbacks.length;
  }
}

class FeedbackData {
  final String id;
  final String userName;
  final String serviceName;
  final int rating;
  final String comment;
  final String date;
  final bool verified;
  int helpful;

  FeedbackData({
    required this.id,
    required this.userName,
    required this.serviceName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.verified,
    required this.helpful,
  });
}