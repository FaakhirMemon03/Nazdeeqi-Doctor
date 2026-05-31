import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final bool isOpenToday;
  final String timings;
  final String certificateUrl;
  final String licenseUrl;
  final List<String> agreementUrls;
  final String status; // 'pending' | 'approved' | 'rejected' | 'suspended'
  final String? rejectionReason;
  final DateTime createdAt;

  ClinicModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.city = 'Karachi',
    this.latitude,
    this.longitude,
    this.isOpenToday = true,
    this.timings = 'Mon-Sat: 9:00 AM - 9:00 PM',
    required this.certificateUrl,
    required this.licenseUrl,
    this.agreementUrls = const [],
    this.status = 'pending',
    this.rejectionReason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'isOpenToday': isOpenToday,
      'timings': timings,
      'certificateUrl': certificateUrl,
      'licenseUrl': licenseUrl,
      'agreementUrls': agreementUrls,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClinicModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ClinicModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? 'Karachi',
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      isOpenToday: map['isOpenToday'] ?? true,
      timings: map['timings'] ?? 'Mon-Sat: 9:00 AM - 9:00 PM',
      certificateUrl: map['certificateUrl'] ?? '',
      licenseUrl: map['licenseUrl'] ?? '',
      agreementUrls: List<String>.from(map['agreementUrls'] ?? []),
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
      createdAt: parseDate(map['createdAt']),
    );
  }

  ClinicModel copyWith({
    String? name,
    String? phone,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    bool? isOpenToday,
    String? timings,
    String? status,
    String? rejectionReason,
  }) {
    return ClinicModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOpenToday: isOpenToday ?? this.isOpenToday,
      timings: timings ?? this.timings,
      certificateUrl: certificateUrl,
      licenseUrl: licenseUrl,
      agreementUrls: agreementUrls,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
    );
  }
}
