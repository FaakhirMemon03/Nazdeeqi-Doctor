import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String bookingCode;
  final String clinicId;
  final String clinicName;
  final String clinicAddress;
  final String doctorId;
  final String doctorName;
  final String userId;
  final String patientName;
  final String patientPhone;
  final String complaint;
  final String timeSlot;
  final DateTime appointmentDate;
  final String status; // 'confirmed' | 'cancelled' | 'completed'
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    String? bookingCode,
    required this.clinicId,
    required this.clinicName,
    required this.clinicAddress,
    required this.doctorId,
    required this.doctorName,
    required this.userId,
    required this.patientName,
    required this.patientPhone,
    this.complaint = '',
    required this.timeSlot,
    required this.appointmentDate,
    this.status = 'confirmed',
    required this.createdAt,
  }) : bookingCode = bookingCode ?? _generateBookingCode();

  static String _generateBookingCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    String code = 'NDQ-';
    for (int i = 0; i < 6; i++) {
      code += chars[rand.nextInt(chars.length)];
    }
    return code;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingCode': bookingCode,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'userId': userId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'complaint': complaint,
      'timeSlot': timeSlot,
      'appointmentDate': appointmentDate.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return AppointmentModel(
      id: map['id'] ?? '',
      bookingCode: map['bookingCode'],
      clinicId: map['clinicId'] ?? '',
      clinicName: map['clinicName'] ?? '',
      clinicAddress: map['clinicAddress'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      userId: map['userId'] ?? '',
      patientName: map['patientName'] ?? '',
      patientPhone: map['patientPhone'] ?? '',
      complaint: map['complaint'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      appointmentDate: parseDate(map['appointmentDate']),
      status: map['status'] ?? 'confirmed',
      createdAt: parseDate(map['createdAt']),
    );
  }

  AppointmentModel copyWith({
    String? status,
  }) {
    return AppointmentModel(
      id: id,
      bookingCode: bookingCode,
      clinicId: clinicId,
      clinicName: clinicName,
      clinicAddress: clinicAddress,
      doctorId: doctorId,
      doctorName: doctorName,
      userId: userId,
      patientName: patientName,
      patientPhone: patientPhone,
      complaint: complaint,
      timeSlot: timeSlot,
      appointmentDate: appointmentDate,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
