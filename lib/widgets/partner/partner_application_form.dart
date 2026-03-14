// lib/widgets/partner/partner_application_form.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/app_localizations.dart';
import '../../services/partner_application_service.dart';

class PartnerApplicationForm extends StatefulWidget {
  final String? userId;
  final Function(String)? onSuccess;

  const PartnerApplicationForm({
    super.key,
    this.userId,
    this.onSuccess,
  });

  @override
  State<PartnerApplicationForm> createState() => _PartnerApplicationFormState();
}

class _PartnerApplicationFormState extends State<PartnerApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _partnerService = PartnerApplicationService();
  
  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _referralController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  
  // Form state
  String _selectedExperience = '1-2 years';
  String _selectedVehicleType = 'Two Wheeler';
  List<String> _selectedServices = [];
  bool _isSubmitting = false;
  
  // Available options
  final List<String> _experienceOptions = [
    '1-2 years',
    '3-5 years',
    '5-10 years',
    '10+ years',
  ];
  
  final List<String> _vehicleOptions = [
    'Two Wheeler',
    'Three Wheeler',
    'Four Wheeler',
    'Tractor',
    'Truck',
    'No Vehicle',
  ];
  
  final List<String> _serviceOptions = [
    'Soil & Water Testing',
    'Ploughing Services',
    'Cultivation Services',
    'Fertilizer & Pesticides',
    'Borewell Services',
    'Irrigation Services',
    'Transport Services',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _vehicleNumberController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _accountHolderController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _referralController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FDF0),
      appBar: AppBar(
        title: Text(
          'Partner Application',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF059669),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.handshake,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Join AgriCare Partner Network',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill out the form below to become our trusted partner',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Personal Information Section
              _buildSectionHeader('Personal Information', Icons.person),
              _buildInputField('Full Name', _fullNameController, 'Enter your full name'),
              _buildInputField('Email Address', _emailController, 'Enter your email', keyboardType: TextInputType.emailAddress),
              _buildInputField('Phone Number', _phoneController, 'Enter your phone number', keyboardType: TextInputType.phone),
              
              const SizedBox(height: 24),
              
              // Address Section
              _buildSectionHeader('Address Information', Icons.location_on),
              _buildInputField('Address', _addressController, 'Enter your full address', maxLines: 2),
              Row(
                children: [
                  Expanded(child: _buildInputField('City', _cityController, 'Enter city')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInputField('State', _stateController, 'Enter state')),
                ],
              ),
              _buildInputField('Pincode', _pincodeController, 'Enter pincode', keyboardType: TextInputType.number),
              
              const SizedBox(height: 24),
              
              // Professional Information Section
              _buildSectionHeader('Professional Information', Icons.work),
              _buildDropdownField('Experience in Agriculture', _selectedExperience, _experienceOptions, (value) {
                setState(() => _selectedExperience = value!);
              }),
              _buildServicesSelection(),
              _buildDropdownField('Vehicle Type', _selectedVehicleType, _vehicleOptions, (value) {
                setState(() => _selectedVehicleType = value!);
              }),
              if (_selectedVehicleType != 'No Vehicle')
                _buildInputField('Vehicle Number', _vehicleNumberController, 'Enter vehicle registration number'),
              
              const SizedBox(height: 24),
              
              // Banking Information Section
              _buildSectionHeader('Banking Information', Icons.account_balance),
              _buildInputField('Bank Account Number', _bankAccountController, 'Enter account number', keyboardType: TextInputType.number),
              _buildInputField('IFSC Code', _ifscController, 'Enter IFSC code'),
              _buildInputField('Account Holder Name', _accountHolderController, 'Enter account holder name'),
              
              const SizedBox(height: 24),
              
              // Identity Information Section
              _buildSectionHeader('Identity Information', Icons.badge),
              _buildInputField('Aadhar Number', _aadharController, 'Enter 12-digit Aadhar number', keyboardType: TextInputType.number),
              _buildInputField('PAN Number', _panController, 'Enter PAN number'),
              
              const SizedBox(height: 24),
              
              // Additional Information Section
              _buildSectionHeader('Additional Information', Icons.info),
              _buildInputField('Referral Code (Optional)', _referralController, 'Enter referral code if any'),
              _buildInputField('Additional Information', _additionalInfoController, 'Tell us more about yourself and your experience', maxLines: 3),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit Application',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Terms and Conditions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'By submitting this application, you agree to our terms and conditions. We will review your application and contact you within 2-3 business days.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF059669), size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              if (label == 'Email Address' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              if (label == 'Phone Number' && !RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                return 'Please enter a valid 10-digit phone number';
              }
              if (label == 'Pincode' && !RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
                return 'Please enter a valid 6-digit pincode';
              }
              if (label == 'Aadhar Number' && !RegExp(r'^[0-9]{12}$').hasMatch(value.trim())) {
                return 'Please enter a valid 12-digit Aadhar number';
              }
              if (label == 'PAN Number' && !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value.trim().toUpperCase())) {
                return 'Please enter a valid PAN number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services You Can Provide',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _serviceOptions.map((service) {
                return CheckboxListTile(
                  title: Text(
                    service,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  value: _selectedServices.contains(service),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedServices.add(service);
                      } else {
                        _selectedServices.remove(service);
                      }
                    });
                  },
                  activeColor: const Color(0xFF059669),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),
          if (_selectedServices.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Please select at least one service',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.red.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service you can provide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final application = PartnerApplication(
        id: '', // Will be set by Firestore
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        experience: _selectedExperience,
        services: _selectedServices,
        vehicleType: _selectedVehicleType,
        vehicleNumber: _vehicleNumberController.text.trim(),
        bankAccountNumber: _bankAccountController.text.trim(),
        ifscCode: _ifscController.text.trim().toUpperCase(),
        accountHolderName: _accountHolderController.text.trim(),
        aadharNumber: _aadharController.text.trim(),
        panNumber: _panController.text.trim().toUpperCase(),
        referralCode: _referralController.text.trim(),
        additionalInfo: _additionalInfoController.text.trim(),
        applicationDate: DateTime.now(),
        status: 'pending',
        userId: widget.userId,
      );

      final applicationId = await _partnerService.submitApplication(application);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.check_circle, color: Colors.green.shade600),
                  ),
                  const SizedBox(width: 12),
                  const Text('Application Submitted!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thank you for your interest in becoming an AgriCare partner!',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application ID: ${applicationId.substring(0, 8).toUpperCase()}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We will review your application and contact you within 2-3 business days.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close form
                    if (widget.onSuccess != null) {
                      widget.onSuccess!(applicationId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting application: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}