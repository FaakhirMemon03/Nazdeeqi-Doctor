import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String _successMessage = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppState>(context, listen: false).patientProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _successMessage = '';
      _errorMessage = '';
    });

    try {
      await Provider.of<AppState>(context, listen: false).updateUserProfile(
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );
      if (mounted) {
        setState(() => _successMessage = 'Profile update ho gaya!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Kuch gadbad ho gai: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Edit Karein'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, size: 44, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  state.currentUserEmail ?? '',
                  style: const TextStyle(fontSize: 13, color: AppColors.textLight),
                ),
              ),
              const SizedBox(height: 32),

              if (_successMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_successMessage,
                      style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                ),
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_errorMessage,
                      style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                ),

              TextFormField(
                controller: _nameController,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Naam zaroori hai' : null,
                decoration: const InputDecoration(
                  labelText: 'Poora Naam',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textLight),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Phone number zaroori hai' : null,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textLight),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: state.isLoading ? null : _save,
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save Karein'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
