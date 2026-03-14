// lib/widgets/service_modal.dart

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/app_localizations.dart';
import '../booking/booking_form.dart';

class ServiceModal extends StatelessWidget {
  final Service service;
  final Map<String, String> bookingDetails;
  final Function(String, String) onInputChange;
  final Future<void> Function(SubService) onSubmit;
  final bool isBooking;

  const ServiceModal({
    super.key,
    required this.service,
    required this.bookingDetails,
    required this.onInputChange,
    required this.onSubmit,
    required this.isBooking,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF047857),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ...service.subServices.map(
                (sub) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SubServiceCard(
                    subService: sub,
                    parentService: service,
                    bookingDetails: bookingDetails,
                    onInputChange: onInputChange,
                    onSubmit: onSubmit,
                    isBooking: isBooking,
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

class SubServiceCard extends StatefulWidget {
  final SubService subService;
  final Service parentService;
  final Map<String, String> bookingDetails;
  final Function(String, String) onInputChange;
  final Future<void> Function(SubService) onSubmit;
  final bool isBooking;

  const SubServiceCard({
    super.key,
    required this.subService,
    required this.parentService,
    required this.bookingDetails,
    required this.onInputChange,
    required this.onSubmit,
    required this.isBooking,
  });

  @override
  State<SubServiceCard> createState() => _SubServiceCardState();
}

class _SubServiceCardState extends State<SubServiceCard> {
  bool isFormVisible = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subService.name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    widget.subService.price,
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isFormVisible = !isFormVisible;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  isFormVisible ? loc.translate('close_form') : loc.translate('book_now'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (isFormVisible)
            BookingForm(
              subService: widget.subService,
              bookingDetails: widget.bookingDetails,
              onInputChange: widget.onInputChange,
              onSubmit: widget.onSubmit,
              isBooking: widget.isBooking,
            ),
        ],
      ),
    );
  }
}
