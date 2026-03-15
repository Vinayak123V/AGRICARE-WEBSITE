// lib/widgets/mock_auth_screen.dart

import 'package:flutter/material.dart';
import '../../services/mock_auth_service.dart';

enum AuthMode { login, register }

enum UserType { farmer, vendor }

class MockAuthScreen extends StatefulWidget {
  final Function(String, [String]) showNotification;
  final MockAuthService authService;
  
  const MockAuthScreen({
    super.key,
    required this.showNotification,
    required this.authService,
  });

  @override
  State<MockAuthScreen> createState() => _MockAuthScreenState();
}

class _MockAuthScreenState extends State<MockAuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;
  UserType _userType = UserType.farmer;
  String _email = '';
  String _password = '';
  String _name = '';
  bool _isLoading = false;
  bool _passwordVisible = false;
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
      _formKey.currentState?.reset();
      _animationController.reset();
      _animationController.forward();
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
        await widget.authService.login(
          email: _email.trim(),
          password: _password,
        );
        widget.showNotification("Login successful! Welcome back.", "success");
      } else {
        await widget.authService.register(
          email: _email.trim(),
          password: _password,
          name: _name,
          userType: _userType.name,
        );
        widget.showNotification(
          "Registration successful! Welcome $_name.",
          "success",
        );
      }
    } catch (e) {
      String message = 'An authentication error occurred.';
      final errorCode = e.toString().replaceAll('Exception: ', '');
      
      if (errorCode == 'weak-password') {
        message = 'The password provided is too weak. Use at least 6 characters.';
      } else if (errorCode == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else if (errorCode == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (errorCode == 'wrong-password') {
        message = 'Incorrect password. Please try again.';
      } else if (errorCode == 'invalid-email') {
        message = 'Invalid email address format.';
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
                          // Logo or Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF047857).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _authMode == AuthMode.login
                                  ? Icons.agriculture
                                  : Icons.person_add,
                              size: 50,
                              color: const Color(0xFF047857),
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
                          // Mock Auth Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'Demo Mode - No Firebase Required',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Demo credentials
                          if (_authMode == AuthMode.login)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.lock_open, size: 16, color: Colors.green[700]),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Demo Credentials:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Email: farmer@demo.com',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[800],
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Text(
                                    'Password: farmer123',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[800],
                                      fontFamily: 'monospace',
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
                          const SizedBox(height: 20),
                          
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
