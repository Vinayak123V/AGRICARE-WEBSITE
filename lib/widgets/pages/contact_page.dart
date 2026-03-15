// lib/widgets/pages/contact_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/app_localizations.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            AppLocalizations.of(context).translate('contact_us'),
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            AppLocalizations.of(context).translate('were_here_to_help'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // Contact Cards
          Row(
            children: [
              Expanded(
                  child: _buildContactCard(
                      context, 'phone', '9483-123-4567', Icons.phone)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildContactCard(
                      context, 'email', 'support@agricare.com', Icons.email)),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                  child: _buildContactCard(
                      context, 'whatsapp', '+91 98765 43210', Icons.message)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildContactCard(context, 'address',
                      'Mahalingapur, India', Icons.location_on)),
            ],
          ),

          const SizedBox(height: 24),

          // Contact Form
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
                  AppLocalizations.of(context).translate('send_us_message'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // Name Field
                TextField(
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('your_name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 16),

                // Email Field
                TextField(
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('your_email'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 16),

                // Phone Field
                TextField(
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('your_phone'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),

                const SizedBox(height: 16),

                // Message Field
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('your_message'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.message),
                  ),
                ),

                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        // Handle form submission
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('send_message'),
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

          const SizedBox(height: 24),

          // Office Locations
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
                  AppLocalizations.of(context).translate('office_locations'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 16),
                _buildOfficeLocation(
                  context,
                  'head_office',
                  '123, Agricultural Colony,\nBangalore - 560001,\nKarnataka, India',
                ),
                const SizedBox(height: 16),
                _buildOfficeLocation(
                  context,
                  'regional_office',
                  '456, Farm Road,\nMahalingapur - 580030,\nKarnataka, India',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Social Media
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
                  AppLocalizations.of(context).translate('follow_us'),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialIcon('Facebook', Icons.facebook),
                    _buildSocialIcon('Twitter', Icons.alternate_email),
                    _buildSocialIcon('Instagram', Icons.camera_alt),
                    _buildSocialIcon('LinkedIn', Icons.work),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
      BuildContext context, String titleKey, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.green[600]),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).translate(titleKey),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeLocation(
      BuildContext context, String titleKey, String address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
                Text(
                  address,
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

  Widget _buildSocialIcon(String platform, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 24, color: Colors.grey[600]),
    );
  }
}
