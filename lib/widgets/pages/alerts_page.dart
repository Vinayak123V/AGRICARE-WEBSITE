// lib/widgets/pages/alerts_page.dart

import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';

class AlertsPage extends StatefulWidget {
  final int? pendingBookings;
  final int? totalBookings;

  const AlertsPage({
    super.key,
    this.pendingBookings,
    this.totalBookings,
  });

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<AlertItem> _allAlerts = [
    AlertItem(
      id: '1',
      type: AlertType.booking,
      title: 'Booking Confirmed',
      message: 'Your ploughing service booking has been confirmed for tomorrow.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    AlertItem(
      id: '2',
      type: AlertType.payment,
      title: 'Payment Successful',
      message: 'Payment of ₹2000 for tractor service completed successfully.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    AlertItem(
      id: '3',
      type: AlertType.weather,
      title: 'Weather Alert',
      message: 'Heavy rain expected in your area. Consider rescheduling outdoor activities.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: false,
    ),
    AlertItem(
      id: '4',
      type: AlertType.service,
      title: 'Service Provider Update',
      message: 'Your service provider is on the way. ETA: 15 minutes.',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      isRead: true,
    ),
    AlertItem(
      id: '5',
      type: AlertType.promotion,
      title: 'Special Offer',
      message: 'Get 20% off on your next irrigation service booking!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    AlertItem(
      id: '6',
      type: AlertType.system,
      title: 'App Update Available',
      message: 'New features and improvements are available. Update now!',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadAlerts = _allAlerts.where((alert) => !alert.isRead).toList();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Alerts & Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('All'),
                  if (_allAlerts.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _allAlerts.length.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unread'),
                  if (unreadAlerts.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unreadAlerts.length.toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Stats
          _buildQuickStats(),
          
          // Alerts List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlertsList(_allAlerts),
                _buildAlertsList(unreadAlerts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final unreadCount = _allAlerts.where((alert) => !alert.isRead).length;
    final todayCount = _allAlerts.where((alert) => 
      alert.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 1)))
    ).length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Unread',
              unreadCount.toString(),
              Icons.mark_email_unread_rounded,
              const Color(0xFFEF4444),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: _buildStatItem(
              'Today',
              todayCount.toString(),
              Icons.today_rounded,
              const Color(0xFF10B981),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: _buildStatItem(
              'Pending',
              '${widget.pendingBookings ?? 0}',
              Icons.pending_actions_rounded,
              const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsList(List<AlertItem> alerts) {
    if (alerts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_rounded,
              size: 40,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No alerts to show',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re all caught up! New alerts will appear here.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AlertItem alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.isRead ? Colors.transparent : const Color(0xFF10B981),
          width: alert.isRead ? 0 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getAlertColor(alert.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getAlertIcon(alert.type),
            color: _getAlertColor(alert.type),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                alert.title,
                style: TextStyle(
                  fontWeight: alert.isRead ? FontWeight.w500 : FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            if (!alert.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alert.message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(alert.timestamp),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        onTap: () => _handleAlertTap(alert),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAlertAction(alert, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: alert.isRead ? 'unread' : 'read',
              child: Row(
                children: [
                  Icon(
                    alert.isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(alert.isRead ? 'Mark as unread' : 'Mark as read'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Color(0xFFEF4444)),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.booking:
        return Icons.calendar_today_rounded;
      case AlertType.payment:
        return Icons.payment_rounded;
      case AlertType.weather:
        return Icons.cloud_rounded;
      case AlertType.service:
        return Icons.build_rounded;
      case AlertType.promotion:
        return Icons.local_offer_rounded;
      case AlertType.system:
        return Icons.system_update_rounded;
    }
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.booking:
        return const Color(0xFF10B981);
      case AlertType.payment:
        return const Color(0xFF3B82F6);
      case AlertType.weather:
        return const Color(0xFF8B5CF6);
      case AlertType.service:
        return const Color(0xFFF59E0B);
      case AlertType.promotion:
        return const Color(0xFFEC4899);
      case AlertType.system:
        return const Color(0xFF6B7280);
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleAlertTap(AlertItem alert) {
    if (!alert.isRead) {
      setState(() {
        alert.isRead = true;
      });
    }
    
    // Show alert details
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getAlertColor(alert.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAlertIcon(alert.type),
                  color: _getAlertColor(alert.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(alert.title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert.message),
              const SizedBox(height: 16),
              Text(
                'Received: ${_formatTimestamp(alert.timestamp)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _handleAlertAction(AlertItem alert, String action) {
    setState(() {
      switch (action) {
        case 'read':
          alert.isRead = true;
          break;
        case 'unread':
          alert.isRead = false;
          break;
        case 'delete':
          _allAlerts.remove(alert);
          break;
      }
    });

    String message;
    switch (action) {
      case 'read':
        message = 'Marked as read';
        break;
      case 'unread':
        message = 'Marked as unread';
        break;
      case 'delete':
        message = 'Alert deleted';
        break;
      default:
        message = 'Action completed';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var alert in _allAlerts) {
        alert.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All alerts marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

enum AlertType {
  booking,
  payment,
  weather,
  service,
  promotion,
  system,
}

class AlertItem {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  AlertItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}