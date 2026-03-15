// lib/widgets/booking_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import '../../services/app_localizations.dart';

class BookingForm extends StatefulWidget {
  final SubService subService;
  final Map<String, String> bookingDetails;
  final Function(String, String) onInputChange;
  final Future<void> Function(SubService) onSubmit;
  final bool isBooking;

  const BookingForm({
    super.key,
    required this.subService,
    required this.bookingDetails,
    required this.onInputChange,
    required this.onSubmit,
    required this.isBooking,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dateController;
  late TextEditingController _areaController;
  late TextEditingController _personsController;
  late TextEditingController _daysController;
  late TextEditingController _quantityController;
  late TextEditingController _kilometersController;
  
  double _calculatedAmount = 0.0;
  double _ratePerAcre = 0.0;
  double _ratePerPersonPerDay = 0.0;
  double _pricePerUnit = 0.0;
  double _ratePerKm = 0.0;
  
  // Product selection for fertilizers and pesticides
  String? _selectedProduct;
  final Map<String, double> _fertilizerProducts = {
    'NPK Fertilizer (50kg bag)': 2500.0,
    'Urea (50kg bag)': 1200.0,
    'DAP Fertilizer (50kg bag)': 2800.0,
    'Organic Compost (50kg bag)': 800.0,
    'Potash Fertilizer (50kg bag)': 2200.0,
  };
  
  final Map<String, double> _pesticideProducts = {
    'Insecticide Spray (1L bottle)': 450.0,
    'Fungicide Powder (500g pack)': 320.0,
    'Herbicide Solution (1L bottle)': 380.0,
    'Bio-Pesticide (500ml bottle)': 280.0,
    'Neem Oil (1L bottle)': 250.0,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bookingDetails['name'] ?? '');
    _phoneController = TextEditingController(text: widget.bookingDetails['phone'] ?? '');
    _addressController = TextEditingController(text: widget.bookingDetails['address'] ?? '');
    _dateController = TextEditingController(text: widget.bookingDetails['date'] ?? '');
    _areaController = TextEditingController(text: widget.bookingDetails['area'] ?? '');
    _personsController = TextEditingController(text: widget.bookingDetails['persons'] ?? '');
    _daysController = TextEditingController(text: widget.bookingDetails['days'] ?? '');
    _quantityController = TextEditingController(text: widget.bookingDetails['quantity'] ?? '');
    _kilometersController = TextEditingController(text: widget.bookingDetails['kilometers'] ?? '');
    
    // Initialize selected product from booking details
    _selectedProduct = widget.bookingDetails['selectedProduct'];
    
    // Extract rate from service price
    _extractRateFromPrice();
    
    // Schedule initial calculations for next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Calculate initial amount if area is already provided
        if (_areaController.text.isNotEmpty) {
          _calculateAmount();
        }
        
        // Calculate initial amount if persons and days are already provided
        if (_personsController.text.isNotEmpty && _daysController.text.isNotEmpty) {
          _calculateCultivationAmount();
        }
        
        // Calculate initial amount if product and quantity are already provided
        if (_selectedProduct != null && _quantityController.text.isNotEmpty) {
          _calculateProductAmount();
        }
        
        // Calculate initial amount if kilometers are already provided for transport services
        if (_kilometersController.text.isNotEmpty) {
          _calculateTransportAmount();
        }
      }
    });
  }
  
  void _extractRateFromPrice() {
    // Extract numeric value from price string like "₹1500" or "₹2000"
    final priceString = widget.subService.price;
    final numericString = priceString.replaceAll(RegExp(r'[^\d]'), '');
    if (numericString.isNotEmpty) {
      if (_isCultivationService()) {
        _ratePerPersonPerDay = double.tryParse(numericString) ?? 0.0;
      } else if (_isFertilizerService() || _isPesticideService()) {
        _pricePerUnit = double.tryParse(numericString) ?? 0.0;
      } else if (_isTransportService()) {
        _ratePerKm = double.tryParse(numericString) ?? 0.0;
      } else {
        _ratePerAcre = double.tryParse(numericString) ?? 0.0;
      }
    }
  }
  
  void _calculateAmount() {
    final area = double.tryParse(_areaController.text) ?? 0.0;
    final newAmount = area * _ratePerAcre;
    
    if (mounted && _calculatedAmount != newAmount) {
      setState(() {
        _calculatedAmount = newAmount;
      });
      // Update booking details with calculated amount
      widget.onInputChange('calculatedAmount', _calculatedAmount.toString());
    }
  }
  
  void _calculateCultivationAmount() {
    final persons = double.tryParse(_personsController.text) ?? 0.0;
    final days = double.tryParse(_daysController.text) ?? 0.0;
    final newAmount = persons * days * _ratePerPersonPerDay;
    
    if (mounted && _calculatedAmount != newAmount) {
      setState(() {
        _calculatedAmount = newAmount;
      });
      // Update booking details with calculated amount
      widget.onInputChange('calculatedAmount', _calculatedAmount.toString());
    }
  }
  
  void _calculateProductAmount() {
    if (_selectedProduct == null) return;
    
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    double productPrice = 0.0;
    
    if (_isFertilizerService()) {
      productPrice = _fertilizerProducts[_selectedProduct] ?? 0.0;
    } else if (_isPesticideService()) {
      productPrice = _pesticideProducts[_selectedProduct] ?? 0.0;
    }
    
    final newAmount = quantity * productPrice;
    
    if (mounted && _calculatedAmount != newAmount) {
      setState(() {
        _calculatedAmount = newAmount;
      });
      // Update booking details with calculated amount
      widget.onInputChange('calculatedAmount', _calculatedAmount.toString());
    }
  }
  
  void _calculateTransportAmount() {
    final kilometers = double.tryParse(_kilometersController.text) ?? 0.0;
    final newAmount = kilometers * _ratePerKm;
    
    if (mounted && _calculatedAmount != newAmount) {
      setState(() {
        _calculatedAmount = newAmount;
      });
      // Update booking details with calculated amount
      widget.onInputChange('calculatedAmount', _calculatedAmount.toString());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _areaController.dispose();
    _personsController.dispose();
    _daysController.dispose();
    _quantityController.dispose();
    _kilometersController.dispose();
    super.dispose();
  }

  void _updateField(String field, String value) {
    widget.onInputChange(field, value);
    
    // Schedule calculations for next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Update calculated amount when area changes
        if (field == 'area') {
          _calculateAmount();
          // Pass calculated amount to booking details
          widget.onInputChange('calculatedAmount', _calculatedAmount.toString());
        }
        // Update calculated amount when persons or days change for cultivation services
        if (field == 'persons' || field == 'days') {
          _calculateCultivationAmount();
          // Pass calculated amount to booking details
          widget.onInputChange('calculatedAmount', _calculatedAmount.toString());
        }
        // Update calculated amount when quantity changes for fertilizer/pesticide services
        if (field == 'quantity' || field == 'selectedProduct') {
          _calculateProductAmount();
          // Pass calculated amount to booking details
          widget.onInputChange('calculatedAmount', _calculatedAmount.toString());
        }
        // Update calculated amount when kilometers change for transport services
        if (field == 'kilometers') {
          _calculateTransportAmount();
          // Pass calculated amount to booking details
          widget.onInputChange('calculatedAmount', _calculatedAmount.toString());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${loc.translate('booking_for')} ${widget.subService.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildInputField(
                context: context,
                label: loc.translate('name'),
                name: 'name',
                controller: _nameController,
                onChanged: _updateField,
                keyboardType: TextInputType.name,
              ),
              _buildInputField(
                context: context,
                label: loc.translate('phone_number'),
                name: 'phone',
                controller: _phoneController,
                onChanged: _updateField,
                keyboardType: TextInputType.phone,
              ),
              _buildInputField(
                context: context,
                label: loc.translate('address'),
                name: 'address',
                controller: _addressController,
                onChanged: _updateField,
                keyboardType: TextInputType.streetAddress,
              ),
              // Add Area field for ploughing services only
              if (_isPloughingService())
                _buildAreaInputField(context),
              // Add Bill Calculator for ploughing services only
              if (_isPloughingService())
                _buildBillCalculator(context),
              // Add Persons and Days fields for cultivation services only
              if (_isCultivationService()) ...[
                _buildPersonsInputField(context),
                _buildDaysInputField(context),
                _buildCultivationBillCalculator(context),
              ],
              // Add Product Selection and Quantity fields for fertilizer services
              if (_isFertilizerService()) ...[
                _buildFertilizerProductSelector(context),
                _buildQuantityInputField(context, 'fertilizer'),
                _buildProductBillCalculator(context, 'fertilizer'),
              ],
              // Add Product Selection and Quantity fields for pesticide services
              if (_isPesticideService()) ...[
                _buildPesticideProductSelector(context),
                _buildQuantityInputField(context, 'pesticide'),
                _buildProductBillCalculator(context, 'pesticide'),
              ],
              // Add Kilometers field for transport services only
              if (_isTransportService()) ...[
                _buildKilometersInputField(context),
                _buildTransportBillCalculator(context),
              ],
              _buildDateInput(context),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: widget.isBooking
                    ? null // Disable button when booking
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await widget.onSubmit(widget.subService);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: widget.isBooking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        loc.translate('confirm_booking'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required String name,
    required TextEditingController controller,
    required Function(String, String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4.0),
          TextFormField(
            controller: controller,
            onChanged: (val) => onChanged(name, val),
            keyboardType: keyboardType,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.5,
                ),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return '$label is required';
              }
              if (name == 'phone') {
                final phoneRegex = RegExp(r'^[0-9]{10}$');
                if (!phoneRegex.hasMatch(val.trim())) {
                  return 'Please enter a valid 10-digit phone number';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('service_date'),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4.0),
          TextFormField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.5,
                ),
              ),
              hintText: loc.translate('select_date'),
              hintStyle: TextStyle(color: Colors.grey.shade600),
              suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
            ),
            onTap: () async {
              // Hide keyboard first
              FocusScope.of(context).unfocus();
              
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              
              if (pickedDate != null) {
                final formattedDate = pickedDate.toIso8601String().split('T')[0];
                _dateController.text = formattedDate;
                _updateField('date', formattedDate);
              }
            },
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Service date is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  bool _isPloughingService() {
    // Check if this is a ploughing service that needs area calculation
    // Use id if available, otherwise fall back to name checking
    if (widget.subService.id != null) {
      final serviceId = widget.subService.id!.toLowerCase();
      return serviceId.contains('ploughing') || 
             serviceId.contains('plough') ||
             serviceId.contains('bullock') ||
             serviceId.contains('rotavator') ||
             serviceId.contains('harrow') ||
             serviceId.contains('leveling');
    }
    
    // Fallback to name checking for backward compatibility
    final serviceName = widget.subService.name.toLowerCase();
    return serviceName.contains('ploughing') || 
           serviceName.contains('plough') ||
           serviceName.contains('bullock') ||
           serviceName.contains('rotavator') ||
           serviceName.contains('harrow') ||
           serviceName.contains('land leveling') ||
           // Kannada keywords
           serviceName.contains('ಉಳುಮೆ') ||
           serviceName.contains('ಎತ್ತು') ||
           serviceName.contains('ರೊಟಾವೇಟರ್') ||
           // Hindi keywords
           serviceName.contains('जुताई') ||
           serviceName.contains('बैल');
  }
  
  bool _isCultivationService() {
    // Check if this is a cultivation service that needs person-based calculation
    if (widget.subService.id != null) {
      final serviceId = widget.subService.id!.toLowerCase();
      return serviceId.contains('seed') || 
             serviceId.contains('sowing') ||
             serviceId.contains('transplanting') ||
             serviceId.contains('weeding') ||
             serviceId.contains('intercultivation') ||
             serviceId.contains('mulching') ||
             serviceId.contains('harvesting');
    }
    
    // Fallback to name checking
    final serviceName = widget.subService.name.toLowerCase();
    return serviceName.contains('seed sowing') || 
           serviceName.contains('transplanting') ||
           serviceName.contains('weeding') ||
           serviceName.contains('intercultivation') ||
           serviceName.contains('mulching') ||
           serviceName.contains('harvesting') ||
           // Kannada keywords
           serviceName.contains('ಬೀಜ') ||
           serviceName.contains('ನಾಟಿ') ||
           serviceName.contains('ಕಳೆ') ||
           serviceName.contains('ಕೊಯ್ಲು') ||
           // Hindi keywords
           serviceName.contains('बीज') ||
           serviceName.contains('रोपाई') ||
           serviceName.contains('कटाई');
  }
  
  bool _isFertilizerService() {
    // Check if this is a fertilizer service that needs product selection
    if (widget.subService.id != null) {
      final serviceId = widget.subService.id!.toLowerCase();
      return serviceId.contains('fertilizer') || 
             serviceId.contains('npk') ||
             serviceId.contains('urea') ||
             serviceId.contains('compost') ||
             serviceId.contains('organic');
    }
    
    // Fallback to name checking
    final serviceName = widget.subService.name.toLowerCase();
    return serviceName.contains('fertilizer') || 
           serviceName.contains('npk') ||
           serviceName.contains('urea') ||
           serviceName.contains('compost') ||
           serviceName.contains('organic fertilizer') ||
           // Kannada keywords
           serviceName.contains('ರಸಗೊಬ್ಬರ') ||
           serviceName.contains('ಸಾವಯವ') ||
           // Hindi keywords
           serviceName.contains('उर्वरक') ||
           serviceName.contains('जैविक');
  }
  
  bool _isPesticideService() {
    // Check if this is a pesticide service that needs product selection
    if (widget.subService.id != null) {
      final serviceId = widget.subService.id!.toLowerCase();
      return serviceId.contains('pesticide') || 
             serviceId.contains('insecticide') ||
             serviceId.contains('fungicide') ||
             serviceId.contains('herbicide') ||
             serviceId.contains('bio') ||
             serviceId.contains('spray');
    }
    
    // Fallback to name checking
    final serviceName = widget.subService.name.toLowerCase();
    return serviceName.contains('pesticide') || 
           serviceName.contains('insecticide') ||
           serviceName.contains('fungicide') ||
           serviceName.contains('herbicide') ||
           serviceName.contains('bio-pesticide') ||
           serviceName.contains('spraying') ||
           // Kannada keywords
           serviceName.contains('ಕೀಟನಾಶಕ') ||
           serviceName.contains('ಸಿಂಪಡಿಸುವಿಕೆ') ||
           // Hindi keywords
           serviceName.contains('कीटनाशक') ||
           serviceName.contains('छिड़काव');
  }
  
  bool _isTransportService() {
    // Check if this is a transport service that needs kilometers input
    if (widget.subService.id != null) {
      final serviceId = widget.subService.id!.toLowerCase();
      return serviceId.contains('transport') || 
             serviceId.contains('delivery') ||
             serviceId.contains('livestock') ||
             serviceId.contains('equipment') ||
             serviceId.contains('storage');
    }
    
    // Fallback to name checking
    final serviceName = widget.subService.name.toLowerCase();
    return serviceName.contains('transport') || 
           serviceName.contains('delivery') ||
           serviceName.contains('transportation') ||
           serviceName.contains('/km') ||
           // Kannada keywords
           serviceName.contains('ಸಾರಿಗೆ') ||
           serviceName.contains('ವಿತರಣೆ') ||
           // Hindi keywords
           serviceName.contains('परिवहन') ||
           serviceName.contains('डिलीवरी');
  }

  Widget _buildAreaInputField(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('area_acres'),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4.0),
          TextFormField(
            controller: _areaController,
            onChanged: (val) {
              _updateField('area', val);
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.5,
                ),
              ),
              hintText: loc.translate('enter_area_acres'),
              hintStyle: TextStyle(color: Colors.grey.shade600),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return loc.translate('area_required');
              }
              final area = double.tryParse(val.trim());
              if (area == null || area <= 0) {
                return loc.translate('valid_area');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillCalculator(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFF10B981), width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: const Color(0xFF059669),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.translate('bill_calculator'),
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('rate_per_acre'),
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  '₹${_ratePerAcre.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              _areaController.text.isEmpty 
                  ? loc.translate('enter_area_calculate')
                  : '${loc.translate('total_amount')} ₹${_calculatedAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12.0,
                color: _areaController.text.isEmpty 
                    ? Colors.grey.shade600 
                    : const Color(0xFF059669),
                fontWeight: _areaController.text.isEmpty 
                    ? FontWeight.normal 
                    : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonsInputField(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('number_of_persons'),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4.0),
          TextFormField(
            controller: _personsController,
            onChanged: (val) {
              _updateField('persons', val);
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.5,
                ),
              ),
              hintText: loc.translate('enter_number_persons'),
              hintStyle: TextStyle(color: Colors.grey.shade600),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return loc.translate('persons_required');
              }
              final persons = int.tryParse(val.trim());
              if (persons == null || persons <= 0) {
                return loc.translate('valid_persons');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaysInputField(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('number_of_days'),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4.0),
          TextFormField(
            controller: _daysController,
            onChanged: (val) {
              _updateField('days', val);
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.5,
                ),
              ),
              hintText: loc.translate('enter_number_days'),
              hintStyle: TextStyle(color: Colors.grey.shade600),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return loc.translate('days_required');
              }
              final days = int.tryParse(val.trim());
              if (days == null || days <= 0) {
                return loc.translate('valid_days');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCultivationBillCalculator(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFF10B981), width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: const Color(0xFF059669),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.translate('bill_calculator'),
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('rate_per_person_day'),
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  '₹${_ratePerPersonPerDay.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            if (_personsController.text.isNotEmpty && _daysController.text.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('persons_days'),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${_personsController.text} × ${_daysController.text} = ${(int.tryParse(_personsController.text) ?? 0) * (int.tryParse(_daysController.text) ?? 0)}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
            ],
            Text(
              (_personsController.text.isEmpty || _daysController.text.isEmpty)
                  ? loc.translate('enter_persons_days_calculate')
                  : '${loc.translate('total_amount')} ₹${_calculatedAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12.0,
                color: (_personsController.text.isEmpty || _daysController.text.isEmpty)
                    ? Colors.grey.shade600 
                    : const Color(0xFF059669),
                fontWeight: (_personsController.text.isEmpty || _daysController.text.isEmpty)
                    ? FontWeight.normal 
                    : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilizerProductSelector(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('select_fertilizer_product'),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProduct,
                hint: Text(
                  loc.translate('choose_fertilizer'),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                isExpanded: true,
                items: _fertilizerProducts.keys.map((String product) {
                  return DropdownMenuItem<String>(
                    value: product,
                    child: Row(
                      children: [
                        Icon(Icons.eco, color: Colors.green.shade600, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '₹${_fertilizerProducts[product]!.toStringAsFixed(0)} ${loc.translate('per_unit')}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProduct = newValue;
                  });
                  _updateField('selectedProduct', newValue ?? '');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPesticideProductSelector(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('select_pesticide_product'),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProduct,
                hint: Text(
                  loc.translate('choose_pesticide'),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                isExpanded: true,
                items: _pesticideProducts.keys.map((String product) {
                  return DropdownMenuItem<String>(
                    value: product,
                    child: Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.orange.shade600, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '₹${_pesticideProducts[product]!.toStringAsFixed(0)} ${loc.translate('per_unit')}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProduct = newValue;
                  });
                  _updateField('selectedProduct', newValue ?? '');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInputField(BuildContext context, String serviceType) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            serviceType == 'fertilizer' ? loc.translate('quantity_bags_packs') : loc.translate('quantity_bottles_packs'),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4.0),
          TextFormField(
            controller: _quantityController,
            onChanged: (val) {
              _updateField('quantity', val);
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.5,
                ),
              ),
              hintText: serviceType == 'fertilizer' 
                  ? loc.translate('enter_bags_packs')
                  : loc.translate('enter_bottles_packs'),
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(
                serviceType == 'fertilizer' ? Icons.eco : Icons.bug_report,
                color: serviceType == 'fertilizer' ? Colors.green.shade600 : Colors.orange.shade600,
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return loc.translate('quantity_required');
              }
              final quantity = int.tryParse(val.trim());
              if (quantity == null || quantity <= 0) {
                return loc.translate('valid_quantity');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductBillCalculator(BuildContext context, String serviceType) {
    final loc = AppLocalizations.of(context);
    final productMap = serviceType == 'fertilizer' ? _fertilizerProducts : _pesticideProducts;
    final productPrice = _selectedProduct != null ? productMap[_selectedProduct] ?? 0.0 : 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFF10B981), width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: const Color(0xFF059669),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  serviceType == 'fertilizer' ? loc.translate('fertilizer_bill_calculator') : loc.translate('pesticide_bill_calculator'),
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (_selectedProduct != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('selected_product'),
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _selectedProduct!,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('price_per_unit'),
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Text(
                    '₹${productPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              if (_quantityController.text.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.translate('quantity_price'),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '$quantity × ₹${productPrice.toStringAsFixed(0)} = ₹${(quantity * productPrice).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
              ],
            ],
            Text(
              (_selectedProduct == null || _quantityController.text.isEmpty)
                  ? loc.translate('select_product_quantity')
                  : '${loc.translate('total_amount')} ₹${_calculatedAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12.0,
                color: (_selectedProduct == null || _quantityController.text.isEmpty)
                    ? Colors.grey.shade600 
                    : const Color(0xFF059669),
                fontWeight: (_selectedProduct == null || _quantityController.text.isEmpty)
                    ? FontWeight.normal 
                    : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKilometersInputField(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('distance_kilometers'),
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4.0),
          TextFormField(
            controller: _kilometersController,
            onChanged: (val) {
              _updateField('kilometers', val);
            },
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: Color(0xFF10B981),
                  width: 1.5,
                ),
              ),
              hintText: loc.translate('enter_distance_km'),
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(
                Icons.local_shipping,
                color: Colors.blue.shade600,
              ),
              suffixText: 'km',
              suffixStyle: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return loc.translate('distance_required');
              }
              final kilometers = double.tryParse(val.trim());
              if (kilometers == null || kilometers <= 0) {
                return loc.translate('valid_distance');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransportBillCalculator(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final kilometers = double.tryParse(_kilometersController.text) ?? 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFF10B981), width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: const Color(0xFF059669),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.translate('transport_bill_calculator'),
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('rate_per_kilometer'),
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  '₹${_ratePerKm.toStringAsFixed(0)}/km',
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            if (_kilometersController.text.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('distance_rate'),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${kilometers.toStringAsFixed(1)} km × ₹${_ratePerKm.toStringAsFixed(0)} = ₹${(kilometers * _ratePerKm).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
            ],
            Text(
              _kilometersController.text.isEmpty
                  ? loc.translate('enter_distance_calculate')
                  : '${loc.translate('total_amount')} ₹${_calculatedAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12.0,
                color: _kilometersController.text.isEmpty
                    ? Colors.grey.shade600 
                    : const Color(0xFF059669),
                fontWeight: _kilometersController.text.isEmpty
                    ? FontWeight.normal 
                    : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
