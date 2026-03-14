// lib/widgets/pages/feedback_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/app_localizations.dart';
import '../../services/feedback_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _selectedFeedbackType = 'general';
  int _selectedRating = 5;
  bool _isSubmitting = false;
  final FeedbackService _feedbackService = FeedbackService();

  @override
  void initState() {
    super.initState();
    debugPrint('🏗️ FeedbackPage: Initializing with FeedbackService instance: ${_feedbackService.hashCode}');
    debugPrint('   Initial feedback count: ${_feedbackService.totalFeedbacks}');
    _feedbackService.addListener(_onFeedbackChanged);
  }

  @override
  void dispose() {
    _feedbackService.removeListener(_onFeedbackChanged);
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onFeedbackChanged() {
    if (mounted) {
      setState(() {});
      debugPrint('🔄 FeedbackPage: UI updated, total feedbacks: ${_feedbackService.totalFeedbacks}');
    }
  }

  void _testFeedbackService() {
    debugPrint('🧪 Testing FeedbackService...');
    _feedbackService.addFeedback(
      userName: 'Test User ${DateTime.now().millisecondsSinceEpoch}',
      serviceName: 'Test Service',
      rating: 5,
      comment: 'This is a test feedback to verify the service is working correctly.',
      feedbackType: 'general',
      context: context, // Pass context for localization
    );
    debugPrint('🧪 Test feedback added');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).translate('feedback'),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Debug info and test button
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      'Total: ${_feedbackService.totalFeedbacks}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: _testFeedbackService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                    ),
                    child: Text(
                      'Test Add',
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            AppLocalizations.of(context).translate('we_value_feedback'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Feedback Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('send_us_feedback'),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('your_name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('your_email'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Rating
                Text(
                  AppLocalizations.of(context).translate('rate_experience'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                        child: Icon(
                          Icons.star,
                          size: 32,
                          color: index < _selectedRating ? Colors.orange[400] : Colors.grey[300],
                        ),
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 16),
                
                // Feedback Type
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('feedback_type'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: [
                    DropdownMenuItem(value: 'general', child: Text(AppLocalizations.of(context).translate('general_feedback'))),
                    DropdownMenuItem(value: 'bug', child: Text(AppLocalizations.of(context).translate('bug_report'))),
                    DropdownMenuItem(value: 'feature', child: Text(AppLocalizations.of(context).translate('feature_request'))),
                    DropdownMenuItem(value: 'complaint', child: Text(AppLocalizations.of(context).translate('complaint'))),
                    DropdownMenuItem(value: 'compliment', child: Text(AppLocalizations.of(context).translate('compliment'))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFeedbackType = value ?? 'general';
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Message Field
                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('your_feedback'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.message),
                    hintText: AppLocalizations.of(context).translate('tell_us_think'),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your feedback';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isSubmitting ? Colors.grey[400] : Colors.green[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MaterialButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Submitting...',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                AppLocalizations.of(context).translate('submit_feedback'),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Feedback Options
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate('quick_feedback'),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickFeedbackChip(context, 'excellent_service'),
                    _buildQuickFeedbackChip(context, 'easy_to_use'),
                    _buildQuickFeedbackChip(context, 'need_improvements'),
                    _buildQuickFeedbackChip(context, 'great_support'),
                    _buildQuickFeedbackChip(context, 'more_features'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFeedbackChip(BuildContext context, String textKey) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Text(
        AppLocalizations.of(context).translate(textKey),
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.green[700],
        ),
      ),
    );
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      debugPrint('🚀 Submit button pressed - starting feedback submission');
      
      try {
        // Store values before clearing form
        final userName = _nameController.text.trim();
        final userEmail = _emailController.text.trim();
        final userComment = _messageController.text.trim();
        final userRating = _selectedRating;
        final userFeedbackType = _selectedFeedbackType;
        
        // Add feedback to the service
        _feedbackService.addFeedback(
          userName: userName,
          serviceName: 'User Feedback', // This will be mapped based on feedback type
          rating: userRating,
          comment: userComment,
          feedbackType: userFeedbackType,
          context: context, // Pass context for localization
        );

        // Clear the form
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        setState(() {
          _selectedRating = 5;
          _selectedFeedbackType = 'general';
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).translate('thank_you_feedback'),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        // Show confirmation dialog instead of navigating away
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                  const SizedBox(width: 8),
                  const Text('Feedback Submitted!'),
                ],
              ),
              content: const Text(
                'Thank you for your feedback! Your review has been added to our public feedback section on the home page.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Continue'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to home page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View on Home Page'),
                ),
              ],
            );
          },
        );

        debugPrint('✅ Feedback submitted successfully by $userName');
      } catch (e) {
        debugPrint('❌ Error submitting feedback: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      debugPrint('❌ Form validation failed');
    }
  }
}
