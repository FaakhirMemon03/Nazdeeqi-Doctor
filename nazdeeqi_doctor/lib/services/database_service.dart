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
}

// -------------------------------------------------------------
// MOCK DATABASE IMPLEMENTATION (LOADED WITH RICH DUMMY DATA)
// -------------------------------------------------------------
class MockDatabaseService implements DatabaseService {
  final List<ClinicModel> mockClinics = [];
  final List<DoctorModel> mockDoctors = [];
  final List<AppointmentModel> mockAppointments = [];
  final List<UserModel> mockUsers = [];

  MockDatabaseService() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();

    // 1. Seed Users
    mockUsers.addAll([
      UserModel(
        uid: 'user_001',
        name: 'Faakhir Memon',
        email: 'faakhir@gmail.com',
        phone: '0333 1234567',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      UserModel(
        uid: 'user_002',
        name: 'Sara Khan',
        email: 'sara@gmail.com',
        phone: '0345 7654321',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);

    // 2. Seed Approved Clinics (Varying distances from typical central Karachi center e.g. Clifton/Saddar)
    mockClinics.addAll([
      ClinicModel(
        uid: 'clinic_001',
        name: 'Al-Khidmat Clinic & Diagnostic',
        email: 'alkhidmat@nazdeeqi.com',
        phone: '021-111-503-504',
        address: 'Nipa Chowrangi, Gulshan-e-Iqbal',
        city: 'Karachi',
        latitude: 24.9180, // Nipa
        longitude: 67.0970,
        isOpenToday: true,
        timings: 'Mon-Sat: 8:00 AM - 10:00 PM',
        certificateUrl: 'mock_cert.png',
        licenseUrl: 'mock_license.png',
        status: 'approved',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      ClinicModel(
        uid: 'clinic_002',
        name: 'Ziauddin Health Centre',
        email: 'ziauddin@nazdeeqi.com',
        phone: '021-36648237',
        address: 'North Nazimabad, Block B',
        city: 'Karachi',
        latitude: 24.9352, // North Nazimabad
        longitude: 67.0372,
        isOpenToday: true,
        timings: 'Mon-Sun: 9:00 AM - 9:00 PM',
        certificateUrl: 'mock_cert.png',
        licenseUrl: 'mock_license.png',
        status: 'approved',
        createdAt: now.subtract(const Duration(days: 18)),
      ),
      ClinicModel(
        uid: 'clinic_003',
        name: 'Clifton Medical Complex',
        email: 'clifton@nazdeeqi.com',
        phone: '021-35832001',
        address: 'Boat Basin, Clifton Block 5',
        city: 'Karachi',
        latitude: 24.8162, // Boat Basin
        longitude: 67.0330,
        isOpenToday: true,
        timings: 'Mon-Sat: 10:00 AM - 8:00 PM',
        certificateUrl: 'mock_cert.png',
        licenseUrl: 'mock_license.png',
        status: 'approved',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      ClinicModel(
        uid: 'clinic_004',
        name: 'Dow University Clinic',
        email: 'dow@nazdeeqi.com',
        phone: '021-99215754',
        address: 'Mission Road, Saddar Town',
        city: 'Karachi',
        latitude: 24.8598, // Dow / Civil
        longitude: 67.0102,
        isOpenToday: false, // Closed today demonstration
        timings: 'Mon-Fri: 9:00 AM - 5:00 PM',
        certificateUrl: 'mock_cert.png',
        licenseUrl: 'mock_license.png',
        status: 'approved',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      ClinicModel(
        uid: 'clinic_pending_01',
        name: 'Taj Consultant Clinic',
        email: 'taj@nazdeeqi.com',
        phone: '0321-9283748',
        address: 'M.A. Jinnah Road, opposite Taj Complex',
        city: 'Karachi',
        latitude: 24.8680,
        longitude: 67.0300,
        isOpenToday: true,
        timings: 'Mon-Sat: 11:00 AM - 10:00 PM',
        certificateUrl: 'mock_cert.png',
        licenseUrl: 'mock_license.png',
        status: 'pending', // Pending approval demo
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // 3. Seed Doctors
    mockDoctors.addAll([
      // Doctors for Clinic 001 (Al-Khidmat)
      DoctorModel(
        id: 'doc_001',
        clinicId: 'clinic_001',
        name: 'Dr. Tariq Mahmood',
        specialty: 'General Physician',
        fee: 800,
        avatarColor: '#E1F5EE',
        textColor: '#0F6E56',
        initials: 'TM',
        createdAt: now.subtract(const Duration(days: 19)),
      ),
      DoctorModel(
        id: 'doc_002',
        clinicId: 'clinic_001',
        name: 'Dr. Ayesha Alvi',
        specialty: 'Pediatrician',
        fee: 1000,
        avatarColor: '#FDF2E9',
        textColor: '#A04000',
        initials: 'AA',
        createdAt: now.subtract(const Duration(days: 19)),
      ),
      // Doctors for Clinic 002 (Ziauddin)
      DoctorModel(
        id: 'doc_003',
        clinicId: 'clinic_002',
        name: 'Dr. Kamran Ahmed',
        specialty: 'Cardiologist',
        fee: 1500,
        avatarColor: '#FADBD8',
        textColor: '#78281F',
        initials: 'KA',
        createdAt: now.subtract(const Duration(days: 17)),
      ),
      // Doctors for Clinic 003 (Clifton Medical)
      DoctorModel(
        id: 'doc_004',
        clinicId: 'clinic_003',
        name: 'Dr. Farhana Shah',
        specialty: 'Gynecologist',
        fee: 1800,
        avatarColor: '#EBDEF0',
        textColor: '#4A235A',
        initials: 'FS',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      DoctorModel(
        id: 'doc_005',
        clinicId: 'clinic_003',
        name: 'Dr. Zainab Fatimah',
        specialty: 'Dermatologist',
        fee: 2000,
        avatarColor: '#E8F8F5',
        textColor: '#117A65',
        initials: 'ZF',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ]);

    // 4. Seed Appointments
    mockAppointments.addAll([
      AppointmentModel(
        id: 'app_001',
        bookingCode: 'NDQ-K3A8P9',
        clinicId: 'clinic_001',
        clinicName: 'Al-Khidmat Clinic & Diagnostic',
        clinicAddress: 'Nipa Chowrangi, Gulshan-e-Iqbal',
        doctorId: 'doc_001',
        doctorName: 'Dr. Tariq Mahmood',
        userId: 'user_001',
        patientName: 'Faakhir Memon',
        patientPhone: '0333 1234567',
        complaint: 'Tez bukhar aur sar dard',
        timeSlot: '11:00 AM',
        appointmentDate: now.add(const Duration(days: 1)),
        status: 'confirmed',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      AppointmentModel(
        id: 'app_002',
        bookingCode: 'NDQ-M2W9R4',
        clinicId: 'clinic_003',
        clinicName: 'Clifton Medical Complex',
        clinicAddress: 'Boat Basin, Clifton Block 5',
        doctorId: 'doc_004',
        doctorName: 'Dr. Farhana Shah',
        userId: 'user_001',
        patientName: 'Ami Jan',
        patientPhone: '0333 1234567',
        complaint: 'Back pain routine checkup',
        timeSlot: '4:00 PM',
        appointmentDate: now.subtract(const Duration(days: 3)),
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ]);
  }

  @override
  Future<List<ClinicModel>> getClinics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(mockClinics);
  }

  @override
  Future<ClinicModel?> getClinicById(String clinicId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return mockClinics.firstWhere((c) => c.uid == clinicId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DoctorModel>> getDoctors(String clinicId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return mockDoctors.where((d) => d.clinicId == clinicId && d.isActive).toList();
  }

  @override
  Future<List<AppointmentModel>> getAppointments({String? clinicId, String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    Iterable<AppointmentModel> items = mockAppointments;
    if (clinicId != null) {
      items = items.where((a) => a.clinicId == clinicId);
    }
    if (userId != null) {
      items = items.where((a) => a.userId == userId);
    }
    final list = items.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> addDoctor(DoctorModel doctor) async {
    await Future.delayed(const Duration(milliseconds: 200));
    mockDoctors.add(doctor);
  }

  @override
  Future<void> updateDoctor(DoctorModel doctor) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = mockDoctors.indexWhere((d) => d.id == doctor.id);
    if (idx != -1) {
      mockDoctors[idx] = doctor;
    }
  }

  @override
  Future<void> deleteDoctor(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    mockDoctors.removeWhere((d) => d.id == doctorId);
  }

  @override
  Future<void> bookAppointment(AppointmentModel appointment) async {
    await Future.delayed(const Duration(milliseconds: 400));
    mockAppointments.add(appointment);
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = mockAppointments.indexWhere((a) => a.id == appointmentId);
    if (idx != -1) {
      mockAppointments[idx] = mockAppointments[idx].copyWith(status: status);
    }
  }

  @override
  Future<void> approveClinic(String clinicId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = mockClinics.indexWhere((c) => c.uid == clinicId);
    if (idx != -1) {
      mockClinics[idx] = mockClinics[idx].copyWith(status: 'approved', rejectionReason: null);
    }
  }

  @override
  Future<void> rejectClinic(String clinicId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = mockClinics.indexWhere((c) => c.uid == clinicId);
    if (idx != -1) {
      mockClinics[idx] = mockClinics[idx].copyWith(status: 'rejected', rejectionReason: reason);
    }
  }

  @override
  Future<void> updateClinicDetails(ClinicModel clinic) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = mockClinics.indexWhere((c) => c.uid == clinic.uid);
    if (idx != -1) {
      mockClinics[idx] = clinic;
    }
  }
}
