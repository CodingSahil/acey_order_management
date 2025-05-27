import 'package:acey_order_management/model/product_model.dart';
import 'package:acey_order_management/utils/date_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class OrderDetailsModel extends Equatable {
  const OrderDetailsModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.userID,
    required this.orderDetails,
    required this.excelSheetURL,
    required this.partyName,
    required this.deliveryDate,
    this.numberOfItems,
    this.totalQuantity,
    this.totalPrice,
    this.gstAmount,
    this.grandTotal,
  });

  final num id;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? deletedAt;
  final num userID;
  final Map<String, dynamic> orderDetails;
  final String excelSheetURL;
  final String partyName;
  final DateTime deliveryDate;
  final num? numberOfItems;
  final num? totalQuantity;
  final num? totalPrice;
  final num? gstAmount;
  final num? grandTotal;

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      id: json['id'] as num? ?? 0,
      createdAt:
          json['createdAt'] != null && json['createdAt'] is String && (json['createdAt'] as String).isNotEmpty
              ? DateFormatter.convertStringIntoTimeStamp(json['createdAt'] as String)
              : Timestamp.now(),
      updatedAt: json['updatedAt'] != null && json['updatedAt'] is String && (json['updatedAt'] as String).isNotEmpty ? DateFormatter.convertStringIntoTimeStamp(json['updatedAt'] as String) : null,
      deletedAt: json['deletedAt'] != null && json['deletedAt'] is String && (json['deletedAt'] as String).isNotEmpty ? DateFormatter.convertStringIntoTimeStamp(json['deletedAt'] as String) : null,
      userID: json['userID'] != null ? json['userID'] as num : -1000,
      orderDetails: json['orderDetails'] ?? {},
      excelSheetURL: json['excelSheetURL'] != null ? json['excelSheetURL'] as String : '',
      partyName: json['partyName'] != null ? json['partyName'] as String : '',
      deliveryDate: json['deliveryDate'] != null ? DateFormatter.convertStringIntoDateTime(json['deliveryDate'] as String) : DateTime.now(),
      numberOfItems: json['numberOfItems'] != null ? json['numberOfItems'] as num : 0,
      totalQuantity: json['totalQuantity'] != null ? json['totalQuantity'] as num : 0,
      totalPrice: json['totalPrice'] != null ? json['totalPrice'] as num : 0,
      gstAmount: json['gstAmount'] != null ? json['gstAmount'] as num : 0,
      grandTotal: json['grandTotal'] != null ? json['grandTotal'] as num : 0,
    );
  }

  OrderDetailsModel copyWith({
    num? id,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? deletedAt,
    num? userID,
    Map<String, dynamic>? orderDetails,
    String? excelSheetURL,
    String? partyName,
    DateTime? deliveryDate,
    num? numberOfItems,
    num? totalQuantity,
    num? totalPrice,
    num? gstAmount,
    num? grandTotal,
  }) {
    return OrderDetailsModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      userID: userID ?? this.userID,
      orderDetails: orderDetails ?? this.orderDetails,
      excelSheetURL: excelSheetURL ?? this.excelSheetURL,
      partyName: partyName ?? this.partyName,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      numberOfItems: numberOfItems ?? this.numberOfItems,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalPrice: totalPrice ?? this.totalPrice,
      gstAmount: gstAmount ?? this.gstAmount,
      grandTotal: grandTotal ?? this.grandTotal,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (createdAt != null) 'createdAt': DateFormatter.convertTimeStampIntoString(createdAt!),
    if (updatedAt != null) 'updatedAt': DateFormatter.convertTimeStampIntoString(updatedAt!),
    if (deletedAt != null) 'deletedAt': DateFormatter.convertTimeStampIntoString(deletedAt!),
    'userID': userID,
    'orderDetails': orderDetails,
    if (excelSheetURL.isNotEmpty) 'excelSheetURL': excelSheetURL,
    if (partyName.isNotEmpty) 'partyName': partyName,
    'deliveryDate': DateFormatter.convertDateTimeIntoString(deliveryDate),
    if (numberOfItems != null && numberOfItems != 0 && numberOfItems != -1000) 'numberOfItems': numberOfItems,
    if (totalQuantity != null && totalQuantity != 0 && totalQuantity != -1000) 'totalQuantity': totalQuantity,
    if (totalPrice != null && totalPrice != 0 && totalPrice != -1000) 'totalPrice': totalPrice,
    if (gstAmount != null && gstAmount != 0 && gstAmount != -1000) 'gstAmount': gstAmount,
    if (grandTotal != null && grandTotal != 0 && grandTotal != -1000) 'grandTotal': grandTotal,
  };

  @override
  List<Object?> get props => [id, createdAt, updatedAt, deletedAt, userID, orderDetails, excelSheetURL, partyName, deliveryDate, numberOfItems, totalQuantity, totalPrice, gstAmount, grandTotal];
}

class OrderModel extends Equatable {
  final ProductModel productModel;
  final int? quantity;

  const OrderModel({required this.productModel, this.quantity});

  OrderModel copyWith({ProductModel? productModel, int? quantity}) {
    return OrderModel(productModel: productModel ?? this.productModel, quantity: quantity ?? this.quantity);
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(productModel: ProductModel.fromJson(json['productModel']), quantity: json['quantity']);
  }

  Map<String, dynamic> toJson() {
    return {'productModel': productModel.toJson(), if (quantity != null) 'quantity': quantity};
  }

  @override
  List<Object?> get props => [productModel, quantity];
}
