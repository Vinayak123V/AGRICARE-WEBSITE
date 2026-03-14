// lib/widgets/notification_widget.dart

import 'package:flutter/material.dart';
import '../../models/models.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationState notification;
  const NotificationWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    IconData icon;
    
    switch (notification.type) {
      case 'success':
        backgroundColor = const Color(0xFF10B981);
        borderColor = const Color(0xFF059669);
        icon = Icons.check_circle_rounded;
        break;
      case 'error':
        backgroundColor = const Color(0xFFEF4444);
        borderColor = const Color(0xFFDC2626);
        icon = Icons.error_rounded;
        break;
      case 'info':
        backgroundColor = const Color(0xFF3B82F6);
        borderColor = const Color(0xFF2563EB);
        icon = Icons.info_rounded;
        break;
      default:
        backgroundColor = const Color(0xFF6B7280);
        borderColor = const Color(0xFF4B5563);
        icon = Icons.notifications_rounded;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [backgroundColor, borderColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        notification.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
