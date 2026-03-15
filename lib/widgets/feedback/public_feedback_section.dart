// lib/widgets/feedback/public_feedback_section.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/app_localizations.dart';
import '../../services/feedback_service.dart';

class PublicFeedbackSection extends StatefulWidget {
  const PublicFeedbackSection({super.key});

  @override
  State<PublicFeedbackSection> createState() => _PublicFeedbackSectionState();
}

class _PublicFeedbackSectionState extends State<PublicFeedbackSection> {
  final FeedbackService _feedbackService = FeedbackService();

  @override
  void initState() {
    super.initState();
    debugPrint('🏗️ PublicFeedbackSection: Initializing with FeedbackService instance: ${_feedbackService.hashCode}');
    debugPrint('   Initial feedback count: ${_feedbackService.totalFeedbacks}');
    // Listen to feedback changes
    _feedbackService.addListener(_onFeedbackChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize feedback service with current context for localization
    _feedbackService.initializeWithContext(context);
  }

  @override
  void dispose() {
    _feedbackService.removeListener(_onFeedbackChanged);
    super.dispose();
  }

  void _onFeedbackChanged() {
    debugPrint('🔄 PublicFeedbackSection: Feedback changed notification received');
    debugPrint('   Total feedbacks: ${_feedbackService.totalFeedbacks}');
    debugPrint('   Average rating: ${_feedbackService.averageRating.toStringAsFixed(1)}');
    
    if (mounted) {
      setState(() {});
      debugPrint('✅ PublicFeedbackSection: UI updated');
    } else {
      debugPrint('⚠️ PublicFeedbackSection: Widget not mounted, skipping update');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.rate_review, color: Colors.green[700], size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('customer_reviews'),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).translate('real_feedback'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _feedbackService.averageRating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      ' (${_feedbackService.totalFeedbacks})',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Feedback Cards
          ..._feedbackService.feedbacks.map((feedback) => _buildFeedbackCard(feedback)).toList(),
          
          // View More Button
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                _showAllFeedbacksDialog(context);
              },
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              label: Text(
                AppLocalizations.of(context).translate('view_all_reviews'),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                side: BorderSide(color: Colors.green[600]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackData feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info and Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green[100],
                child: Text(
                  feedback.userName[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // User Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          feedback.userName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (feedback.verified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 10, color: Colors.blue[600]),
                                const SizedBox(width: 2),
                                Text(
                                  AppLocalizations.of(context).translate('verified'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback.serviceName,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Date
              Text(
                feedback.date,
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Rating Stars
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < feedback.rating ? Icons.star : Icons.star_border,
                size: 16,
                color: index < feedback.rating ? Colors.amber : Colors.grey[300],
              );
            }),
          ),
          
          const SizedBox(height: 12),
          
          // Comment
          Text(
            feedback.comment,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Helpful Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  '${AppLocalizations.of(context).translate('helpful')} (${feedback.helpful})',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _feedbackService.markHelpful(feedback.id);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('yes'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Not helpful
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('no'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllFeedbacksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.rate_review, color: Colors.green[700], size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate('all_customer_reviews'),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${_feedbackService.totalFeedbacks} ${AppLocalizations.of(context).translate('reviews_average').replaceAll('{rating}', _feedbackService.averageRating.toStringAsFixed(1))}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Feedback List
                Expanded(
                  child: _feedbackService.feedbacks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context).translate('no_reviews_yet'),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context).translate('be_first_review'),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _feedbackService.feedbacks.length,
                          itemBuilder: (context, index) {
                            final feedback = _feedbackService.feedbacks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildFeedbackCard(feedback),
                            );
                          },
                        ),
                ),
                
                // Footer
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          // Navigate to feedback page - you might need to adjust this based on your navigation
                        },
                        icon: const Icon(Icons.add_comment, size: 18),
                        label: Text(AppLocalizations.of(context).translate('leave_review')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.green[600]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


