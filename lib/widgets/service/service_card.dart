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
    final iconFontSize = isMobile ? 36.0 : 48.0;
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.05 : 1.0)
            ..translate(0.0, _isHovered ? -5.0 : 0.0),
          decoration: BoxDecoration(
            gradient: _isHovered 
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF0FDF4),
                      Color(0xFFECFDF5),
                    ],
                  )
                : const LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? const Color(0xFF047857).withOpacity(0.25)
                    : Colors.grey.withOpacity(0.1),
                spreadRadius: _isHovered ? 4 : 1,
                blurRadius: _isHovered ? 20 : 8,
                offset: Offset(0, _isHovered ? 8 : 3),
              ),
            ],
            border: Border.all(
              color: _isHovered 
                  ? const Color(0xFF047857).withOpacity(0.4)
                  : Colors.grey.withOpacity(0.1),
              width: _isHovered ? 2.0 : 1.0,
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
              // Enhanced animated icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isHovered ? [
                      const Color(0xFF047857).withOpacity(0.2),
                      const Color(0xFF10B981).withOpacity(0.3),
                    ] : [
                      const Color(0xFF047857).withOpacity(0.1),
                      const Color(0xFF10B981).withOpacity(0.1),
                    ],
                  ),
                  boxShadow: _isHovered ? [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ] : [
                    BoxShadow(
                      color: const Color(0xFF047857).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF047857).withOpacity(0.2),
                    width: 2,
                  ),
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
