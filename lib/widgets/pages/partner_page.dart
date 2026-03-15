// lib/widgets/pages/partner_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/app_localizations.dart';
import '../partner/partner_application_form.dart';

class PartnerPage extends StatelessWidget {
  final String? userId;
  final Function(String)? showNotification;
  
  const PartnerPage({
    super.key,
    this.userId,
    this.showNotification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            AppLocalizations.of(context).translate('be_partner'),
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            AppLocalizations.of(context).translate('join_network'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Benefits Section
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate('partner_benefits'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: _buildBenefit(context, 'more_customers', Icons.people)),
                    Expanded(child: _buildBenefit(context, 'flexible_work', Icons.schedule)),
                    Expanded(child: _buildBenefit(context, 'fair_payments', Icons.payments)),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: _buildBenefit(context, 'training_support', Icons.school)),
                    Expanded(child: _buildBenefit(context, 'insurance_coverage', Icons.health_and_safety)),
                    Expanded(child: _buildBenefit(context, 'community', Icons.groups)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // How it Works
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
                  AppLocalizations.of(context).translate('how_it_works'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildStep(context, '1', 'apply_online', 'fill_application'),
                _buildStep(context, '2', 'verification', 'verify_skills'),
                _buildStep(context, '3', 'training', 'free_training'),
                _buildStep(context, '4', 'start_earning', 'receive_requests'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Requirements
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate('requirements'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildRequirement(context, 'experience_required'),
                _buildRequirement(context, 'valid_id'),
                _buildRequirement(context, 'smartphone_knowledge'),
                _buildRequirement(context, 'bank_account'),
                _buildRequirement(context, 'serve_rural'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // CTA Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.handshake, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).translate('ready_to_join'),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).translate('start_earning_today'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: MaterialButton(
                    onPressed: () => _openPartnerApplication(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text(
                        AppLocalizations.of(context).translate('apply_now'),
                        style: GoogleFonts.poppins(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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

  Widget _buildBenefit(BuildContext context, String titleKey, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.green[600]),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).translate(titleKey),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String titleKey, String descriptionKey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate(titleKey),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  AppLocalizations.of(context).translate(descriptionKey),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(BuildContext context, String requirementKey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).translate(requirementKey),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPartnerApplication(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PartnerApplicationForm(
          userId: userId,
          onSuccess: (applicationId) {
            if (showNotification != null) {
              showNotification!('Partner application submitted successfully! Application ID: ${applicationId.substring(0, 8).toUpperCase()}');
            }
          },
        ),
      ),
    );
  }
}
