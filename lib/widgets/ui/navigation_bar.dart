// lib/widgets/ui/navigation_bar.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/language_provider.dart';
import '../../services/app_localizations.dart';
import '../../services/profile_service.dart';
import 'language_switcher.dart';

class NavigationBar extends StatefulWidget {
  final Function(String)? onNavigate;
  final String currentPage;
  final LanguageProvider? languageProvider;
  final dynamic authService;

  const NavigationBar({
    super.key,
    this.onNavigate,
    this.currentPage = 'home',
    this.languageProvider,
    this.authService,
  });

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  bool _isScrolled = false;
  String? _hoveredPage;
  String? _localPhotoUrl;
  final ProfileService _profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bool isAuthenticated = _isUserAuthenticated();
    
    // Debug: Check if callback is provided
    if (widget.onNavigate == null) {
      debugPrint('WARNING: NavigationBar onNavigate callback is null!');
    }
    
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1FDF0),
            Colors.white,
          ],
        ),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Navigation
              Row(
                children: [
                  // Left-side menu button (opens drawer)
                  Builder(
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.menu, size: 22, color: Color(0xFF047857)),
                        onPressed: () {
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null) {
                            scaffold.openDrawer();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Logo from assets
                  Image.asset(
                    'assets/images/logo.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AGRICARE',
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Your Partner in Modern Farming',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Desktop Menu
                  if (MediaQuery.of(context).size.width > 768) ...[
                    _buildNavItem(loc.translate('home'), 'home'),
                    _buildNavItem(loc.translate('our_services'), 'services'),
                    _buildNavItem(loc.translate('feedback'), 'feedback'),
                    _buildNavItem(loc.translate('be_partner'), 'partner'),
                    _buildNavItem(loc.translate('contact_us'), 'contact'),
                  ],
                  
                  const SizedBox(width: 16),
                  
                  // Language Switcher
                  if (widget.languageProvider != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF22C55E),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: LanguageSwitcher(
                        languageProvider: widget.languageProvider!,
                      ),
                    ),

                  const SizedBox(width: 12),

                  // Logged-in user profile avatar
                  if (isAuthenticated)
                    _buildProfileAvatar(),
                  
                  // Mobile Menu Button
                  if (MediaQuery.of(context).size.width <= 768)
                    IconButton(
                      onPressed: _showMobileMenu,
                      icon: Icon(Icons.menu, color: Colors.green[600]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isUserAuthenticated() {
    try {
      if (widget.authService == null) return false;
      return widget.authService.isAuthenticated == true;
    } catch (_) {
      return false;
    }
  }

  dynamic get _currentUser {
    try {
      return widget.authService?.currentUser;
    } catch (_) {
      return null;
    }
  }

  String _userDisplayName() {
    final user = _currentUser;
    if (user == null) return 'Guest';
    try {
      final displayName = user.displayName as String?;
      if (displayName != null && displayName.trim().isNotEmpty) return displayName.trim();
    } catch (_) {}
    try {
      final email = user.email as String?;
      if (email != null && email.contains('@')) {
        return email.split('@').first;
      }
    } catch (_) {}
    return 'Guest';
  }

  String? _userEmail() {
    final user = _currentUser;
    try {
      return user?.email as String?;
    } catch (_) {
      return null;
    }
  }

  String? _userPhotoUrl() {
    final user = _currentUser;
    if (user == null) return null;

    // Firebase User.photoURL
    try {
      final dynamic url = user.photoURL;
      if (url != null && url.toString().isNotEmpty) {
        return url.toString();
      }
    } catch (_) {}

    // MockUser.photoUrl
    try {
      final dynamic url = user.photoUrl;
      if (url != null && url.toString().isNotEmpty) {
        return url.toString();
      }
    } catch (_) {}

    return null;
  }

  Widget _buildProfileAvatar() {
    final name = _userDisplayName();
    final photoUrl = _localPhotoUrl ?? _userPhotoUrl();
    final profileImageSource = _profileService.getProfileImageSource();
    
    debugPrint('👤 Building avatar: name=$name, photoUrl=$photoUrl, _localPhotoUrl=$_localPhotoUrl');
    debugPrint('👤 Profile service image: $profileImageSource');
    
    final initials = name.isNotEmpty
        ? name.trim().split(' ').where((p) => p.isNotEmpty).map((p) => p[0]).take(2).join().toUpperCase()
        : 'U';

    // Use profile service image first, then fallback to auth service photo
    final finalImageSource = profileImageSource ?? photoUrl;
    final hasProfileImage = finalImageSource != null && finalImageSource.isNotEmpty;

    return InkWell(
      onTap: _showProfileDialog,
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: hasProfileImage ? const Color(0xFF047857) : const Color(0xFF22C55E),
                width: hasProfileImage ? 2.0 : 1.5,
              ),
              boxShadow: hasProfileImage ? [
                BoxShadow(
                  color: const Color(0xFF047857).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFDCFCE7),
              backgroundImage: hasProfileImage
                  ? (finalImageSource!.startsWith('data:') 
                      ? MemoryImage(_base64ToUint8List(finalImageSource))
                      : NetworkImage(finalImageSource)) as ImageProvider
                  : null,
              child: !hasProfileImage
                  ? Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
          ),
          // Profile completion indicator
          if (hasProfileImage)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF047857),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showProfileDialog() async {
    final email = _userEmail();
    final userId = _getUserId();
    final parentContext = context; // Capture parent context
    
    // Initialize profile service if needed
    if (userId.isNotEmpty) {
      await _profileService.initializeProfile(userId, email ?? '', _userDisplayName());
    }
    
    // Debug: Check profile initialization
    debugPrint('🔍 Profile Dialog: userId=$userId, email=$email, displayName=${_userDisplayName()}');
    debugPrint('🔍 Profile Service: currentProfile=${_profileService.currentProfile?.fullName}');
    debugPrint('🔍 Profile Image: ${_profileService.getProfileImageSource()}');

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final profile = _profileService.currentProfile;
            final imageSource = _profileService.getProfileImageSource();
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fixed Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            color: const Color(0xFF047857),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              shape: const CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                    
                    // Enhanced Profile Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF047857).withOpacity(0.1),
                            const Color(0xFF10B981).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF047857).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Profile Image with Upload
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF047857),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
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
                                              size: 35,
                                              color: const Color(0xFF047857).withOpacity(0.7),
                                            ),
                                            Text(
                                              _userDisplayName().isNotEmpty 
                                                  ? _userDisplayName()[0].toUpperCase() 
                                                  : 'U',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF047857),
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _showPhotoUploadOptions(setDialogState),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF047857),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Enhanced User Details Section
                          Column(
                            children: [
                              // Name with completion indicator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      profile?.fullName.isNotEmpty == true 
                                          ? profile!.fullName 
                                          : _userDisplayName(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (profile?.fullName.isNotEmpty == true)
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF047857),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Email with verification status
                              if (email != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          email,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.verified,
                                        size: 14,
                                        color: Colors.green[600],
                                      ),
                                    ],
                                  ),
                                ),
                              
                              const SizedBox(height: 16),
                              
                              // Simplified Profile Information
                              if (profile != null) ...[
                                // Interactive Info Grid
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSimpleInfoCard(
                                        icon: Icons.phone_outlined,
                                        label: 'Phone',
                                        hasValue: profile.phoneNumber.isNotEmpty,
                                        value: profile.phoneNumber.isNotEmpty ? profile.phoneNumber : null,
                                        onTap: () => _showEditDialog(
                                          parentContext,
                                          'Phone Number',
                                          profile.phoneNumber,
                                          Icons.phone_outlined,
                                          'phone',
                                          (value) async {
                                            await _profileService.updateProfile(
                                              phoneNumber: value,
                                            );
                                            setDialogState(() {}); // Refresh dialog
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildSimpleInfoCard(
                                        icon: Icons.location_on_outlined,
                                        label: 'Location',
                                        hasValue: profile.address.isNotEmpty,
                                        value: profile.address.isNotEmpty ? profile.address : null,
                                        onTap: () => _showEditDialog(
                                          parentContext,
                                          'Location',
                                          profile.address,
                                          Icons.location_on_outlined,
                                          'address',
                                          (value) async {
                                            await _profileService.updateProfile(
                                              address: value,
                                            );
                                            setDialogState(() {}); // Refresh dialog
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildSimpleInfoCard(
                                        icon: Icons.work_outline,
                                        label: 'Work',
                                        hasValue: profile.occupation.isNotEmpty,
                                        value: profile.occupation.isNotEmpty ? profile.occupation : null,
                                        onTap: () => _showEditDialog(
                                          parentContext,
                                          'Occupation',
                                          profile.occupation,
                                          Icons.work_outline,
                                          'occupation',
                                          (value) async {
                                            await _profileService.updateProfile(
                                              occupation: value,
                                            );
                                            setDialogState(() {}); // Refresh dialog
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              
                              // Profile Completion Indicator
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.account_circle,
                                      size: 14,
                                      color: Colors.blue[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Profile ${(_profileService.getProfileCompleteness() * 100).round()}% Complete',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    
                    // Fixed Action Buttons at Bottom
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showPhotoUploadOptions(setDialogState),
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: Text(
                                imageSource != null ? 'Change Photo' : 'Add Photo',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF047857),
                                side: const BorderSide(color: Color(0xFF047857)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                // Save current profile data
                                try {
                                  await _profileService.saveProfile();
                                  debugPrint('✅ Profile saved successfully');
                                  Navigator.of(dialogContext).pop();
                                } catch (e) {
                                  debugPrint('❌ Error saving profile: $e');
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                              icon: const Icon(Icons.save, size: 18),
                              label: Text(
                                'Save Profile',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF047857),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  Widget _buildNavItem(String title, String page) {
    final isActive = widget.currentPage == page;
    final isHovered = _hoveredPage == page;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredPage = page),
        onExit: (_) => setState(() => _hoveredPage = null),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              debugPrint('Navigation item tapped: $page');
              if (widget.onNavigate != null) {
                debugPrint('Calling onNavigate callback with page: $page');
                widget.onNavigate!(page);
              } else {
                debugPrint('ERROR: onNavigate callback is null!');
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFDCFCE7)
                    : (isHovered ? const Color(0xFFF0FDF4) : Colors.transparent),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF22C55E)
                      : (isHovered ? const Color(0xFFBBF7D0) : Colors.transparent),
                  width: 1.2,
                ),
              ),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: isActive
                      ? const Color(0xFF047857)
                      : (isHovered ? const Color(0xFF065F46) : Colors.black87),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(String title, String page, IconData icon) {
    final isActive = widget.currentPage == page;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('Mobile nav item tapped: $page');
          // Close the modal first, then navigate
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          // Use a small delay to ensure modal is closed before navigation
          Future.delayed(const Duration(milliseconds: 100), () {
            if (widget.onNavigate != null) {
              debugPrint('Calling onNavigate callback with page: $page');
              widget.onNavigate!(page);
            } else {
              debugPrint('ERROR: onNavigate callback is null!');
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.green[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.green[700] : Colors.black54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: isActive ? Colors.green[700] : Colors.black87,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Logo and App Name
            Row(
              children: [
                // Logo from assets
                Image.asset(
                  'assets/images/logo.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AgriCare',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Agricultural Services',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Menu Items
            Builder(
              builder: (context) {
                final loc = AppLocalizations.of(context);
                return Column(
                  children: [
                    _buildMobileNavItem(loc.translate('home'), 'home', Icons.home),
                    _buildMobileNavItem(loc.translate('our_services'), 'services', Icons.agriculture),
                    _buildMobileNavItem(loc.translate('feedback'), 'feedback', Icons.rate_review),
                    _buildMobileNavItem(loc.translate('be_partner'), 'partner', Icons.handshake_outlined),
                    _buildMobileNavItem(loc.translate('contact_us'), 'contact', Icons.phone_outlined),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // CTA Button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: MaterialButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    // Use a small delay to ensure modal is closed before navigation
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (widget.onNavigate != null) {
                        widget.onNavigate!('book-service');
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_android, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Book Service',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }



  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required bool hasValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: hasValue 
            ? const Color(0xFF047857).withOpacity(0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasValue 
              ? const Color(0xFF047857).withOpacity(0.2)
              : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: hasValue ? const Color(0xFF047857) : Colors.grey[400],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (hasValue)
                Icon(
                  Icons.check_circle,
                  size: 10,
                  color: const Color(0xFF047857),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: hasValue ? Colors.black87 : Colors.grey[500],
              fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInfoCard({
    required IconData icon,
    required String label,
    required bool hasValue,
    String? value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasValue 
              ? const Color(0xFF047857).withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue 
                ? const Color(0xFF047857).withOpacity(0.3)
                : Colors.grey[200]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: hasValue ? const Color(0xFF047857) : Colors.grey[400],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: hasValue ? const Color(0xFF047857) : Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (hasValue && value != null)
              Text(
                value.length > 12 ? '${value.substring(0, 12)}...' : value,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                hasValue ? 'Added' : 'Not set',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: hasValue ? const Color(0xFF047857) : Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 2),
            if (hasValue)
              Icon(
                Icons.check_circle,
                size: 12,
                color: const Color(0xFF047857),
              )
            else
              Icon(
                Icons.add_circle_outline,
                size: 12,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  void _showPhotoUploadOptions(StateSetter setDialogState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Update Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(context);
                      await _uploadFromCamera(setDialogState);
                    },
                  ),
                  _buildPhotoOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      await _uploadFromGallery(setDialogState);
                    },
                  ),
                  _buildPhotoOption(
                    icon: Icons.link,
                    label: 'URL',
                    onTap: () {
                      Navigator.pop(context);
                      _showUrlDialog(setDialogState);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF047857).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF047857).withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF047857),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFromCamera(StateSetter setDialogState) async {
    try {
      final userId = _getUserId();
      if (userId.isNotEmpty) {
        await _profileService.uploadProfileImage(fromCamera: true);
        // Update both dialog and main widget state
        setDialogState(() {});
        if (mounted) {
          setState(() {});
        }
        _showSuccessMessage('Photo updated from camera!');
      }
    } catch (e) {
      debugPrint('❌ Camera upload error: $e');
      _showErrorMessage('Failed to upload photo from camera');
    }
  }

  Future<void> _uploadFromGallery(StateSetter setDialogState) async {
    try {
      final userId = _getUserId();
      if (userId.isNotEmpty) {
        await _profileService.uploadProfileImage(fromCamera: false);
        // Update both dialog and main widget state
        setDialogState(() {});
        if (mounted) {
          setState(() {});
        }
        _showSuccessMessage('Photo updated from gallery!');
      }
    } catch (e) {
      debugPrint('❌ Gallery upload error: $e');
      _showErrorMessage('Failed to upload photo from gallery');
    }
  }

  void _showUrlDialog(StateSetter setDialogState) {
    final urlController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Photo URL'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'Enter photo URL',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = urlController.text.trim();
                if (url.isNotEmpty) {
                  try {
                    await _profileService.setProfileImageUrl(url);
                    // Update both dialog and main widget state
                    setDialogState(() {});
                    if (mounted) {
                      setState(() {});
                    }
                    Navigator.pop(context);
                    _showSuccessMessage('Photo updated successfully!');
                  } catch (e) {
                    debugPrint('❌ URL upload error: $e');
                    _showErrorMessage('Failed to set photo URL');
                  }
                }
              },
              child: const Text('Set Photo'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToFullProfile() {
    // Navigate to full profile edit page
    if (widget.onNavigate != null) {
      widget.onNavigate!('profile');
    }
  }

  String _getUserId() {
    try {
      final user = widget.authService?.currentUser;
      if (user != null) {
        return user.uid ?? '';
      }
    } catch (e) {
      debugPrint('Error getting user ID: $e');
    }
    return '';
  }

  Uint8List _base64ToUint8List(String base64String) {
    final base64Data = base64String.split(',').last;
    return base64Decode(base64Data);
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, String title, String currentValue, IconData icon, String fieldType, Function(String) onSave) async {
    final TextEditingController controller = TextEditingController(text: currentValue);
    
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
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
              Expanded(
                child: Text(
                  'Edit $title',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                keyboardType: fieldType == 'phone' ? TextInputType.phone : TextInputType.text,
                maxLines: fieldType == 'address' ? 3 : 1,
                decoration: InputDecoration(
                  labelText: title,
                  hintText: _getHintText(fieldType),
                  prefixIcon: Icon(icon, color: const Color(0xFF047857)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF047857), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.pop(dialogContext, value);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF047857),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    
    controller.dispose();
    
    // Handle the result after dialog is closed
    if (result != null && result.isNotEmpty) {
      try {
        await onSave(result);
        debugPrint('✅ $title updated successfully');
      } catch (e) {
        debugPrint('❌ Error saving $fieldType: $e');
      }
    }
  }

  String _getHintText(String fieldType) {
    switch (fieldType) {
      case 'phone':
        return 'Enter your phone number';
      case 'address':
        return 'Enter your address or location';
      case 'occupation':
        return 'Enter your occupation or work';
      default:
        return 'Enter information';
    }
  }
}

// Sticky Navigation Bar Wrapper
class StickyNavigationBar extends StatefulWidget {
  final Widget child;
  final Function(String)? onNavigate;
  final String currentPage;
  final LanguageProvider? languageProvider;

  const StickyNavigationBar({
    super.key,
    required this.child,
    this.onNavigate,
    this.currentPage = 'home',
    this.languageProvider,
  });

  @override
  State<StickyNavigationBar> createState() => _StickyNavigationBarState();
}

class _StickyNavigationBarState extends State<StickyNavigationBar> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final scrollOffset = _scrollController.offset;
    final isScrolled = scrollOffset > 50;
    
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Fixed Navigation Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: NavigationBar(
              onNavigate: widget.onNavigate,
              currentPage: widget.currentPage,
              languageProvider: widget.languageProvider,
            ),
            toolbarHeight: 60,
          ),
          
          // Main Content
          SliverToBoxAdapter(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
