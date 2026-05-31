import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/app_state.dart';
import '../../models/appointment_model.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Split appointments into Active and History
    final upcoming = state.appointments.where((a) => a.status == 'confirmed').toList();
    final history = state.appointments.where((a) => a.status != 'confirmed').toList();

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
                Tab(text: 'Upcoming Slots'),
                Tab(text: 'Past History'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAppointmentsList(context, upcoming, isUpcoming: true),
                _buildAppointmentsList(context, history, isUpcoming: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(BuildContext context, List<AppointmentModel> list, {required bool isUpcoming}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              isUpcoming ? 'Koi upcoming appointments nahi hain.' : 'Koi booking history nahi mili.',
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
        final formattedDate = DateFormat('MMMM d, yyyy').format(appointment.appointmentDate);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Text(
                      appointment.bookingCode,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 15, color: AppColors.primary),
                    ),
                    _buildStatusTag(appointment.status),
                  ],
                ),
                const Divider(height: 24, thickness: 0.8),
                Text(appointment.doctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(appointment.clinicName, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(formattedDate, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 14, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Text(appointment.timeSlot, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
                  ],
                ),
                if (appointment.complaint.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Bimari: ${appointment.complaint}', style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontStyle: FontStyle.italic)),
                ],
                if (isUpcoming) ...[
                  const Divider(height: 24, thickness: 0.8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _confirmCancel(context, appointment.id),
                      icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                      label: const Text('Cancel Slot', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusTag(String status) {
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
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  void _confirmCancel(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text('Kya aap sach me ye appointment slot cancel karna chahte hain?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nahi', style: TextStyle(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).updateAppointmentStatus(appointmentId, 'cancelled');
              Navigator.pop(context);
            },
            child: const Text('Haan, Cancel Karein', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
