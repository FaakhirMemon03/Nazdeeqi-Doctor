import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../constants/nazdeeqi_loader.dart';
import '../../providers/app_state.dart';
import '../../models/clinic_model.dart';
import 'clinic_detail_screen.dart';
import 'patient_dashboard.dart';
import '../auth/login_screen.dart';

/// Main landing screen — visible to ALL users (logged in or not).
/// Shows clinics, doctors, everything. Login only needed for booking.
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isLoggedIn = state.currentUserUid != null;

    final List<Widget> tabs = [
      const ExploreClinicsTab(),
      if (isLoggedIn) const PatientDashboard(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.healing_outlined, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('Nazdeeqi Doctor'),
          ],
        ),
        actions: [
          if (isLoggedIn)
            // Logged in — show logout
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              tooltip: 'Sign Out',
              onPressed: () async {
                await state.logout();
                if (context.mounted) {
                  setState(() {
                    _currentTab = 0;
                  });
                }
              },
            )
          else
            // Not logged in — show Login button
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  ).then((_) {
                    // Refresh state when returning from login
                    setState(() {});
                  });
                },
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Login'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) {
          if (idx == 1 && !isLoggedIn) {
            // Not logged in — prompt login for My Bookings tab
            _showLoginPrompt(context);
            return;
          }
          setState(() {
            _currentTab = idx;
          });
          if (idx == 1) {
            Provider.of<AppState>(context, listen: false).loadAppointments();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Clinics Dhoondhein',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_added_rounded),
            label: 'My Bookings',
          ),
        ],
      ),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Login Zaroori Hai',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apni bookings dekhne ke liye pehle login karein.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textLight),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                  child: const Text('Login / Sign Up'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Baad me', style: TextStyle(color: AppColors.textLight)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// EXPLORE CLINICS TAB COMPONENT
// -------------------------------------------------------------
class ExploreClinicsTab extends StatefulWidget {
  const ExploreClinicsTab({super.key});

  @override
  State<ExploreClinicsTab> createState() => _ExploreClinicsTabState();
}

class _ExploreClinicsTabState extends State<ExploreClinicsTab> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return RefreshIndicator(
      onRefresh: () async {
        await state.loadClinics();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Badge Title section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: AppColors.tealGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.verified_user_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('100% Verified Doctors', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Apna Doctor,\nApni Marzi',
                      style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ghar baithe appointment book karein — koi line nahi, koi intezaar nahi.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    // Counter Statistics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatBox('${state.totalClinicsCount}+', 'Registered Clinics'),
                        _buildStatBox('${state.totalDoctorsCount}+', 'Active Doctors'),
                        _buildStatBox(
                          state.totalPatientsServed >= 1000 ? '${(state.totalPatientsServed / 1000).floor()}K+' : '${state.totalPatientsServed}',
                          'Patients Served',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Search Header with Meri Location button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Qareeb ki Clinics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  OutlinedButton.icon(
                    onPressed: state.isLoading ? null : () => state.findNearbyClinics(),
                    icon: const Icon(Icons.my_location_rounded, size: 16),
                    label: const Text('Meri Location', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
              if (state.locationStatus.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.locationStatus,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Clinics list view
              if (state.isLoading)
                const NazdeeqiLoader(
                  message: 'Nazdeeqi Doctor',
                  subMessage: 'Clinics load ho rahi hain...',
                )
              else if (state.filteredClinics.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.grey.shade400, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'Koi approved clinics nahi mili.',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Location permission check karein ya shehar badal kar dekhein.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.filteredClinics.length,
                  separatorBuilder: (context, idx) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final clinic = state.filteredClinics[index];
                    final distance = state.clinicDistances[clinic.uid];

                    return _buildClinicCard(context, clinic, distance);
                  },
                ),
              const SizedBox(height: 24),
              // Trust features panel
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureIcon(Icons.sms_rounded, 'SMS Reminder'),
                    _buildFeatureIcon(Icons.security_rounded, 'Data Safe'),
                    _buildFeatureIcon(Icons.cancel_presentation_rounded, 'Free Cancel'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String number, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ],
    );
  }

  Widget _buildClinicCard(BuildContext context, ClinicModel clinic, double? distanceKm) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // Go to details screen — no login required to browse
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClinicDetailScreen(clinic: clinic)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Open Status tag
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            clinic.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: clinic.isOpenToday ? AppColors.successBg : AppColors.errorBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            clinic.isOpenToday ? '● Open Today' : '● Closed Today',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: clinic.isOpenToday ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Address
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            clinic.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Timings
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          clinic.timings,
                          style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (distanceKm != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$distanceKm km',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
