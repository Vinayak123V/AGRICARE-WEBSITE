// lib/widgets/footer.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/app_localizations.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2D3748),
      ),
      child: Column(
        children: [
          // Main footer content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  // Desktop layout
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildAboutUs(context)),
                      const SizedBox(width: 40),
                      Expanded(child: _buildServices(context)),
                      const SizedBox(width: 40),
                      Expanded(child: _buildQuickLinks(context)),
                      const SizedBox(width: 40),
                      Expanded(child: _buildContactUs(context)),
                    ],
                  );
                } else {
                  // Mobile layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAboutUs(context),
                      const SizedBox(height: 32),
                      _buildServices(context),
                      const SizedBox(height: 32),
                      _buildQuickLinks(context),
                      const SizedBox(height: 32),
                      _buildContactUs(context),
                    ],
                  );
                }
              },
            ),
          ),
          
          // Copyright section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade700,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              '© ${DateTime.now().year} ${loc.translate('app_title')}. ${loc.translate('all_rights_reserved')}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutUs(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('about_us'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          loc.translate('about_us_desc'),
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildSocialIcon(Icons.facebook, 'https://facebook.com'),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.alternate_email, 'https://twitter.com'),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.camera_alt, 'https://instagram.com'),
            const SizedBox(width: 12),
            _buildSocialIcon(Icons.link, 'https://linkedin.com'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildServices(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final services = [
      loc.translate('soil_water_testing'),
      loc.translate('ploughing_services'),
      loc.translate('cultivation_services'),
      loc.translate('fertilizer_pesticides'),
      loc.translate('borewell_services'),
      loc.translate('irrigation_services'),
      loc.translate('transport_services'),
      loc.translate('contract_farming'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('our_services'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...services.map((service) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            service,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final links = [
      {'label': loc.translate('home'), 'action': () {}},
      {'label': loc.translate('about_us'), 'action': () {}},
      {'label': loc.translate('our_services'), 'action': () {}},
      {'label': loc.translate('my_bookings'), 'action': () {}},
      {'label': loc.translate('weather_forecast'), 'action': () {}},
      {'label': loc.translate('ai_crop_manager'), 'action': () {}},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('quick_links'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => link['action'] as VoidCallback,
            child: Text(
              link['label'] as String,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildContactUs(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('contact_us'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          Icons.location_on,
          loc.translate('location'),
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          Icons.phone,
          '+91 9483065328',
          onTap: () => _launchURL('tel:+919483065328'),
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          Icons.email,
          'agricare@gmail.com',
          onTap: () => _launchURL('mailto:agricare@gmail.com'),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF10B981),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
