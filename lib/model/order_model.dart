import 'package:acey_order_management/model/product_model.dart';
import 'package:equatable/equatable.dart';

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
