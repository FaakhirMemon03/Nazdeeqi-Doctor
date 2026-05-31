import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/app_state.dart';

class ClinicRegisterScreen extends StatefulWidget {
  const ClinicRegisterScreen({super.key});

  @override
  State<ClinicRegisterScreen> createState() => _ClinicRegisterScreenState();
}

class _ClinicRegisterScreenState extends State<ClinicRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMessage = '';

  // Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedCity = 'Karachi';

  // Geo Coordinates
  double? _latitude;
  double? _longitude;
  bool _fetchingLocation = false;

  // Documents simulation state variables
  String? _certificateName;
  String? _licenseName;
  double _certUploadProgress = 0.0;
  double _licenseUploadProgress = 0.0;

  final List<String> _cities = ['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad', 'Multan', 'Peshawar', 'Quetta'];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (_) {}
    setState(() => _fetchingLocation = false);
  }

  void _simulateUpload(String docType) async {
    for (double i = 0.0; i <= 1.0; i += 0.2) {
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() {
        if (docType == 'cert') {
          _certUploadProgress = i;
          if (i >= 0.9) _certificateName = 'Clinic_MD_Certificate.pdf';
        } else {
          _licenseUploadProgress = i;
          if (i >= 0.9) _licenseName = 'PMDC_Medical_License.jpg';
        }
      });
    }
  }

  void _submitRegistration() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    if (_certificateName == null || _licenseName == null) {
      setState(() {
        _errorMessage = 'Doctor certificate aur license ki documents zaroor upload karein';
        _isLoading = false;
      });
      return;
    }

    final state = Provider.of<AppState>(context, listen: false);

    try {
      await state.registerClinic(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _selectedCity,
        certificateUrl: 'uploads/docs/${_certificateName}',
        licenseUrl: 'uploads/docs/${_licenseName}',
        agreementUrls: ['uploads/docs/agreement_mock_sample.png'],
        latitude: _latitude,
        longitude: _longitude,
      );

      setState(() {
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 96),
                const SizedBox(height: 24),
                const Text(
                  'Registration Submit Ho Gayi!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin review ke baad aap apne diye gaye email (${_emailController.text}) aur password se login kar sakenge.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.textLight, height: 1.4),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Login Page par wapas jayein'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Registration'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              if (_currentStep == 0) {
                if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Naam aur address likhna zaroori hai.')),
                  );
                  return;
                }
              } else if (_currentStep == 1) {
                if (_phoneController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact details aur proper password fill karein.')),
                  );
                  return;
                }
              }
              setState(() => _currentStep++);
            } else {
              _submitRegistration();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_currentStep == 2 ? 'Register Karein' : 'Aagay Chalein'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Wapas'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Basic Information
            Step(
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.editing,
              title: const Text('Basic'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Hospital / Clinic details enter karein',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital / Clinic Ka Naam *',
                      hintText: 'e.g. City Care Hospital',
                      prefixIcon: Icon(Icons.local_hospital_outlined, color: AppColors.textLight),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Pura Address *',
                      hintText: 'Block, Area, City',
                      prefixIcon: Icon(Icons.map_outlined, color: AppColors.textLight),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                    onChanged: (val) => setState(() => _selectedCity = val!),
                    decoration: const InputDecoration(
                      labelText: 'Shehar (City)',
                      prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.textLight),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // GPS Tracker Alert Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.gps_fixed, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _fetchingLocation
                              ? const Text('GPS coordinates dhoondh rahe hain...', style: TextStyle(fontSize: 12))
                              : Text(
                                  _latitude != null
                                      ? 'GPS Location Saved: (${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})'
                                      : 'GPS location permit nahi mili. Default coordinates store kiye jaenge.',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryDark),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Step 2: Contact Information
            Step(
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : (_currentStep == 1 ? StepState.editing : StepState.indexed),
              title: const Text('Contact'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Hospital Credentials & Contact Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Clinic Phone Number *',
                      hintText: '03XX XXXXXXX',
                      prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textLight),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Login Email Address *',
                      hintText: 'clinic@email.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textLight),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Login Password *',
                      hintText: 'Minimum 4 characters',
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.textLight),
                    ),
                  ),
                ],
              ),
            ),
            // Step 3: Document Uploads
            Step(
              isActive: _currentStep >= 2,
              state: _currentStep == 2 ? StepState.editing : StepState.indexed,
              title: const Text('Verification'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Documents Verification Upload',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Admin verification ke liye required licensing documents attach karein.',
                    style: TextStyle(fontSize: 13, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_errorMessage, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                    ),
                  // Cert upload
                  _buildUploadBox(
                    label: 'Doctor ka Certificate (Degree/PMDC) *',
                    fileName: _certificateName,
                    progress: _certUploadProgress,
                    onTap: () => _simulateUpload('cert'),
                  ),
                  const SizedBox(height: 16),
                  // License upload
                  _buildUploadBox(
                    label: 'Hospital operational Health License *',
                    fileName: _licenseName,
                    progress: _licenseUploadProgress,
                    onTap: () => _simulateUpload('license'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox({
    required String label,
    required String? fileName,
    required double progress,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          if (fileName == null && progress == 0.0)
            InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Select Document', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else if (progress < 0.9)
            Column(
              children: [
                LinearProgressIndicator(value: progress, color: AppColors.primary, backgroundColor: Colors.grey.shade200),
                const SizedBox(height: 6),
                Text('Uploading... ${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              ],
            )
          else
            Row(
              children: [
                const Icon(Icons.insert_drive_file_rounded, color: AppColors.primary, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fileName!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      const Text('Upload Successful (Ready to submit)', style: TextStyle(fontSize: 11, color: AppColors.success)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    setState(() {
                      if (label.contains('Certificate')) {
                        _certificateName = null;
                        _certUploadProgress = 0.0;
                      } else {
                        _licenseName = null;
                        _licenseUploadProgress = 0.0;
                      }
                    });
                  },
                ),
              ],
            )
        ],
      ),
    );
  }
}
