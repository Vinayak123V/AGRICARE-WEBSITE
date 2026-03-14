// lib/widgets/pages/settings_page.dart

import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final dynamic authService;

  const SettingsPage({
    super.key,
    this.authService,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR (₹)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('settings'),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionHeader(context, 'account'),
          _buildSettingsCard([
            _buildSettingsTile(
              context,
              icon: Icons.person_rounded,
              titleKey: 'profile_information',
              subtitleKey: 'update_personal_details',
              onTap: () => _showComingSoonDialog('Profile editing'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
            _buildDivider(),
            _buildSettingsTile(
              context,
              icon: Icons.security_rounded,
              titleKey: 'privacy_security',
              subtitleKey: 'manage_privacy_settings',
              onTap: () => _showComingSoonDialog('Privacy settings'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
            _buildDivider(),
            _buildSettingsTile(
              context,
              icon: Icons.payment_rounded,
              titleKey: 'payment_methods',
              subtitleKey: 'manage_payment_options',
              onTap: () => _showComingSoonDialog('Payment management'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          ]),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(context, 'notifications'),
          _buildSettingsCard([
            _buildSwitchTile(
              context,
              icon: Icons.notifications_rounded,
              titleKey: 'enable_notifications',
              subtitleKey: 'receive_app_notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildDivider(),
            _buildSwitchTile(
              context,
              icon: Icons.email_rounded,
              titleKey: 'email_notifications',
              subtitleKey: 'receive_updates_email',
              value: _emailNotifications,
              onChanged: _notificationsEnabled ? (value) {
                setState(() {
                  _emailNotifications = value;
                });
              } : null,
            ),
            _buildDivider(),
            _buildSwitchTile(
              context,
              icon: Icons.sms_rounded,
              titleKey: 'sms_notifications',
              subtitleKey: 'receive_sms_updates',
              value: _smsNotifications,
              onChanged: _notificationsEnabled ? (value) {
                setState(() {
                  _smsNotifications = value;
                });
              } : null,
            ),
            _buildDivider(),
            _buildSwitchTile(
              context,
              icon: Icons.phone_android_rounded,
              titleKey: 'push_notifications',
              subtitleKey: 'receive_push_notifications',
              value: _pushNotifications,
              onChanged: _notificationsEnabled ? (value) {
                setState(() {
                  _pushNotifications = value;
                });
              } : null,
            ),
          ]),

          const SizedBox(height: 24),

          // App Preferences Section
          _buildSectionHeader(context, 'app_preferences'),
          _buildSettingsCard([
            _buildSwitchTile(
              context,
              icon: Icons.dark_mode_rounded,
              titleKey: 'dark_mode',
              subtitleKey: 'use_dark_theme',
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                _showComingSoonDialog('Dark mode');
              },
            ),
            _buildDivider(),
            _buildSettingsTile(
              context,
              icon: Icons.language_rounded,
              titleKey: 'language',
              subtitleKey: 'language', // Will show current language
              onTap: () => _showLanguageDialog(),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
            _buildDivider(),
            _buildSettingsTile(
              context,
              icon: Icons.currency_rupee_rounded,
              titleKey: 'currency',
              subtitleKey: 'currency', // Will show current currency
              onTap: () => _showCurrencyDialog(),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          ]),

          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader(context, 'support_about'),
          _buildSettingsCard([
            _buildSettingsTile(
              context,
              icon: Icons.help_rounded,
              titleKey: 'help_faq',
              subtitleKey: 'get_help_answers',
              onTap: () => _showComingSoonDialog('Help center'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
            _buildDivider(),
            _buildSettingsTile(
              context,
              icon: Icons.feedback_rounded,
              titleKey: 'send_feedback',
              subtitleKey: 'share_thoughts',
              onTap: () => _showComingSoonDialog('Feedback form'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
            _buildDivider(),
            _buildSettingsTile(
              context,
              icon: Icons.info_rounded,
              titleKey: 'about_agricare',
              subtitleKey: 'version',
              onTap: () => _showAboutDialog(),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          ]),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionHeader(context, 'account_actions'),
          _buildSettingsCard([
            _buildSettingsTile(
              context,
              icon: Icons.logout_rounded,
              titleKey: 'sign_out',
              subtitleKey: 'sign_out_account',
              onTap: () => _showSignOutDialog(),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              isDestructive: true,
            ),
            _buildDivider(),
            _buildSettingsTile(
              context,
              icon: Icons.delete_forever_rounded,
              titleKey: 'delete_account',
              subtitleKey: 'permanently_delete',
              onTap: () => _showDeleteAccountDialog(),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              isDestructive: true,
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String titleKey) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        AppLocalizations.of(context).translate(titleKey),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String titleKey,
    required String subtitleKey,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive 
              ? const Color(0xFFEF4444).withOpacity(0.1)
              : const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive 
              ? const Color(0xFFEF4444)
              : const Color(0xFF10B981),
          size: 20,
        ),
      ),
      title: Text(
        AppLocalizations.of(context).translate(titleKey),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDestructive 
              ? const Color(0xFFEF4444)
              : const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        AppLocalizations.of(context).translate(subtitleKey),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF6B7280),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String titleKey,
    required String subtitleKey,
    required bool value,
    required Function(bool)? onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF10B981),
          size: 20,
        ),
      ),
      title: Text(
        AppLocalizations.of(context).translate(titleKey),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        AppLocalizations.of(context).translate(subtitleKey),
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF6B7280),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF10B981),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
      indent: 20,
      endIndent: 20,
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Hindi', 'Marathi', 'Gujarati', 'Tamil', 'Telugu'];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                },
                activeColor: const Color(0xFF10B981),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showCurrencyDialog() {
    final currencies = ['INR (₹)', 'USD (\$)', 'EUR (€)', 'GBP (£)'];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Select Currency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies.map((currency) {
              return RadioListTile<String>(
                title: Text(currency),
                value: currency,
                groupValue: _selectedCurrency,
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                  Navigator.pop(context);
                },
                activeColor: const Color(0xFF10B981),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('About AgriCare'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AgriCare v2.0.1',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your comprehensive agricultural services platform. Connecting farmers with essential services for better crop management and productivity.',
              ),
              SizedBox(height: 16),
              Text(
                '© 2024 AgriCare. All rights reserved.',
                style: TextStyle(
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

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to main app
                // Here you would call the actual logout function
                _showComingSoonDialog('Sign out functionality');
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Color(0xFFEF4444)),
          ),
          content: const Text(
            'This action cannot be undone. All your data will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showComingSoonDialog('Account deletion');
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Coming Soon'),
          content: Text('$feature will be available in a future update.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}