// lib/widgets/service_grid.dart

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../data/services_data.dart';
import '../../services/app_localizations.dart';
import 'service_card.dart';

class ServiceGrid extends StatelessWidget {
  final Function(Service) onServiceClick;
  const ServiceGrid({super.key, required this.onServiceClick});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localizedServices = getLocalizedServices(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    int crossAxisCount = 4; // Default for large screens
    double childAspectRatio = 0.95; // Default aspect ratio
    double mainAxisSpacing = 20.0;
    double crossAxisSpacing = 20.0;
    double titleFontSize = 32.0;
    double subtitleFontSize = 15.0;
    
    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 2;
      childAspectRatio = 0.80; // More vertical space for mobile
      mainAxisSpacing = 12.0;
      crossAxisSpacing = 12.0;
      titleFontSize = 24.0;
      subtitleFontSize = 13.0;
    } else if (screenWidth < 900) {
      // Tablet
      crossAxisCount = 3;
      childAspectRatio = 0.90;
      titleFontSize = 28.0;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          loc.translate('our_services'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF047857),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          loc.translate('services_subtitle'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: screenWidth < 600 ? 20.0 : 32.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: localizedServices.length,
          itemBuilder: (context, index) {
            final service = localizedServices[index];
            return ServiceCard(
              service: service,
              onClick: () => onServiceClick(service),
            );
          },
        ),
      ],
    );
  }
}
