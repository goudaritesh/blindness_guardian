import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.8, -0.6),
            radius: 1.2,
            colors: [
              theme.colorScheme.secondary.withOpacity(0.08),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shield_rounded, size: 72, color: theme.colorScheme.primary),
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).shimmer(delay: 1.seconds),
                    const SizedBox(height: 32),
                    Text(
                      'Guardian App',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    Text(
                      'Secure Monitoring for Blind Stick',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white54,
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Guardian Email',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Please enter your email' : null,
                    ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      obscureText: true,
                      validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                    ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                    const SizedBox(height: 32),
                    auth.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                bool success = await context.read<AuthProvider>().login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                                if (!success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Login failed. Please check your credentials.'),
                                      backgroundColor: theme.colorScheme.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('SIGN IN'),
                          ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.9, 0.9)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('First time here?', style: TextStyle(color: Colors.white54)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage()));
                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 900.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
