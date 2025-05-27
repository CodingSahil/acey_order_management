import 'dart:convert';
import 'dart:developer';

import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/model/product_model.dart';
import 'package:acey_order_management/utils/storage_keys.dart';
import 'package:acey_order_management/utils/supabase/supabase_methods.dart';
import 'package:acey_order_management/utils/supabase/supabase_table_name.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  RxBool loader = false.obs;
  List<ProductModel> productList = [];
  List<OrderDetailsModel> orderDetailsList = [];

  Future<void> getProductList({bool isLoaderRequire = false}) async {
    loader(true);
    productList = await SupabaseMethods.getFromList<ProductModel>(tableKey: SupabaseTableKeys.products, fromJson: ProductModel.fromJson);
    log('productList.length => ${productList.length}');
    loader(false);
  }

  Future<void> getOrderList({bool isLoaderRequire = false, required num userID}) async {
    loader(true);
    List<OrderDetailsModel> orderDetailsListTemp = await SupabaseMethods.getFromList<OrderDetailsModel>(tableKey: SupabaseTableKeys.orderDetails, fromJson: OrderDetailsModel.fromJson);
    orderDetailsList = orderDetailsListTemp.where((element) => element.userID == userID).toList();
    log('orderDetailsList.length => ${orderDetailsList.map((e) => jsonEncode(e.toJson())).toList()}');
    loader(false);
    update([UpdateKeys.updateOrderListInDashboard]);
  }
}
