// lib/widgets/pages/edit_profile_page.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/app_localizations.dart';
import '../../services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId;
  final dynamic authService;

  const EditProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userId,
    this.authService,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _occupationController;
  late TextEditingController _farmSizeController;
  
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  String _selectedGender = '';
  DateTime? _selectedDateOfBirth;
  List<String> _selectedCropTypes = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _loadUserProfile();
    _profileService.addListener(_onProfileChanged);
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController(text: widget.userEmail);
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _occupationController = TextEditingController();
    _farmSizeController = TextEditingController();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      await _profileService.initializeProfile(
        widget.userId,
        widget.userEmail,
        widget.userName,
      );
      
      final profile = _profileService.currentProfile;
      if (profile != null) {
        _nameController.text = profile.fullName;
        _phoneController.text = profile.phoneNumber;
        _addressController.text = profile.address;
        _occupationController.text = profile.occupation;
        _farmSizeController.text = profile.farmSize;
        _selectedGender = profile.gender;
        _selectedDateOfBirth = profile.dateOfBirth;
        _selectedCropTypes = List.from(profile.cropTypes);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load profile data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _profileService.removeListener(_onProfileChanged);
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    _buildSimpleProfileDetailsCard(),
                    const SizedBox(height: 24),
                    _buildProfileCompletionCard(),
                    const SizedBox(height: 24),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 20),
                    _buildContactInfoSection(),
                    const SizedBox(height: 20),
                    _buildFarmingInfoSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF047857),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        if (!_isLoading)
          TextButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save, color: Colors.white, size: 18),
            label: Text(
              'Save',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final profile = _profileService.currentProfile;
    final imageSource = _profileService.getProfileImageSource();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF047857),
            const Color(0xFF10B981),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Profile Image Section
          Stack(
            children: [
              Hero(
                tag: 'profile_image',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60, // Increased size for better visibility
                    backgroundColor: Colors.white,
                    backgroundImage: imageSource != null 
                        ? (imageSource.startsWith('data:') 
                            ? MemoryImage(_base64ToUint8List(imageSource))
                            : NetworkImage(imageSource)) as ImageProvider
                        : null,
                    child: imageSource == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                size: 40,
                                color: const Color(0xFF047857).withOpacity(0.7),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              // Enhanced Camera Button with Animation
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF047857), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF047857),
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Image Upload Status Indicator
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Enhanced User Details
          Column(
            children: [
              // Name with Edit Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      profile?.fullName.isNotEmpty == true ? profile!.fullName : widget.userName,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Email with Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: Colors.white.withOpacity(0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.userEmail,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Additional User Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildUserInfoChip(
                    icon: Icons.phone_outlined,
                    label: profile?.phoneNumber.isNotEmpty == true 
                        ? profile!.phoneNumber 
                        : 'Add Phone',
                    isEmpty: profile?.phoneNumber.isEmpty ?? true,
                  ),
                  _buildUserInfoChip(
                    icon: Icons.location_on_outlined,
                    label: profile?.address.isNotEmpty == true 
                        ? 'Location Added' 
                        : 'Add Location',
                    isEmpty: profile?.address.isEmpty ?? true,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Status Badges Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (profile?.isVerified == true)
                    _buildStatusBadge(
                      icon: Icons.verified,
                      label: 'Verified',
                      color: Colors.blue,
                    ),
                  if (profile?.occupation.isNotEmpty == true) ...[
                    const SizedBox(width: 8),
                    _buildStatusBadge(
                      icon: Icons.work_outline,
                      label: profile!.occupation,
                      color: Colors.orange,
                    ),
                  ],
                  if (profile?.farmSize.isNotEmpty == true) ...[
                    const SizedBox(width: 8),
                    _buildStatusBadge(
                      icon: Icons.agriculture,
                      label: profile!.farmSize,
                      color: Colors.green,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleProfileDetailsCard() {
    final profile = _profileService.currentProfile;
    final imageSource = _profileService.getProfileImageSource();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Profile Picture Upload
          Row(
            children: [
              // Profile Picture with Upload Button
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF047857), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey[100],
                      backgroundImage: imageSource != null 
                          ? (imageSource.startsWith('data:') 
                              ? MemoryImage(_base64ToUint8List(imageSource))
                              : NetworkImage(imageSource)) as ImageProvider
                          : null,
                      child: imageSource == null
                          ? Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF047857),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // User Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.fullName.isNotEmpty == true ? profile!.fullName : widget.userName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.userEmail,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (profile?.phoneNumber.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile!.phoneNumber,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Upload Photo Button (Alternative)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showPhotoOptions,
                    icon: const Icon(Icons.upload, size: 16),
                    label: Text(
                      imageSource != null ? 'Change' : 'Upload',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (imageSource != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Photo Added ✓',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick Info Row
          Row(
            children: [
              Expanded(
                child: _buildQuickInfoItem(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: profile?.address.isNotEmpty == true 
                      ? 'Added' 
                      : 'Not set',
                  hasValue: profile?.address.isNotEmpty == true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickInfoItem(
                  icon: Icons.work_outline,
                  label: 'Occupation',
                  value: profile?.occupation.isNotEmpty == true 
                      ? profile!.occupation 
                      : 'Not set',
                  hasValue: profile?.occupation.isNotEmpty == true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickInfoItem(
                  icon: Icons.agriculture,
                  label: 'Farm Size',
                  value: profile?.farmSize.isNotEmpty == true 
                      ? profile!.farmSize 
                      : 'Not set',
                  hasValue: profile?.farmSize.isNotEmpty == true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool hasValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasValue ? const Color(0xFF047857).withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasValue ? const Color(0xFF047857).withOpacity(0.3) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: hasValue ? const Color(0xFF047857) : Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.length > 8 ? '${value.substring(0, 8)}...' : value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: hasValue ? const Color(0xFF047857) : Colors.grey[500],
              fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard() {
    final completeness = _profileService.getProfileCompleteness();
    final percentage = (completeness * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF047857).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_circle,
                  color: Color(0xFF047857),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Completion',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Complete your profile to get better recommendations',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF047857),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: completeness,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF047857)),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_rounded,
          hint: 'Enter your full name',
        ),
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 16),
        _buildGenderField(),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_rounded,
          hint: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
          enabled: false,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone_rounded,
          hint: 'Enter your phone number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on_rounded,
          hint: 'Enter your address',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildFarmingInfoSection() {
    return _buildSection(
      title: 'Farming Information',
      icon: Icons.agriculture,
      children: [
        _buildTextField(
          controller: _occupationController,
          label: 'Occupation',
          icon: Icons.work_rounded,
          hint: 'e.g., Farmer, Agricultural Engineer',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _farmSizeController,
          label: 'Farm Size',
          icon: Icons.landscape_rounded,
          hint: 'e.g., 5 acres, 2 hectares',
        ),
        const SizedBox(height: 16),
        _buildCropTypesField(),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF047857).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF047857),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }





  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(
              icon,
              color: enabled ? const Color(0xFF047857) : Colors.grey,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF047857), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDateOfBirth,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF047857),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDateOfBirth != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDateOfBirth!)
                        : 'Select your date of birth',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _selectedDateOfBirth != null 
                          ? Colors.black87 
                          : Colors.grey[500],
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF047857),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    final genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender.isNotEmpty ? _selectedGender : null,
              hint: Text(
                'Select gender',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF047857)),
              isExpanded: true,
              items: genders.map((gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Color(0xFF047857),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        gender,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value ?? '';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCropTypesField() {
    final cropTypes = [
      'Rice', 'Wheat', 'Corn', 'Sugarcane', 'Cotton', 'Soybeans',
      'Tomatoes', 'Potatoes', 'Onions', 'Carrots', 'Cabbage', 'Spinach',
      'Apples', 'Bananas', 'Oranges', 'Grapes', 'Mangoes', 'Other'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crop Types',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showCropTypesDialog(cropTypes),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.agriculture_rounded,
                  color: Color(0xFF047857),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _selectedCropTypes.isEmpty
                      ? Text(
                          'Select crop types you grow',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        )
                      : Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: _selectedCropTypes.take(3).map((crop) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF047857).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                crop,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF047857),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList()
                            ..addAll(_selectedCropTypes.length > 3 
                                ? [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '+${_selectedCropTypes.length - 3} more',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ]
                                : []),
                        ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF047857),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveProfile,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save_rounded, size: 20),
            label: Text(
              _isLoading ? 'Saving...' : 'Save Changes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF047857),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 20),
            label: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Header with Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF047857).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF047857),
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Update Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to add your profile picture.\nThis will be visible to other users.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Photo Options
              Column(
                children: [
                  _buildPhotoOptionTile(
                    icon: Icons.camera_alt_rounded,
                    title: 'Take Photo',
                    subtitle: 'Use camera to capture a new photo',
                    color: const Color(0xFF047857),
                    onTap: () {
                      Navigator.pop(context);
                      _uploadFromCamera();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPhotoOptionTile(
                    icon: Icons.photo_library_rounded,
                    title: 'Choose from Gallery',
                    subtitle: 'Select an existing photo from your device',
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.pop(context);
                      _uploadFromGallery();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPhotoOptionTile(
                    icon: Icons.link_rounded,
                    title: 'Add Photo URL',
                    subtitle: 'Enter a direct link to your photo',
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.pop(context);
                      _showUrlDialog();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlDialog() {
    final urlController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.link_rounded, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              Text(
                'Photo URL',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter a direct link to your profile photo',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText: 'https://example.com/photo.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  try {
                    await _profileService.setProfileImageUrl(url);
                    Navigator.pop(context);
                    _showSuccessSnackBar('Profile photo updated successfully!');
                  } catch (e) {
                    _showErrorSnackBar('Failed to set photo URL');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: Text(
                'Set Photo',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFromCamera() async {
    try {
      setState(() => _isLoading = true);
      await _profileService.uploadProfileImage(fromCamera: true);
      _showSuccessSnackBar('Profile photo updated from camera!');
    } catch (e) {
      _showErrorSnackBar('Failed to upload photo from camera');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadFromGallery() async {
    try {
      setState(() => _isLoading = true);
      await _profileService.uploadProfileImage(fromCamera: false);
      _showSuccessSnackBar('Profile photo updated from gallery!');
    } catch (e) {
      _showErrorSnackBar('Failed to upload photo from gallery');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF047857),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _showCropTypesDialog(List<String> cropTypes) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.agriculture_rounded, color: Color(0xFF047857)),
                  const SizedBox(width: 8),
                  Text(
                    'Select Crop Types',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: cropTypes.length,
                  itemBuilder: (context, index) {
                    final crop = cropTypes[index];
                    final isSelected = _selectedCropTypes.contains(crop);
                    
                    return CheckboxListTile(
                      title: Text(
                        crop,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: isSelected,
                      activeColor: const Color(0xFF047857),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            _selectedCropTypes.add(crop);
                          } else {
                            _selectedCropTypes.remove(crop);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Update main widget
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Uint8List _base64ToUint8List(String base64String) {
    // Remove data URL prefix if present
    final base64Data = base64String.split(',').last;
    return base64Decode(base64Data);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF047857),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      // Validate required fields
      if (_nameController.text.trim().isEmpty) {
        _showErrorSnackBar('Please enter your full name');
        return;
      }

      // Update profile with all the collected data
      await _profileService.updateProfile(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        dateOfBirth: _selectedDateOfBirth,
        gender: _selectedGender,
        occupation: _occupationController.text.trim(),
        farmSize: _farmSizeController.text.trim(),
        cropTypes: _selectedCropTypes,
      );

      // Update auth service if available
      if (widget.authService != null) {
        final newName = _nameController.text.trim();
        if (newName.isNotEmpty && newName != widget.userName) {
          try {
            await widget.authService.updateDisplayName(newName);
          } catch (e) {
            debugPrint('Warning: Could not update auth service display name: $e');
          }
        }
      }

      _showSuccessSnackBar('Profile updated successfully!');
      
      // Wait a moment for the snackbar to show, then navigate back
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      _showErrorSnackBar('Failed to update profile. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildUserInfoChip({
    required IconData icon,
    required String label,
    required bool isEmpty,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isEmpty 
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmpty 
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isEmpty ? Colors.white60 : Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label.length > 15 ? '${label.substring(0, 15)}...' : label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isEmpty ? Colors.white60 : Colors.white,
              fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label.length > 10 ? '${label.substring(0, 10)}...' : label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}