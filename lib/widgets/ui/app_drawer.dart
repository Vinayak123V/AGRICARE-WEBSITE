// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import '../../services/profile_service.dart';
import '../pages/edit_profile_page.dart';
import '../pages/settings_page.dart';
import '../pages/alerts_page.dart';

class AppDrawer extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId;
  final VoidCallback onProfileTap;
  final VoidCallback onBookingsTap;
  final VoidCallback onWeatherTap;
  final VoidCallback onChatTap;
  final VoidCallback onLogoutTap;
  final dynamic authService;
  final int? totalBookings;
  final int? pendingBookings;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userId,
    required this.onProfileTap,
    required this.onBookingsTap,
    required this.onWeatherTap,
    required this.onChatTap,
    required this.onLogoutTap,
    this.authService,
    this.totalBookings,
    this.pendingBookings,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    // Start animations
    _slideController.forward();
    _fadeController.forward();
    
    // Listen to profile changes
    _profileService.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _profileService.removeListener(_onProfileChanged);
    super.dispose();
  }
  
  void _onProfileChanged() {
    // Rebuild the widget when profile changes
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    String displayName = widget.userName;
    String email = widget.userEmail;
    String? photoUrl;

    try {
      final user = widget.authService?.currentUser;
      if (user != null) {
        final dn = user.displayName as String?;
        final em = user.email as String?;
        String? pu;
        // Firebase User.photoURL
        try {
          pu = user.photoURL as String?;
        } catch (_) {}
        // MockUser.photoUrl
        if (pu == null || pu.isEmpty) {
          try {
            pu = user.photoUrl as String?;
          } catch (_) {}
        }
        if (dn != null && dn.trim().isNotEmpty) displayName = dn.trim();
        if (em != null && em.trim().isNotEmpty) email = em.trim();
        photoUrl = pu;
      }
    } catch (_) {}

    return SlideTransition(
      position: _slideAnimation,
      child: Drawer(
        child: Container(
          color: const Color(0xFFF1F5F9),
          child: Column(
            children: <Widget>[
              // Enhanced Header
              _buildEnhancedHeader(displayName, email, photoUrl, context, loc),
              
              // White Background Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.only(top: 24),
                    children: [
                      // Stats Section
                      if (widget.totalBookings != null || widget.pendingBookings != null)
                        _buildStatsSection(),
                      
                      const SizedBox(height: 16),
                      
                      // Navigation Items
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            _buildModernListTile(
                              icon: Icons.person_rounded,
                              title: 'My Profile',
                              subtitle: 'Account & Settings',
                              onTap: widget.onProfileTap,
                              delay: 100,
                              iconColor: const Color(0xFF10B981),
                              iconBgColor: const Color(0xFFDCFCE7),
                            ),
                            _buildModernListTile(
                              icon: Icons.bookmark_rounded,
                              title: 'My Bookings',
                              subtitle: '${widget.totalBookings ?? 0} total bookings',
                              onTap: widget.onBookingsTap,
                              delay: 200,
                              badge: widget.pendingBookings,
                              iconColor: const Color(0xFF3B82F6),
                              iconBgColor: const Color(0xFFDBEAFE),
                            ),
                            _buildModernListTile(
                              icon: Icons.cloud_rounded,
                              title: 'Weather Forecast',
                              subtitle: 'Local weather updates',
                              onTap: widget.onWeatherTap,
                              delay: 300,
                              iconColor: const Color(0xFF8B5CF6),
                              iconBgColor: const Color(0xFFEDE9FE),
                            ),
                            _buildModernListTile(
                              icon: Icons.support_agent_rounded,
                              title: 'Support Chat',
                              subtitle: '24/7 customer support',
                              onTap: widget.onChatTap,
                              delay: 400,
                              iconColor: const Color(0xFFF59E0B),
                              iconBgColor: const Color(0xFFFEF3C7),
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              child: Divider(thickness: 1, color: Color(0xFFF1F5F9)),
                            ),
                            
                            _buildModernListTile(
                              icon: Icons.logout_rounded,
                              title: 'Logout',
                              subtitle: 'Sign out of your account',
                              onTap: widget.onLogoutTap,
                              delay: 500,
                              iconColor: const Color(0xFFEF4444),
                              iconBgColor: const Color(0xFFFEE2E2),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // App Version Footer
                      _buildAppFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(String displayName, String email, String? photoUrl, BuildContext context, AppLocalizations loc) {
    // Get profile photo from ProfileService first, then fall back to authService
    String? profilePhotoUrl = _profileService.getProfileImageSource();
    if (profilePhotoUrl == null || profilePhotoUrl.isEmpty) {
      profilePhotoUrl = photoUrl;
    }
    
    // Get display name from ProfileService if available
    if (_profileService.currentProfile != null) {
      final profileName = _profileService.currentProfile!.fullName;
      if (profileName.isNotEmpty) {
        displayName = profileName;
      }
    }
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF047857),
            Color(0xFF10B981),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              // Compact Avatar with Online Status
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF8B5CF6),
                      backgroundImage: (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
                          ? (profilePhotoUrl.startsWith('data:image')
                              ? MemoryImage(
                                  Uri.parse(profilePhotoUrl).data!.contentAsBytes(),
                                )
                              : NetworkImage(profilePhotoUrl)) as ImageProvider
                          : null,
                      child: (profilePhotoUrl == null || profilePhotoUrl.isEmpty)
                          ? Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'V',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  // Online Status Indicator
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // User Name
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 6),
              
              // User Email
              Text(
                email,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Edit Profile',
                    onTap: () => _navigateToEditProfile(context),
                  ),
                  _buildActionButton(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    onTap: () => _navigateToSettings(context),
                  ),
                  _buildActionButton(
                    icon: Icons.notifications_rounded,
                    label: 'Alerts',
                    onTap: () => _navigateToAlerts(context),
                    badge: widget.pendingBookings != null && widget.pendingBookings! > 0 
                        ? widget.pendingBookings.toString() 
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                if (badge != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Bookings',
              '${widget.totalBookings ?? 0}',
              Icons.calendar_today_rounded,
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildModernListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int delay,
    required Color iconColor,
    required Color iconBgColor,
    int? badge,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badge != null && badge > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
                onTap: onTap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'AgriCare v2.0.1',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Agricultural Services Platform',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showProfileEditDialog(BuildContext context, AppLocalizations loc) async {
    String currentName = widget.userName;
    String? currentPhotoUrl;

    try {
      final user = widget.authService?.currentUser;
      if (user != null) {
        final dn = user.displayName as String?;
        final pu = user.photoURL as String?;
        if (dn != null && dn.trim().isNotEmpty) currentName = dn.trim();
        currentPhotoUrl = pu;
      }
    } catch (_) {}

    final nameController = TextEditingController(text: currentName);
    final photoController = TextEditingController(text: currentPhotoUrl ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(loc.translate('profile') ?? 'Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFFDCFCE7),
                    backgroundImage: (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty)
                        ? NetworkImage(currentPhotoUrl!)
                        : null,
                    child: (currentPhotoUrl == null || currentPhotoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 32, color: Color(0xFF047857))
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: loc.translate('name') ?? 'Name',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: photoController,
                  decoration: InputDecoration(
                    labelText: loc.translate('profile_photo_url') ?? 'Profile photo URL',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.translate('cancel') ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newPhotoUrl = photoController.text.trim();

                try {
                  if (widget.authService != null) {
                    if (newName.isNotEmpty) {
                      await widget.authService.updateDisplayName(newName);
                    }
                    if (newPhotoUrl.isNotEmpty) {
                      await widget.authService.updatePhotoUrl(newPhotoUrl);
                    }
                  }

                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.translate('profile_updated') ?? 'Profile updated'),
                    ),
                  );
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.translate('profile_update_failed') ?? 'Failed to update profile'),
                    ),
                  );
                }
              },
              child: Text(loc.translate('save') ?? 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          userName: widget.userName,
          userEmail: widget.userEmail,
          userId: widget.userId,
          authService: widget.authService,
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          authService: widget.authService,
        ),
      ),
    );
  }

  void _navigateToAlerts(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AlertsPage(
          pendingBookings: widget.pendingBookings,
          totalBookings: widget.totalBookings,
        ),
      ),
    );
  }
}
