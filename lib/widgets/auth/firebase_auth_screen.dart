// lib/widgets/firebase_auth_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/firebase_auth_service.dart';
import 'google_sign_in_button.dart';

enum AuthMode { login, register }
enum UserType { farmer, vendor }

class FirebaseAuthScreen extends StatefulWidget {
  final Function(String, [String]) showNotification;
  final FirebaseAuthService authService;
  
  const FirebaseAuthScreen({
    super.key,
    required this.showNotification,
    required this.authService,
  });

  @override
  State<FirebaseAuthScreen> createState() => _FirebaseAuthScreenState();
}

class _FirebaseAuthScreenState extends State<FirebaseAuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;
  UserType _userType = UserType.farmer;
  String _email = '';
  String _password = '';
  String _name = '';
  String _licenceNumber = '';
  String _rcNumber = '';
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _isEmailVerified = false;
  Timer? _emailVerificationTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _checkEmailVerification();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailVerificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerification() async {
    await widget.authService.currentUser?.reload();
    setState(() {
      _isEmailVerified = widget.authService.isEmailVerified;
    });
    
    // Check verification status every 5 seconds
    _emailVerificationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        if (mounted) {
          await widget.authService.currentUser?.reload();
          setState(() {
            _isEmailVerified = widget.authService.isEmailVerified;
          });
          if (_isEmailVerified) {
            timer.cancel();
          }
        }
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.authService.signInWithGoogle();
      if (mounted) {
        widget.showNotification("Signed in with Google successfully!", "success");
      }
    } catch (e) {
      if (mounted) {
        widget.showNotification(
          e.toString().contains('cancelled') 
              ? 'Google Sign-In was cancelled' 
              : 'Failed to sign in with Google',
          'error',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
      _formKey.currentState?.reset();
      _animationController.reset();
      _animationController.forward();
      // Reset vendor fields when switching modes
      _licenceNumber = '';
      _rcNumber = '';
    });
  }

  void _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.login) {
        debugPrint('🔐 Attempting login with email: ${_email.trim()}');
        await widget.authService.login(
          email: _email.trim(),
          password: _password,
        );
        widget.showNotification("Login successful! Welcome back.", "success");
      } else {
        debugPrint('🔐 Attempting registration with email: ${_email.trim()}');
        await widget.authService.register(
          email: _email.trim(),
          password: _password,
          name: _name,
          userType: _userType.name,
          licenceNumber: _userType == UserType.vendor ? _licenceNumber.trim() : null,
          rcNumber: _userType == UserType.vendor ? _rcNumber.trim() : null,
        );
        
        // Show success popup
        widget.showNotification(
          "Registration successful! Please login with your new credentials.",
          "success",
        );
        
        // Add delay to let user see the popup before UI changes
        await Future.delayed(const Duration(seconds: 2));
        
        // Reset form to login mode
        setState(() {
          _authMode = AuthMode.login;
          _email = '';
          _password = '';
          _name = '';
        });
      }
    } catch (e) {
      debugPrint('❌ Auth error: $e');
      String message = 'An authentication error occurred.';
      final errorCode = e.toString().replaceAll('Exception: ', '');
      
      if (errorCode == 'firebase-config-error') {
        message = 'Firebase configuration error. Please check your Firebase project settings.';
      } else if (errorCode == 'weak-password') {
        message = 'The password provided is too weak. Use at least 6 characters.';
      } else if (errorCode == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else if (errorCode == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (errorCode == 'wrong-password') {
        message = 'Incorrect password. Please try again.';
      } else if (errorCode == 'invalid-email') {
        message = 'Invalid email address format.';
      } else if (errorCode == 'invalid-credential') {
        message = 'Invalid email or password.';
      }
      widget.showNotification(message, "error");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FDF0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF1FDF0),
              const Color(0xFFD1FAE5),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.green.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF047857).withOpacity(0.1),
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: AssetImage('assets/images/login_logo.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _authMode == AuthMode.login
                                ? 'Welcome Back!'
                                : 'Join AgriCare',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _authMode == AuthMode.login
                                ? 'Sign in to continue'
                                : 'Create your account',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Firebase Auth Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.security, size: 16, color: Colors.blue[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'Secure Firebase Authentication',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Name field (only for registration)
                          if (_authMode == AuthMode.register)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: TextFormField(
                                key: const ValueKey('name'),
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  hintText: 'Enter your full name',
                                  prefixIcon: const Icon(Icons.person, color: Color(0xFF047857)),
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
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your name.';
                                  }
                                  if (val.trim().length < 2) {
                                    return 'Name must be at least 2 characters.';
                                  }
                                  return null;
                                },
                                onSaved: (val) => _name = val!.trim(),
                              ),
                            ),
                          if (_authMode == AuthMode.register)
                            const SizedBox(height: 16),
                          
                          // Email field
                          TextFormField(
                            key: const ValueKey('email'),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'your.email@example.com',
                              prefixIcon: const Icon(Icons.email, color: Color(0xFF047857)),
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
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email.';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (val) => _email = val!.trim(),
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          TextFormField(
                            key: const ValueKey('password'),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock, color: Color(0xFF047857)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Color(0xFF047857),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
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
                            obscureText: !_passwordVisible,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter a password.';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters.';
                              }
                              return null;
                            },
                            onSaved: (val) => _password = val!,
                          ),
                          const SizedBox(height: 16),
                          
                          // Vendor-specific fields (only for registration and vendor type)
                          if (_authMode == AuthMode.register && _userType == UserType.vendor)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                children: [
                                  TextFormField(
                                    key: const ValueKey('licenceNumber'),
                                    decoration: InputDecoration(
                                      labelText: 'Licence Number',
                                      hintText: 'Enter your licence number',
                                      prefixIcon: const Icon(Icons.badge, color: Color(0xFF047857)),
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
                                    validator: (val) {
                                      if (_userType == UserType.vendor && (val == null || val.trim().isEmpty)) {
                                        return 'Licence number is required for vendor registration.';
                                      }
                                      return null;
                                    },
                                    onSaved: (val) => _licenceNumber = val!.trim(),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    key: const ValueKey('rcNumber'),
                                    decoration: InputDecoration(
                                      labelText: 'RC Number of Vehicle',
                                      hintText: 'Enter your vehicle RC number',
                                      prefixIcon: const Icon(Icons.directions_car, color: Color(0xFF047857)),
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
                                    validator: (val) {
                                      if (_userType == UserType.vendor && (val == null || val.trim().isEmpty)) {
                                        return 'RC number is required for vendor registration.';
                                      }
                                      return null;
                                    },
                                    onSaved: (val) => _rcNumber = val!.trim(),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          
                          // Forgot Password link (only in login mode)
                          if (_authMode == AuthMode.login)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () async {
                                  final emailController = TextEditingController();
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Reset Password'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('Enter your email address and we\'ll send you a link to reset your password.'),
                                            const SizedBox(height: 16),
                                            TextField(
                                              controller: emailController,
                                              decoration: InputDecoration(
                                                labelText: 'Email',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                prefixIcon: const Icon(Icons.email, color: Color(0xFF047857)),
                                              ),
                                              keyboardType: TextInputType.emailAddress,
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('CANCEL'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF047857),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () {
                                              if (emailController.text.isNotEmpty) {
                                                Navigator.of(context).pop(true);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Please enter your email address'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text('SEND RESET LINK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (result == true && emailController.text.isNotEmpty) {
                                    try {
                                      await FirebaseAuthService().resetPassword(emailController.text);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Password reset email sent to ${emailController.text}'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Error sending password reset email. Please try again.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFF047857),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 20),
                          
                          // OR divider (only in login mode)
                          if (_authMode == AuthMode.login) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey[300],
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Continue with Google button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _handleGoogleSignIn,
                                icon: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4285F4), // Google Blue
                                        Color(0xFF34A853), // Google Green
                                        Color(0xFFFBBC05), // Google Yellow
                                        Color(0xFFEA4335), // Google Red
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                label: Text(
                                  _isLoading ? 'Signing in...' : 'Continue with Google',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.grey[300]!, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          // User type selection (only for registration)
                          if (_authMode == AuthMode.register)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'I am a:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFF047857),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildUserTypeCard(
                                          UserType.farmer,
                                          'Farmer',
                                          Icons.agriculture,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildUserTypeCard(
                                          UserType.vendor,
                                          'Vendor',
                                          Icons.store,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          
                          // Submit button
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: CircularProgressIndicator(
                                color: Color(0xFF047857),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _submitAuthForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF059669),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: const Color(0xFF047857).withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _authMode == AuthMode.login ? 'LOGIN' : 'REGISTER',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          
                          // Switch auth mode button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _authMode == AuthMode.login
                                    ? "Don't have an account? "
                                    : 'Already have an account? ',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              TextButton(
                                onPressed: _switchAuthMode,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF047857),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  _authMode == AuthMode.login ? 'Register' : 'Login',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Logout button for testing
                          if (widget.authService.isAuthenticated)
                            TextButton.icon(
                              onPressed: () async {
                                await widget.authService.logout();
                                widget.showNotification("Logged out successfully", "success");
                              },
                              icon: const Icon(Icons.logout, size: 16),
                              label: const Text('Logout (Testing)'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(UserType type, String title, IconData icon) {
    final isSelected = _userType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _userType = type;
          // Reset vendor fields when switching away from vendor
          if (type != UserType.vendor) {
            _licenceNumber = '';
            _rcNumber = '';
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF047857) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF047857) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF047857).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF047857),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF047857),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
