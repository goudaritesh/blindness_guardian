import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _deviceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('CREATE ACCOUNT')),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.6),
            radius: 1.2,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Text(
                    'Guardian Profile',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const Text(
                    'Fill in your details to stay connected',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildAnimatedField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    delay: 100,
                  ),
                  _buildAnimatedField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.alternate_email_rounded,
                    delay: 200,
                  ),
                  _buildAnimatedField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    delay: 300,
                  ),
                  _buildAnimatedField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_android_rounded,
                    delay: 400,
                  ),
                  _buildAnimatedField(
                    controller: _deviceController,
                    label: 'Blind Stick ID',
                    icon: Icons.memory_rounded,
                    hint: 'e.g., stick_001',
                    delay: 500,
                  ),
                  
                  const SizedBox(height: 48),
                  auth.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                bool success = await context.read<AuthProvider>().signup(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  _nameController.text.trim(),
                                  _phoneController.text.trim(),
                                  _deviceController.text.trim(),
                                );
                                
                                if (success && mounted) {
                                  Navigator.pop(context);
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Signup failed. Please try again.'),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                                  );
                                }
                              }
                            }
                          },
                          child: const Text('CREATE ACCOUNT'),
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isPassword = false,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        validator: (v) => v!.isEmpty ? 'Enter $label' : null,
      ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1),
    );
  }
}
