import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../models/appointment_model.dart';
import 'patient_home_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final AppointmentModel appointment;
  const BookingSuccessScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(appointment.appointmentDate);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Appointment Booked!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aapka slot kamyabi se book ho chuka hai. Slip niche dekh sakte hain.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
              const SizedBox(height: 32),
              // Premium Invoice Receipt Medical Ticket
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // Ticket Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BOOKING SLIP',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                            child: const Text(
                              'CONFIRMED',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Ticket Body
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Booking Code
                          Center(
                            child: Column(
                              children: [
                                const Text('BOOKING CODE', style: TextStyle(fontSize: 10, color: AppColors.textLight, letterSpacing: 0.5)),
                                const SizedBox(height: 4),
                                Text(
                                  appointment.bookingCode,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: AppColors.primary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTicketRow('Patient Name:', appointment.patientName),
                          _buildTicketRow('Phone Number:', appointment.patientPhone),
                          _buildTicketRow('Doctor:', appointment.doctorName),
                          _buildTicketRow('Clinic / Hospital:', appointment.clinicName),
                          _buildTicketRow('Address:', appointment.clinicAddress, isMultiline: true),
                          _buildTicketRow('Scheduled Date:', formattedDate),
                          _buildTicketRow('Scheduled Time:', appointment.timeSlot),
                          if (appointment.complaint.isNotEmpty)
                            _buildTicketRow('Bimari / Complaint:', appointment.complaint, isMultiline: true),
                          const Divider(height: 32, thickness: 1, color: Colors.grey),
                          // Simulated Barcode
                          Column(
                            children: [
                              Container(
                                height: 36,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    35,
                                    (i) => Container(
                                      width: (i % 3 == 0) ? 3 : 1.5,
                                      color: Colors.grey.shade400,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text('Nazdeeqi Doctor Mobile System', style: TextStyle(fontSize: 9, color: AppColors.textLight)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Warning alert
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: const [
                    Icon(Icons.sms_outlined, color: AppColors.warning, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Aapko booking confirm hone par SMS reminder bheja ja chuka hai.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Wapas Home Par Jayein'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
