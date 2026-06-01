import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/app_state.dart';

import '../clinic/clinic_dashboard.dart';
import '../admin/admin_dashboard.dart';
import 'patient_register_screen.dart';
import 'clinic_register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'patient'; // 'patient' | 'clinic' | 'admin'
  bool _obscurePassword = true;
  String _errorMessage = '';

  static const String _adminEmail = 'nazdeeqi@admin.com';
  static const String _adminPassword = 'nazdeeqi@access.com';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _errorMessage = '';
    });

    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Admin detection via hardcoded credentials
    if (email == _adminEmail && password == _adminPassword) {
      final state = Provider.of<AppState>(context, listen: false);
      try {
        await state.login(email, password, 'admin');
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
      return;
    }

    final state = Provider.of<AppState>(context, listen: false);

    try {
      await state.login(
        email,
        password,
        _selectedRole,
      );

      if (!mounted) return;

      // Role based routing
      if (_selectedRole == 'clinic') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClinicDashboard()),
        );
      } else {
        // Patient: pop back to wherever they came from (PatientHomeScreen/ClinicDetailScreen)
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // App branding header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.healing_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Nazdeeqi Doctor',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Khush Amdeed',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Apna email aur password enter karke sign in karein.',
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Role Selector Interactive Tab Bar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildRoleTab('patient', 'Patient'),
                        _buildRoleTab('clinic', 'Clinic'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  // Email Input Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email zaroori hai';
                      if (!val.contains('@')) return 'Munasib email format enter karein';
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'e.g. name@email.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textLight),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password Input Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Password zaroori hai';
                      if (val.length < 4) return 'Password 4 characters se bara hona chahiye';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textLight),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textLight),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state.isLoading ? null : _handleLogin,
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Login Karein'),
                  ),
                  const SizedBox(height: 16),
                  // Sign-up option togglers
                  if (_selectedRole == 'patient')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Account nahi hai? ", style: TextStyle(color: AppColors.textLight)),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PatientRegisterScreen()),
                          ),
                          child: const Text('Sign Up Karein', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  if (_selectedRole == 'clinic')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Naya Hospital register karna hai? ", style: TextStyle(color: AppColors.textLight)),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ClinicRegisterScreen()),
                          ),
                          child: const Text('Register Clinic', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String role, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }
}
