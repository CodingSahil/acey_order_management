import 'package:acey_order_management/utils/enum.dart';
import 'package:equatable/equatable.dart';

import 'order_model.dart';

class EditOrderNavigationModel extends Equatable {
  const EditOrderNavigationModel({
    this.orderID,
    required this.partyName,
    required this.dateOfDelivery,
    required this.orderList,
    required this.quantityList,
    this.remainingUpdate,
    required this.packagingType,
    required this.discount,
    required this.onAddEdit,
  });

  final num? orderID;
  final String partyName;
  final DateTime dateOfDelivery;
  final List<OrderModel> orderList;
  final List<int> quantityList;
  final num? remainingUpdate;
  final num discount;
  final PackingType packagingType;
  final void Function() onAddEdit;

  @override
  List<Object?> get props => [orderID, partyName, dateOfDelivery, orderList, quantityList, remainingUpdate, discount, packagingType, onAddEdit];
}
