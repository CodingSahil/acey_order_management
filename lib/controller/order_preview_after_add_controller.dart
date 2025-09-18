import 'dart:convert';
import 'dart:developer';

import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/utils/supabase/supabase_methods.dart';
import 'package:acey_order_management/utils/supabase/supabase_table_name.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class OrderPreviewAfterAddController extends GetxController {
  RxBool loader = false.obs;
  RxBool createLoader = false.obs;
  List<OrderDetailsModel> orderDetailsModelList = [];

  Future<void> getOrderList({bool isLoaderRequire = true}) async {
    if (isLoaderRequire) loader(true);
    orderDetailsModelList = await SupabaseMethods.getFromList<OrderDetailsModel>(
      tableKey: SupabaseTableKeys.orderDetails,
      fromJson: OrderDetailsModel.fromJson,
    );
    log(orderDetailsModelList.map((e) => jsonEncode(e.toJson())).toList().toString(), name: 'orderDetailsModelList.map => ');
    if (isLoaderRequire) loader(false);
  }

  Future<void> createOrder({required Map<String, dynamic> request, required BuildContext context}) async {
    createLoader(true);
    await SupabaseMethods.createObjectInTable(tableKey: SupabaseTableKeys.orderDetails, request: request);
    // try {
    //   await SupabaseMethods.createObjectInTable<OrderDetailsModel>(tableKey: SupabaseTableKeys.orderDetails, request: request);
    //   log('createOrder controller');
    //   await Future.delayed(Duration(seconds: 1));
    //   await getOrderList(isLoaderRequire: false);
    // } on Exception catch (e) {
    //   errorSnackBar(context: context, title: e.toString());
    //   createLoader(false);
    // }
    createLoader(false);
  }

  Future<void> updateOrder({required Map<String, dynamic> request, required BuildContext context, required num id}) async {
    createLoader(true);
    await SupabaseMethods.updateObjectInTable(tableKey: SupabaseTableKeys.orderDetails, request: request, id: id);
    // try {
    //   await SupabaseMethods.createObjectInTable<OrderDetailsModel>(tableKey: SupabaseTableKeys.orderDetails, request: request);
    //   log('createOrder controller');
    //   await Future.delayed(Duration(seconds: 1));
    //   await getOrderList(isLoaderRequire: false);
    // } on Exception catch (e) {
    //   errorSnackBar(context: context, title: e.toString());
    //   createLoader(false);
    // }
    createLoader(false);
  }
}
