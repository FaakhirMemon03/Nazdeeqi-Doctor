import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clinic_model.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../models/user_model.dart';

abstract class DatabaseService {
  Future<List<ClinicModel>> getClinics();
  Future<ClinicModel?> getClinicById(String clinicId);
  Future<List<DoctorModel>> getDoctors(String clinicId);
  Future<List<AppointmentModel>> getAppointments({String? clinicId, String? userId});
  Future<void> addDoctor(DoctorModel doctor);
  Future<void> updateDoctor(DoctorModel doctor);
  Future<void> deleteDoctor(String doctorId);
  Future<void> bookAppointment(AppointmentModel appointment);
  Future<void> updateAppointmentStatus(String appointmentId, String status);
  Future<void> approveClinic(String clinicId);
  Future<void> rejectClinic(String clinicId, String reason);
  Future<void> updateClinicDetails(ClinicModel clinic);
}

// -------------------------------------------------------------
// CLOUD FIRESTORE DATABASE IMPLEMENTATION
// -------------------------------------------------------------
class FirebaseDatabaseService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ClinicModel>> getClinics() async {
    final snapshot = await _firestore.collection('clinics').get();
    return snapshot.docs.map((doc) => ClinicModel.fromMap(doc.data())).toList();
  }

  @override
  Future<ClinicModel?> getClinicById(String clinicId) async {
    final doc = await _firestore.collection('clinics').doc(clinicId).get();
    if (!doc.exists) return null;
    return ClinicModel.fromMap(doc.data()!);
  }

  @override
  Future<List<DoctorModel>> getDoctors(String clinicId) async {
    final snapshot = await _firestore
        .collection('doctors')
        .where('clinicId', isEqualTo: clinicId)
        .get();
    return snapshot.docs.map((doc) => DoctorModel.fromMap(doc.data())).toList();
  }

  @override
  Future<List<AppointmentModel>> getAppointments({String? clinicId, String? userId}) async {
    Query query = _firestore.collection('appointments');
    if (clinicId != null) {
      query = query.where('clinicId', isEqualTo: clinicId);
    }
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    
    // Ordered by newest first
    final snapshot = await query.get();
    final appointments = snapshot.docs.map((doc) => AppointmentModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    appointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return appointments;
  }

  @override
  Future<void> addDoctor(DoctorModel doctor) async {
    await _firestore.collection('doctors').doc(doctor.id).set(doctor.toMap());
  }

  @override
  Future<void> updateDoctor(DoctorModel doctor) async {
    await _firestore.collection('doctors').doc(doctor.id).update(doctor.toMap());
  }

  @override
  Future<void> deleteDoctor(String doctorId) async {
    await _firestore.collection('doctors').doc(doctorId).delete();
  }

  @override
  Future<void> bookAppointment(AppointmentModel appointment) async {
    await _firestore.collection('appointments').doc(appointment.id).set(appointment.toMap());
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _firestore.collection('appointments').doc(appointmentId).update({'status': status});
  }

  @override
  Future<void> approveClinic(String clinicId) async {
    await _firestore.collection('clinics').doc(clinicId).update({
      'status': 'approved',
      'rejectionReason': null,
    });
  }

  @override
  Future<void> rejectClinic(String clinicId, String reason) async {
    await _firestore.collection('clinics').doc(clinicId).update({
      'status': 'rejected',
      'rejectionReason': reason,
    });
  }

  @override
  Future<void> updateClinicDetails(ClinicModel clinic) async {
    await _firestore.collection('clinics').doc(clinic.uid).update(clinic.toMap());
  }
        phone: '03708433612',
