// lib/widgets/feedback_section.dart

import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';

class FeedbackSection extends StatefulWidget {
  final Function(String, [String]) showNotification;

  const FeedbackSection({
    super.key,
    required this.showNotification,
  });

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class FeedbackData {
  final String name;
  final String email;
  final String type;
  final String message;
  final DateTime timestamp;

  FeedbackData({
    required this.name,
    required this.email,
    required this.type,
    required this.message,
    required this.timestamp,
  });
}

class _FeedbackSectionState extends State<FeedbackSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedType = 'suggestion';
  bool _isSubmitting = false;
  final List<FeedbackData> _feedbackList = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    
    final loc = AppLocalizations.of(context);
    setState(() => _isSubmitting = true);

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Add feedback to local list
      final feedback = FeedbackData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        type: _selectedType,
        message: _messageController.text.trim(),
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _feedbackList.insert(0, feedback);
      });
      
      // Clear form
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      _formKey.currentState!.reset();
      
      widget.showNotification(
        loc.translate('feedback_success'),
        "success",
      );
      
      debugPrint('✅ Feedback submitted: ${feedback.name} - ${feedback.type}');
    } catch (e) {
      widget.showNotification(
        loc.translate('feedback_error'),
        "error",
      );
      debugPrint("❌ Feedback submission error: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(
            Icons.feedback_outlined,
            size: 48,
            color: const Color(0xFF047857),
          ),
          const SizedBox(height: 16),
          Text(
            loc.translate('feedback_title'),
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF047857),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            loc.translate('feedback_desc'),
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          _buildFeedbackForm(),
        ],
      ),
    );
  }

  Widget _buildFeedbackForm() {
    final loc = AppLocalizations.of(context);
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: loc.translate('feedback_name'),
              prefixIcon: const Icon(Icons.person, color: Color(0xFF047857)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF047857), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: loc.translate('feedback_email'),
              prefixIcon: const Icon(Icons.email, color: Color(0xFF047857)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF047857), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Feedback type dropdown
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: loc.translate('feedback_type'),
              prefixIcon: const Icon(Icons.category, color: Color(0xFF047857)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF047857), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: [
              DropdownMenuItem(value: 'suggestion', child: Text(loc.translate('feedback_type_suggestion'))),
              DropdownMenuItem(value: 'bug', child: Text(loc.translate('feedback_type_bug'))),
              DropdownMenuItem(value: 'compliment', child: Text(loc.translate('feedback_type_compliment'))),
              DropdownMenuItem(value: 'complaint', child: Text(loc.translate('feedback_type_complaint'))),
              DropdownMenuItem(value: 'other', child: Text(loc.translate('feedback_type_other'))),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Message field
          TextFormField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: loc.translate('feedback_message'),
              hintText: loc.translate('feedback_placeholder'),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF047857), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your feedback';
              }
              if (val.trim().length < 10) {
                return 'Feedback must be at least 10 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: const Color(0xFF047857).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      loc.translate('send_feedback'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

}
