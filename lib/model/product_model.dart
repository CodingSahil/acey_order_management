import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String srNumber;
  final String referencePartNumber;
  final String aeplPartNumber;
  final String description;
  final num moq;
  final num mrp;
  final String mmOuterLength;
  final String inchOuterLength;
  final String mmTotalLength;
  final String inchTotalLength;

  const ProductModel({
    required this.id,
    required this.srNumber,
    required this.referencePartNumber,
    required this.aeplPartNumber,
    required this.description,
    required this.moq,
    required this.mrp,
    required this.mmOuterLength,
    required this.inchOuterLength,
    required this.mmTotalLength,
    required this.inchTotalLength,
  });

  ProductModel copyWith({
    int? id,
    String? srNumber,
    String? referencePartNumber,
    String? aeplPartNumber,
    String? description,
    num? moq,
    num? mrp,
    String? mmOuterLength,
    String? inchOuterLength,
    String? mmTotalLength,
    String? inchTotalLength,
  }) {
    return ProductModel(
      id: id ?? this.id,
      srNumber: srNumber ?? this.srNumber,
      referencePartNumber: referencePartNumber ?? this.referencePartNumber,
      aeplPartNumber: aeplPartNumber ?? this.aeplPartNumber,
      description: description ?? this.description,
      moq: moq ?? this.moq,
      mrp: mrp ?? this.mrp,
      mmOuterLength: mmOuterLength ?? this.mmOuterLength,
      inchOuterLength: inchOuterLength ?? this.inchOuterLength,
      mmTotalLength: mmTotalLength ?? this.mmTotalLength,
      inchTotalLength: inchTotalLength ?? this.inchTotalLength,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'srNumber': srNumber,
    'referencePartNumber': referencePartNumber,
    'aeplPartNumber': aeplPartNumber,
    'description': description,
    'moq': moq,
    'mrp': mrp,
    'mmOuterLength': mmOuterLength,
    'inchOuterLength': inchOuterLength,
    'mmTotalLength': mmTotalLength,
    'inchTotalLength': inchTotalLength,
  };

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      srNumber: json['srNumber'] ?? '',
      referencePartNumber: json['referencePartNumber'] ?? '',
      aeplPartNumber: json['aeplPartNumber'] ?? '',
      description: json['description'] ?? '',
      moq: json['moq'] ?? 0,
      mrp: json['mrp'] ?? 0,
      mmOuterLength: json['mmOuterLength'] ?? '',
      inchOuterLength: json['inchOuterLength'] ?? '',
      mmTotalLength: json['mmTotalLength'] ?? '',
      inchTotalLength: json['inchTotalLength'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, srNumber, referencePartNumber, aeplPartNumber, description, moq, mrp, mmOuterLength, inchOuterLength, mmTotalLength, inchTotalLength];
}
