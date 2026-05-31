import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String id;
  final String clinicId;
  final String name;
  final String specialty;
  final int fee;
  final String avatarColor; // hex value e.g. '#E1F5EE'
  final String textColor; // hex value e.g. '#0F6E56'
  final String initials;
  final List<String> availableSlots;
  final bool isActive;
  final DateTime createdAt;

  DoctorModel({
    required this.id,
    required this.clinicId,
    required this.name,
    required this.specialty,
    required this.fee,
    this.avatarColor = '#E1F5EE',
    this.textColor = '#0F6E56',
    required this.initials,
    this.availableSlots = const ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '2:00 PM', '4:00 PM', '5:00 PM'],
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clinicId': clinicId,
      'name': name,
      'specialty': specialty,
      'fee': fee,
      'avatarColor': avatarColor,
      'textColor': textColor,
      'initials': initials,
      'availableSlots': availableSlots,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return DoctorModel(
      id: map['id'] ?? '',
      clinicId: map['clinicId'] ?? '',
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      fee: (map['fee'] ?? 0) as int,
      avatarColor: map['avatarColor'] ?? '#E1F5EE',
      textColor: map['textColor'] ?? '#0F6E56',
      initials: map['initials'] ?? '',
      availableSlots: List<String>.from(map['availableSlots'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: parseDate(map['createdAt']),
    );
  }

  DoctorModel copyWith({
    String? name,
    String? specialty,
    int? fee,
    String? avatarColor,
    String? textColor,
    String? initials,
    List<String>? availableSlots,
    bool? isActive,
  }) {
    return DoctorModel(
      id: id,
      clinicId: clinicId,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      fee: fee ?? this.fee,
      avatarColor: avatarColor ?? this.avatarColor,
      textColor: textColor ?? this.textColor,
      initials: initials ?? this.initials,
      availableSlots: availableSlots ?? this.availableSlots,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
