import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/clinic_model.dart';
import '../../models/doctor_model.dart';
import '../../providers/app_state.dart';
import 'booking_success_screen.dart';

class ClinicDetailScreen extends StatefulWidget {
  final ClinicModel clinic;
  const ClinicDetailScreen({super.key, required this.clinic});

  @override
  State<ClinicDetailScreen> createState() => _ClinicDetailScreenState();
}

class _ClinicDetailScreenState extends State<ClinicDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  
  DoctorModel? _selectedDoctor;
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;

  final _patientNameController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _complaintController = TextEditingController();

  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    // Load doctors for this clinic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      state.loadClinicDoctors(widget.clinic.uid).then((_) {
        // Auto-select first doctor if available
        if (state.activeClinicDoctors.isNotEmpty) {
          setState(() {
            _selectedDoctor = state.activeClinicDoctors.first;
          });
        }
      });

      // Pre-fill patient details from profile
      if (state.patientProfile != null) {
        _patientNameController.text = state.patientProfile!.name;
        _patientPhoneController.text = state.patientProfile!.phone;
      }
    });
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientPhoneController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  void _handleBookAppointment() async {
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor select karna zaroori hai.')),
      );
      return;
    }

    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment time slot select karein.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isBooking = true);
    final state = Provider.of<AppState>(context, listen: false);

    try {
      final appointment = await state.bookAppointment(
        clinic: widget.clinic,
        doctor: _selectedDoctor!,
        patientName: _patientNameController.text.trim(),
        patientPhone: _patientPhoneController.text.trim(),
        complaint: _complaintController.text.trim(),
        timeSlot: _selectedSlot!,
        date: _selectedDate,
      );

      if (!mounted) return;

      // Pushes to BookingSuccessScreen and removes previous detail screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(appointment: appointment),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking fail ho gayi: ${e.toString()}')),
      );
    } finally {
      setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Build lists of the next 5 dates
    final dates = List.generate(5, (idx) => DateTime.now().add(Duration(days: idx)));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clinic.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Clinic Info header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.clinic.isOpenToday ? AppColors.successBg : AppColors.errorBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.clinic.isOpenToday ? 'Open Today' : 'Closed Today',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: widget.clinic.isOpenToday ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(widget.clinic.timings, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textLight)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.clinic.address,
                              style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(widget.clinic.phone, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Section: Select Doctor
                const Text('Doctor Select Karein', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 12),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.primary))
                else if (state.activeClinicDoctors.isEmpty)
                  const Text('Abhi is clinic me koi active doctor available nahi hai.', style: TextStyle(color: AppColors.textLight, fontSize: 13))
                else
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.activeClinicDoctors.length,
                      separatorBuilder: (context, idx) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final doc = state.activeClinicDoctors[index];
                        final isSelected = _selectedDoctor?.id == doc.id;

                        // Parse colors from hex
                        final avatarColor = Color(int.parse(doc.avatarColor.replaceAll('#', '0xFF')));
                        final textColor = Color(int.parse(doc.textColor.replaceAll('#', '0xFF')));

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDoctor = doc;
                              _selectedSlot = null; // reset slot selection
                            });
                          },
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isSelected ? Colors.white24 : avatarColor,
                                  child: Text(
                                    doc.initials,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  doc.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  doc.specialty,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? Colors.white70 : AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                // Section: Select Date (Horizontal Row)
                const Text('Date Select Karein', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 68,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    separatorBuilder: (context, idx) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final date = dates[index];
                      final isSelected = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(date);
                      
                      final weekday = DateFormat('E').format(date);
                      final dayNum = DateFormat('d').format(date);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(weekday, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : AppColors.textLight)),
                              Text(dayNum, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textDark)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Section: Available Slots Grid
                if (_selectedDoctor != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Time Slot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      Text(
                        'Fee: Rs. ${_selectedDoctor!.fee}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                    ),
                    itemCount: _selectedDoctor!.availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _selectedDoctor!.availableSlots[index];
                      final isSelected = _selectedSlot == slot;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSlot = slot;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
                // Section: Patient Details Form
                const Text('Mareez (Patient) Ki Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _patientNameController,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Mareez ka naam zaroori hai';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Patient Ka Naam *',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.textLight),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _patientPhoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Phone number zaroori hai';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textLight),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _complaintController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bimari / Complaint (Optional)',
                    hintText: 'e.g. Bukhar aur khansi hai...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Icon(Icons.comment_outlined, color: AppColors.textLight),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isBooking ? null : _handleBookAppointment,
                  child: _isBooking
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirm Appointment'),
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
