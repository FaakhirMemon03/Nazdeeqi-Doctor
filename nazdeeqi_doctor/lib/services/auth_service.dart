import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/clinic_model.dart';
import 'database_service.dart';
import 'service_locator.dart';

abstract class AuthService {
  String? get currentUid;
  String? get currentEmail;
  Future<Map<String, dynamic>?> login(String email, String password, String role);
  Future<UserModel> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
  });
  Future<ClinicModel> registerClinic({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
    required String certificateUrl,
    required String licenseUrl,
    required List<String> agreementUrls,
    double? latitude,
    double? longitude,
  });
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
}

// -------------------------------------------------------------
// FIREBASE AUTH SERVICE IMPLEMENTATION
// -------------------------------------------------------------
class FirebaseAuthService implements AuthService {
  final fauth.FirebaseAuth _auth = fauth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  String? get currentEmail => _auth.currentUser?.email;

  @override
  Future<Map<String, dynamic>?> login(String email, String password, String role) async {
    try {
      fauth.UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) return null;

      if (role == 'admin') {
        // Query Admins
        final doc = await _firestore.collection('admins').doc(uid).get();
        if (doc.exists) {
          return {'role': 'admin', 'data': doc.data()};
        }
        await _auth.signOut();
        throw Exception("Ye Account Admin role se registered nahi hai.");
      } else if (role == 'clinic') {
        // Query Clinics
        final doc = await _firestore.collection('clinics').doc(uid).get();
        if (doc.exists) {
          final clinicData = ClinicModel.fromMap(doc.data()!);
          if (clinicData.status == 'pending') {
            await _auth.signOut();
            throw Exception("Aapki clinic registration abhi pending approval hai.");
          } else if (clinicData.status == 'rejected') {
            await _auth.signOut();
            throw Exception("Aapki clinic request reject ho chuki hai. Reason: ${clinicData.rejectionReason ?? 'None'}");
          } else if (clinicData.status == 'suspended') {
            await _auth.signOut();
            throw Exception("Aapki clinic temporary block (suspended) ki gayi hai.");
          }
          return {'role': 'clinic', 'data': doc.data()};
        }
        await _auth.signOut();
        throw Exception("Ye Account Clinic role se registered nahi hai.");
      } else {
        // Query Patients (User)
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          final userData = UserModel.fromMap(doc.data()!);
          if (userData.status == 'banned') {
            await _auth.signOut();
            throw Exception("Aapka account block (banned) ho chuka hai.");
          }
          return {'role': 'patient', 'data': doc.data()};
        }
        await _auth.signOut();
        throw Exception("Ye Account Patient/User role se registered nahi hai.");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      fauth.UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final user = UserModel(
        uid: uid,
        name: name,
        email: email.toLowerCase(),
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ClinicModel> registerClinic({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
    required String certificateUrl,
    required String licenseUrl,
    required List<String> agreementUrls,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Create user auth for the clinic
      fauth.UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      final clinic = ClinicModel(
        uid: uid,
        name: name,
        email: email.toLowerCase(),
        phone: phone,
        address: address,
        city: city,
        latitude: latitude,
        longitude: longitude,
        certificateUrl: certificateUrl,
        licenseUrl: licenseUrl,
        agreementUrls: agreementUrls,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('clinics').doc(uid).set(clinic.toMap());
      // Log them out immediately after registering because approval is pending
      await _auth.signOut();
      return clinic;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}

// -------------------------------------------------------------
// MOCK AUTH SERVICE IMPLEMENTATION (FOR OFFLINE / TEST MODE)
// -------------------------------------------------------------
class MockAuthService implements AuthService {
  String? _uid;
  String? _email;

  @override
  String? get currentUid => _uid;

  @override
  String? get currentEmail => _email;

  @override
  Future<Map<String, dynamic>?> login(String email, String password, String role) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final db = ServiceLocator.database;

    if (role == 'admin') {
      if (email.toLowerCase() == 'admin@nazdeeqi.com' && password == 'admin123') {
        _uid = 'admin_uid_001';
        _email = email;
        return {
          'role': 'admin',
          'data': {'uid': _uid, 'email': _email, 'name': 'Nazdeeqi Admin'}
        };
      }
      throw Exception("Ghalat admin credentials. Default admin: admin@nazdeeqi.com / admin123");
    } else if (role == 'clinic') {
      final clinics = await db.getClinics();
      final clinic = clinics.firstWhere(
        (c) => c.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception("Aapki clinic email register nahi hai."),
      );

      // In mock, let's bypass complex bcrypt logic with simple comparison
      if (password.length < 4) {
        throw Exception("Password short hai. Minimal length: 4 characters.");
      }

      if (clinic.status == 'pending') {
        throw Exception("Aapki clinic registration abhi pending approval hai.");
      } else if (clinic.status == 'rejected') {
        throw Exception("Aapki clinic request reject ho chuki hai. Reason: ${clinic.rejectionReason ?? 'None'}");
      }

      _uid = clinic.uid;
      _email = clinic.email;
      return {'role': 'clinic', 'data': clinic.toMap()};
    } else {
      // Patient Login
      final users = (db as MockDatabaseService).mockUsers;
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception("Aapka account patient list me nahi hai. Please Sign Up karein."),
      );

      _uid = user.uid;
      _email = user.email;
      return {'role': 'patient', 'data': user.toMap()};
    }
  }

  @override
  Future<UserModel> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final db = ServiceLocator.database as MockDatabaseService;

    if (db.mockUsers.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw Exception("Ye email pehle se registered hai.");
    }

    final user = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email.toLowerCase(),
      phone: phone,
      createdAt: DateTime.now(),
    );

    db.mockUsers.add(user);
    _uid = user.uid;
    _email = user.email;
    return user;
  }

  @override
  Future<ClinicModel> registerClinic({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
    required String certificateUrl,
    required String licenseUrl,
    required List<String> agreementUrls,
    double? latitude,
    double? longitude,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final db = ServiceLocator.database as MockDatabaseService;

    if (db.mockClinics.any((c) => c.email.toLowerCase() == email.toLowerCase())) {
      throw Exception("Ye clinic email pehle se registered hai.");
    }

    final clinic = ClinicModel(
      uid: 'clinic_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email.toLowerCase(),
      phone: phone,
      address: address,
      city: city,
      latitude: latitude ?? 24.8607, // Default Karachi lat
      longitude: longitude ?? 67.0011, // Default Karachi lng
      certificateUrl: certificateUrl,
      licenseUrl: licenseUrl,
      agreementUrls: agreementUrls,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    db.mockClinics.add(clinic);
    return clinic;
  }

  @override
  Future<void> logout() async {
    _uid = null;
    _email = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Simulate email send
  }
}
