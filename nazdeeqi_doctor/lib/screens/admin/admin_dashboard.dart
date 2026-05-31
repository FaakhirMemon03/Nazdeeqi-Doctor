import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/app_state.dart';
import '../../models/clinic_model.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Filter clinics
    final pending = state.clinics.where((c) => c.status == 'pending').toList();
    final allClinics = state.clinics;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.security, color: AppColors.error, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('Admin Dashboard'),
          ],
        ),
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
            Tab(icon: Icon(Icons.pending_actions_rounded), text: 'Pending Approval'),
            Tab(icon: Icon(Icons.business_rounded), text: 'All Clinics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(context, state, pending),
          _buildAllClinicsTab(context, state, allClinics),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 1. PENDING APPROVAL TAB
  // -------------------------------------------------------------
  Widget _buildPendingTab(BuildContext context, AppState state, List<ClinicModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 56, color: AppColors.success.withOpacity(0.3)),
            const SizedBox(height: 12),
            const Text(
              'Koi pending registrations nahi hain.',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight),
            ),
            const Text('Sab clinics approved aur verified hain!', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, idx) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final clinic = list[index];

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
                    Expanded(
                      child: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(10)),
                      child: const Text('PENDING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.warning)),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Text('Address: ${clinic.address}', style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                Text('Phone: ${clinic.phone} • Email: ${clinic.email}', style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                const Divider(height: 24),
                
                // Documents review box
                const Text('Uploaded Documents:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDocumentLink(context, 'Degree / Certificate', clinic.certificateUrl),
                    const SizedBox(width: 12),
                    _buildDocumentLink(context, 'License Image', clinic.licenseUrl),
                  ],
                ),
                const Divider(height: 24),
                
                // Actions (Approve / Reject)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _promptRejectionReason(context, state, clinic.uid),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Reject Clinic', style: TextStyle(color: AppColors.error)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        state.approveClinic(clinic.uid);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${clinic.name} approved successfully!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Verify & Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentLink(BuildContext context, String label, String url) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Preview document
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(label),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.insert_drive_file_rounded, size: 48, color: AppColors.primary),
                        SizedBox(height: 12),
                        Text('Document File Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('(Mock file stored on Cloud Storage)', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                )
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.file_present_rounded, color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _promptRejectionReason(BuildContext context, AppState state, String clinicId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Registration?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Clinic ko reject karne ki wajah (reason) likhein:', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
            const SizedBox(height: 12),
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(hintText: 'e.g. License document blurred hai...'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              state.rejectClinic(clinicId, reasonController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Reject Karein', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 2. ALL CLINICS OVERVIEW TAB
  // -------------------------------------------------------------
  Widget _buildAllClinicsTab(BuildContext context, AppState state, List<ClinicModel> list) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Statistics Panel Grid
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Approved Clinics', '${state.totalClinicsCount}', AppColors.success, AppColors.successBg)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Pending Approval',
                  '${list.where((c) => c.status == 'pending').length}',
                  AppColors.warning,
                  AppColors.warningBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('All Registered Establishments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (context, idx) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final clinic = list[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: ListTile(
                  title: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${clinic.city} • Timings: ${clinic.timings}'),
                  trailing: _buildStatusLabel(clinic.status),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(String status) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade600;

    if (status == 'approved') {
      bg = AppColors.successBg;
      fg = AppColors.success;
    } else if (status == 'pending') {
      bg = AppColors.warningBg;
      fg = AppColors.warning;
    } else if (status == 'rejected') {
      bg = AppColors.errorBg;
      fg = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
