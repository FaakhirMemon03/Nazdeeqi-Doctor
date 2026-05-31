import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/app_state.dart';
import '../../models/appointment_model.dart';
import '../auth/login_screen.dart';

class ClinicDashboard extends StatefulWidget {
  const ClinicDashboard({super.key});

  @override
  State<ClinicDashboard> createState() => _ClinicDashboardState();
}

class _ClinicDashboardState extends State<ClinicDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initial fetch for appointments and doctors list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      if (state.currentUserUid != null) {
        state.loadClinicDoctors(state.currentUserUid!);
        state.loadAppointments();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final clinic = state.clinicProfile;

    if (clinic == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Clinic Dashboard')),
        body: const Center(child: Text('Loading profile...')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () async {
              await state.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Doctors'),
            Tab(icon: Icon(Icons.book_online_rounded), text: 'Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ClinicSettingsTab(state: state),
          ClinicDoctorsTab(state: state),
          ClinicAppointmentsTab(state: state),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 1. SETTINGS TAB (STATUS SWITCHER & TIMINGS)
// -------------------------------------------------------------
class ClinicSettingsTab extends StatefulWidget {
  final AppState state;
  const ClinicSettingsTab({super.key, required this.state});

  @override
  State<ClinicSettingsTab> createState() => _ClinicSettingsTabState();
}

class _ClinicSettingsTabState extends State<ClinicSettingsTab> {
  final _timingsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timingsController.text = widget.state.clinicProfile?.timings ?? '';
  }

  @override
  void dispose() {
    _timingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clinic = widget.state.clinicProfile!;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Clinic Operational Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 16),
          // Live Open/Closed today switch
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: SwitchListTile(
                title: const Text('Open Today Status', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                subtitle: Text(
                  clinic.isOpenToday ? 'Patients aapki clinic ko open dekhenge.' : 'Patients aapki clinic ko closed dekhenge.',
                  style: const TextStyle(fontSize: 12),
                ),
                activeColor: AppColors.success,
                activeTrackColor: AppColors.successBg,
                inactiveThumbColor: AppColors.error,
                inactiveTrackColor: AppColors.errorBg,
                value: clinic.isOpenToday,
                onChanged: (val) {
                  widget.state.toggleClinicOpenStatus(val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Edit Timings textfield
          const Text('Clinic Timing Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _timingsController,
            decoration: const InputDecoration(
              hintText: 'e.g. Mon-Sat: 9:00 AM - 9:00 PM',
              prefixIcon: Icon(Icons.access_time_rounded, color: AppColors.textLight),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await widget.state.updateClinicTimings(_timingsController.text.trim());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Timings update ho chuki hain!')),
                );
              }
            },
            child: const Text('Save Timings'),
          ),
          const Spacer(),
          // Meta details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Clinic Details (Verify Only):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                const SizedBox(height: 8),
                Text('Address: ${clinic.address}', style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('Phone: ${clinic.phone}', style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text('Status: Approved (Live)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. DOCTORS TAB (MANAGE ACTIVE DOCTORS LIST)
// -------------------------------------------------------------
class ClinicDoctorsTab extends StatefulWidget {
  final AppState state;
  const ClinicDoctorsTab({super.key, required this.state});

  @override
  State<ClinicDoctorsTab> createState() => _ClinicDoctorsTabState();
}

class _ClinicDoctorsTabState extends State<ClinicDoctorsTab> {
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _feeController = TextEditingController();

  void _showAddDoctorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Naya Doctor Add Karein'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Doctor Ka Naam', hintText: 'e.g. Tariq Mahmood'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(labelText: 'Specialty / Category', hintText: 'e.g. General Physician'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _feeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Consultation Fee (Rs.)', hintText: 'e.g. 1000'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _specialtyController.clear();
              _feeController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () {
              if (_nameController.text.isEmpty || _specialtyController.text.isEmpty || _feeController.text.isEmpty) return;
              
              widget.state.addDoctor(
                _nameController.text.trim(),
                _specialtyController.text.trim(),
                int.parse(_feeController.text.trim()),
              );

              _nameController.clear();
              _specialtyController.clear();
              _feeController.clear();
              Navigator.pop(context);
            },
            child: const Text('Doctor Add Karein', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDoctorDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.state.activeClinicDoctors.isEmpty
            ? const Center(child: Text('Abhi koi doctor register nahi hai. Naya Doctor add karein.'))
            : ListView.separated(
                itemCount: widget.state.activeClinicDoctors.length,
                separatorBuilder: (context, idx) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = widget.state.activeClinicDoctors[index];
                  final avatarColor = Color(int.parse(doc.avatarColor.replaceAll('#', '0xFF')));
                  final textColor = Color(int.parse(doc.textColor.replaceAll('#', '0xFF')));

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: avatarColor,
                        child: Text(doc.initials, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${doc.specialty} • Fee: Rs. ${doc.fee}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(doc.isActive ? Icons.toggle_on : Icons.toggle_off, color: doc.isActive ? AppColors.success : Colors.grey, size: 36),
                            onPressed: () {
                              widget.state.toggleDoctorActive(doc);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () {
                              widget.state.deleteDoctor(doc.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. APPOINTMENTS TAB (MANAGE BOOKED PATIENTS SLOTS)
// -------------------------------------------------------------
class ClinicAppointmentsTab extends StatelessWidget {
  final AppState state;
  const ClinicAppointmentsTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Split appointments into Active and Past
    final active = state.appointments.where((a) => a.status == 'confirmed').toList();
    final completed = state.appointments.where((a) => a.status != 'confirmed').toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Active Bookings'),
                Tab(text: 'Completed History'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAppointmentsListView(context, active, isActive: true),
                _buildAppointmentsListView(context, completed, isActive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsListView(BuildContext context, List<AppointmentModel> list, {required bool isActive}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_ind_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              isActive ? 'Abhi koi active bookings nahi hain.' : 'Koi booking history nahi mili.',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = list[index];
        final dateStr = DateFormat('MMMM d, yyyy').format(appointment.appointmentDate);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appointment.bookingCode,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppColors.primary, fontSize: 15),
                    ),
                    _buildStatusBadge(appointment.status),
                  ],
                ),
                const Divider(height: 24),
                Text('Patient: ${appointment.patientName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text('Phone: ${appointment.patientPhone}', style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                const SizedBox(height: 2),
                Text('Assigned Doctor: ${appointment.doctorName}', style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 14, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(dateStr, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(appointment.timeSlot, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                if (appointment.complaint.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Bimari: ${appointment.complaint}', style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontStyle: FontStyle.italic)),
                ],
                if (isActive) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          state.updateAppointmentStatus(appointment.id, 'cancelled');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel Slot', style: TextStyle(color: AppColors.error)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          state.updateAppointmentStatus(appointment.id, 'completed');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Checkup Completed'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade600;

    if (status == 'confirmed') {
      bg = AppColors.successBg;
      fg = AppColors.success;
    } else if (status == 'completed') {
      bg = AppColors.primaryLight;
      fg = AppColors.primary;
    } else if (status == 'cancelled') {
      bg = AppColors.errorBg;
      fg = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
