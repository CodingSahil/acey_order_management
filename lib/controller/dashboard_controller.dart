import 'dart:developer';

import 'package:acey_order_management/model/product_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardController {
  DashboardController();

  RxBool loader = false.obs;
  List<ProductModel> productList = [];

  Future<void> getProductList({bool isLoaderRequire = false}) async{
    loader(true);

    final future = await Supabase.instance.client.from('products').select();
    productList = future.map((e) => ProductModel.fromJson(e),).toList();
    log('productList.length => ${productList.length}');

    loader(false);
  }
}
