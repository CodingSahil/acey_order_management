import 'package:acey_order_management/utils/date_functions.dart';
import 'package:acey_order_management/utils/enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final num id;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? deletedAt;
  final String name;
  final String email;
  final String password;
  final String mobileNumber;
  final UserType userType;
  final String? fcmToken;
  final bool isActiveCurrently;
  final DateTime? lastActiveTime;

  const UserModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.email,
    required this.password,
    required this.mobileNumber,
    required this.userType,
    this.fcmToken,
    this.isActiveCurrently = false,
    this.lastActiveTime,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] != null ? json['id'] as num : -1000,
      createdAt:
          json['createdAt'] != null && json['createdAt'] is String && (json['createdAt'] as String).isNotEmpty
              ? DateFormatter.convertStringIntoTimeStamp(json['createdAt'] as String)
              : Timestamp.now(),
      updatedAt: json['updatedAt'] != null && json['updatedAt'] is String && (json['updatedAt'] as String).isNotEmpty ? DateFormatter.convertStringIntoTimeStamp(json['updatedAt'] as String) : null,
      deletedAt: json['deletedAt'] != null && json['deletedAt'] is String && (json['deletedAt'] as String).isNotEmpty ? DateFormatter.convertStringIntoTimeStamp(json['deletedAt'] as String) : null,
      name: json['name'] != null && json['name'] is String && (json['name'] as String).isNotEmpty ? json['name'] as String : '',
      email: json['email'] != null && json['email'] is String && (json['email'] as String).isNotEmpty ? json['email'] as String : '',
      password: json['password'] != null && json['password'] is String && (json['password'] as String).isNotEmpty ? json['password'] as String : '',
      mobileNumber: json['mobileNumber'] != null && json['mobileNumber'] is String && (json['mobileNumber'] as String).isNotEmpty ? json['mobileNumber'] as String : '',
      userType: json['userType'] != null && json['userType'] is String && (json['userType'] as String).isNotEmpty ? convertStringToEnum(json['userType'] as String) : UserType.None,
      fcmToken: json['fcmToken'] != null && json['fcmToken'] is String && (json['fcmToken'] as String).isNotEmpty ? json['fcmToken'] as String : null,
      isActiveCurrently: json['isActiveCurrently'] ?? false,
      lastActiveTime: json['lastActiveTime'] != null ? DateFormatter.convertTimeStampIntoDateTime(json['lastActiveTime'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != -1000) 'id': id,
    if (createdAt != null) 'createdAt': DateFormatter.convertTimeStampIntoString(createdAt!),
    if (updatedAt != null) 'updatedAt': DateFormatter.convertTimeStampIntoString(updatedAt!),
    if (deletedAt != null) 'deletedAt': DateFormatter.convertTimeStampIntoString(deletedAt!),
    if (name.isNotEmpty) 'name': name,
    if (email.isNotEmpty) 'email': email,
    if (password.isNotEmpty) 'password': password,
    if (mobileNumber.isNotEmpty) 'mobileNumber': mobileNumber,
    if (userType != UserType.None) 'userType': convertEnumToString(userType),
    if (fcmToken != null && fcmToken!.isNotEmpty) 'fcmToken': fcmToken,
    'isActiveCurrently': isActiveCurrently,
    if (lastActiveTime != null) 'lastActiveTime': lastActiveTime?.toIso8601String(),
  };

  UserModel copyWith({
    num? id,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? deletedAt,
    String? name,
    String? email,
    String? password,
    String? mobileNumber,
    UserType? userType,
    String? fcmToken,
    bool? isActiveCurrently,
    DateTime? lastActiveTime,
  }) {
    return UserModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      userType: userType ?? this.userType,
      fcmToken: fcmToken ?? this.fcmToken,
      isActiveCurrently: isActiveCurrently ?? this.isActiveCurrently,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, updatedAt, deletedAt, name, email, password, mobileNumber, userType, fcmToken, isActiveCurrently, lastActiveTime];
}
