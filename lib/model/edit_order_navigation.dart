import 'package:acey_order_management/utils/enum.dart';
import 'package:equatable/equatable.dart';

import 'order_model.dart';

class EditOrderNavigationModel extends Equatable {
  const EditOrderNavigationModel({
    required this.orderID,
    required this.partyName,
    required this.dateOfDelivery,
    required this.orderList,
    required this.quantityList,
    required this.remainingUpdate,
    required this.packagingType,
    required this.discount,
  });

  final num orderID;
  final String partyName;
  final DateTime dateOfDelivery;
  final List<OrderModel> orderList;
  final List<int> quantityList;
  final num remainingUpdate;
  final num discount;
  final PackingType packagingType;

  @override
  List<Object?> get props => [orderID, partyName, dateOfDelivery, orderList, quantityList, remainingUpdate, discount, packagingType];
}
