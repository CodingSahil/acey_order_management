import 'package:acey_order_management/utils/date_functions.dart';
import 'package:acey_order_management/utils/enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SalesRepresentativeModel extends Equatable {
  final int? id;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? deletedAt;
  final String name;
  final String email;
  final String contactNumber;
  final String password;
  final bool isResigned;
  final Zones zone;

  const SalesRepresentativeModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.email,
    required this.contactNumber,
    required this.password,
    this.isResigned = false,
    required this.zone,
  });

  factory SalesRepresentativeModel.fromJson(Map<String, dynamic> json) {
    return SalesRepresentativeModel(
      id: json['id'] != null ? json['id'] as int : -1000,
      createdAt:
          json['createdAt'] != null && json['createdAt'] is String && (json['createdAt'] as String).isNotEmpty
              ? DateFormatter.convertStringIntoTimeStamp(json['createdAt'] as String)
              : Timestamp.now(),
      updatedAt:
          json['updatedAt'] != null && json['updatedAt'] is String && (json['updatedAt'] as String).isNotEmpty
              ? DateFormatter.convertStringIntoTimeStamp(json['updatedAt'] as String)
              : null,
      deletedAt:
          json['deletedAt'] != null && json['deletedAt'] is String && (json['deletedAt'] as String).isNotEmpty
              ? DateFormatter.convertStringIntoTimeStamp(json['deletedAt'] as String)
              : null,
      name:
          json['name'] != null && json['name'] is String && (json['name'] as String).isNotEmpty
              ? json['name'] as String
              : '',
      email:
          json['email'] != null && json['email'] is String && (json['email'] as String).isNotEmpty
              ? json['email'] as String
              : '',
      contactNumber:
          json['contactNumber'] != null && json['contactNumber'] is String && (json['contactNumber'] as String).isNotEmpty
              ? json['contactNumber'] as String
              : '',
      password:
          json['password'] != null && json['password'] is String && (json['password'] as String).isNotEmpty
              ? json['password'] as String
              : '',
      isResigned: json['isResigned'] ?? false,
      zone: convertStringToZones(json['zone']),
    );
  }

  SalesRepresentativeModel copyWith({
    int? id,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? deletedAt,
    String? name,
    String? email,
    String? contactNumber,
    String? password,
    bool? isResigned,
    Zones? zone,
  }) {
    return SalesRepresentativeModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      password: password ?? this.password,
      isResigned: isResigned ?? this.isResigned,
      zone: zone ?? this.zone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id != -1000) 'id': id,
      if (createdAt != null) 'createdAt': createdAt!.toDate().toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toDate().toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toDate().toIso8601String(),
      if (name.isNotEmpty) 'name': name,
      if (email.isNotEmpty) 'email': email,
      if (contactNumber.isNotEmpty) 'contactNumber': contactNumber,
      if (password.isNotEmpty) 'password': password,
      'isResigned': isResigned,
      'zone': convertZonesToString(zone),
    };
  }

  @override
  List<Object?> get props => [id, createdAt, updatedAt, deletedAt, name, email, contactNumber, password, isResigned, zone];
}
