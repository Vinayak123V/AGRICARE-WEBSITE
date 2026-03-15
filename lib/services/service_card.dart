// lib/widgets/service_card.dart

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/app_localizations.dart';

class ServiceCard extends StatefulWidget {
  final Service service;
  final VoidCallback onClick;
  const ServiceCard({super.key, required this.service, required this.onClick});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Responsive sizing
    final iconSize = isMobile ? 80.0 : 110.0;
    final titleFontSize = isMobile ? 14.0 : 17.0;
    final descFontSize = isMobile ? 11.0 : 13.0;
    final verticalPadding = isMobile ? 12.0 : 20.0;
    final horizontalPadding = isMobile ? 8.0 : 16.0;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onClick,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? const Color(0xFF047857).withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                spreadRadius: _isHovered ? 3 : 1,
                blurRadius: _isHovered ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: _isHovered 
                  ? const Color(0xFF047857).withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Circular icon container
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF047857).withOpacity(0.1),
                      const Color(0xFF10B981).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF047857).withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF047857).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(iconSize / 2),
                    child: Image.asset(
                      widget.service.icon,
                      width: iconSize - 16,
                      height: iconSize - 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 8.0 : 12.0),
              // Service name
              Flexible(
                child: Text(
                  widget.service.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF14532D),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: isMobile ? 4.0 : 6.0),
              // Service description
              Flexible(
                child: Text(
                  widget.service.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: descFontSize,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // View details link (only show on hover for desktop)
              if (_isHovered && !isMobile)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    '${AppLocalizations.of(context).translate('view_details')} →',
                    style: const TextStyle(
                      color: Color(0xFF047857),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
