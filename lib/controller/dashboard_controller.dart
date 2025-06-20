import 'dart:convert';
import 'dart:developer';

import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/model/product_model.dart';
import 'package:acey_order_management/utils/date_functions.dart';
import 'package:acey_order_management/utils/storage_keys.dart';
import 'package:acey_order_management/utils/supabase/supabase_methods.dart';
import 'package:acey_order_management/utils/supabase/supabase_table_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  RxBool loader = false.obs;
  RxBool updateLoader = false.obs;
  List<ProductModel> productList = [];
  List<OrderDetailsModel> orderDetailsList = [];

  Future<void> getProductList({bool isLoaderRequire = false}) async {
    loader(true);
    productList = await SupabaseMethods.getFromList<ProductModel>(tableKey: SupabaseTableKeys.products, fromJson: ProductModel.fromJson);
    log('productList.length => ${productList.length}');
    loader(false);
  }

  Future<void> getOrderList({ required num userID}) async {
    loader(true);
    List<OrderDetailsModel> orderDetailsListTemp = await SupabaseMethods.getFromList<OrderDetailsModel>(tableKey: SupabaseTableKeys.orderDetails, fromJson: OrderDetailsModel.fromJson);
    orderDetailsList = orderDetailsListTemp.where((element) => element.userID == userID).toList();
    log('orderDetailsList.length => ${orderDetailsList.map((e) => jsonEncode(e.toJson())).toList()}');
    loader(false);
    update([UpdateKeys.updateOrderListInDashboard]);
  }

  Future<void> deleteOrder({required Timestamp deletedAt, required num orderID, required num userID}) async {
    await SupabaseMethods.updateObjectInTable(tableKey: SupabaseTableKeys.orderDetails, request: {'deletedAt': DateFormatter.convertTimeStampIntoString(deletedAt)}, id: orderID);
    await Future.delayed(Duration(milliseconds: 250));
    await getOrderList(userID: userID);
    await Future.delayed(Duration(milliseconds: 750));
    update([UpdateKeys.updateOrderListInDashboard]);
  }
}
