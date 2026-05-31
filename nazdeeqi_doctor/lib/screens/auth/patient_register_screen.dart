import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/app_state.dart';
import '../patient/patient_home_screen.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() {
      _errorMessage = '';
    });

    if (!_formKey.currentState!.validate()) return;

    final state = Provider.of<AppState>(context, listen: false);

    try {
      await state.registerPatient(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim(),
      );

      if (!mounted) return;

      // Redirect to patient home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
        (route) => false,
      );
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
      appBar: AppBar(
        title: const Text('Naya Account Banayein'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Sign Up Karein',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Apni details enter karke apna patient profile activate karein.',
                  style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.bottom(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                // Name Field
                TextFormField(
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Naam zaroori hai';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Pura Naam',
                    hintText: 'e.g. Faakhir Memon',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.textLight),
                  ),
                ),
                const SizedBox(height: 16),
                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Phone number zaroori hai';
                    if (val.length < 10) return 'Munasib phone number enter karein';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '03XX XXXXXXX',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textLight),
                  ),
                ),
                const SizedBox(height: 16),
                // Email Field
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
                    hintText: 'e.g. user@gmail.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textLight),
                  ),
                ),
                const SizedBox(height: 16),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Password zaroori hai';
                    if (val.length < 6) return 'Password kam-se-kam 6 characters ka hona chahiye';
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
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _handleRegister,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Register Karein'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
