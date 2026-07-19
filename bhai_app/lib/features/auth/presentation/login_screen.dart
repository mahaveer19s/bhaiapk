import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  void _sendOtp() {
    if (_phoneController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    
    // Simulate sending OTP via backend
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your phone number.')),
      );
    });
  }

  void _verifyOtp() {
    if (_otpController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    // Simulate verification
    Future.delayed(const Duration(seconds: 1), () async {
      final settings = Hive.box('settings');
      await settings.put('auth_token', 'dummy_jwt_token_bhai');
      await settings.put('user_id', 'dummy_user_id');

      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/home');
      }
    });
  }

  void _guestLogin() async {
    setState(() => _isLoading = true);
    final settings = Hive.box('settings');
    await settings.put('auth_token', 'guest_token');
    await settings.put('user_id', 'guest_user');
    
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo Circle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentCyan.withOpacity(0.15),
                  ),
                  child: const Icon(Icons.shield_outlined, size: 80, color: AppTheme.accentCyan),
                ),
                const SizedBox(height: 16),
                const Text(
                  'BHAI',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2.0),
                ),
                const Text(
                  '"Your Brother is Always With You"',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Main login Form container
                GlassmorphicContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        _otpSent ? 'Enter verification code' : 'Login using Phone Number',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      if (!_otpSent) ...[
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter 10-digit mobile number',
                            prefixIcon: const Icon(Icons.phone_iphone),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '6-digit OTP code',
                            prefixIcon: const Icon(Icons.lock_clock),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (_isLoading)
                        const CircularProgressIndicator(color: AppTheme.accentCyan)
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentCyan,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _otpSent ? _verifyOtp : _sendOtp,
                          child: Text(_otpSent ? 'Verify OTP' : 'Send Verification OTP'),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const Text('Or sign in with', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),

                // OAuth Sign Ins
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 45,
                      icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.red),
                      onPressed: () {
                        // Google sign-in integration hook
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: 40,
                      icon: const Icon(Icons.apple, color: Colors.white),
                      onPressed: () {
                        // Apple sign-in integration hook
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                // Guest sign in button
                TextButton(
                  onPressed: _guestLogin,
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
