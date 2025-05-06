import 'dart:developer';

import 'package:acey_order_management/model/product_model.dart';
import 'package:acey_order_management/utils/supabase/supabase_methods.dart';
import 'package:acey_order_management/utils/supabase/supabase_table_name.dart';
import 'package:get/get.dart';

class DashboardController {
  DashboardController();

  RxBool loader = false.obs;
  List<ProductModel> productList = [];

  Future<void> getProductList({bool isLoaderRequire = false}) async {
    loader(true);

    productList = await SupabaseMethods.getFromList<ProductModel>(tableKey: SupabaseTableKeys.products, fromJson: ProductModel.fromJson);
    log('productList.length => ${productList.length}');

    loader(false);
  }
}
