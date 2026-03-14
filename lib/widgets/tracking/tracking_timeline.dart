// lib/widgets/tracking_timeline.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/live_tracking_models.dart';

class TrackingTimeline extends StatelessWidget {
  final List<TrackingEvent> events;

  const TrackingTimeline({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No tracking events yet',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Journey',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final isLast = index == events.length - 1;
              
              return TimelineItem(
                event: event,
                isLast: isLast,
              );
            },
          ),
        ],
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final TrackingEvent event;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.event,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(event.status),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(event.status),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Event details
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusTitle(event.status),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (event.description != null)
                    Text(
                      event.description!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(event.timestamp),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp);
    }
  }

  String _getStatusTitle(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.assigned:
        return 'Provider Assigned';
      case TrackingStatus.on_way:
        return 'On The Way';
      case TrackingStatus.arriving:
        return 'Arriving Soon';
      case TrackingStatus.in_progress:
        return 'Service In Progress';
      case TrackingStatus.completed:
        return 'Service Completed';
      case TrackingStatus.cancelled:
        return 'Service Cancelled';
    }
  }

  IconData _getStatusIcon(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.assigned:
        return Icons.assignment_ind;
      case TrackingStatus.on_way:
        return Icons.directions_car;
      case TrackingStatus.arriving:
        return Icons.near_me;
      case TrackingStatus.in_progress:
        return Icons.handyman;
      case TrackingStatus.completed:
        return Icons.check_circle;
      case TrackingStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.assigned:
        return Colors.blue;
      case TrackingStatus.on_way:
        return Colors.orange;
      case TrackingStatus.arriving:
        return Colors.deepOrange;
      case TrackingStatus.in_progress:
        return Colors.purple;
      case TrackingStatus.completed:
        return Colors.green;
      case TrackingStatus.cancelled:
        return Colors.red;
    }
  }
}
