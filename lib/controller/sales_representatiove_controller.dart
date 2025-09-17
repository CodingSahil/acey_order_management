import 'dart:developer';

import 'package:acey_order_management/model/sales_representative_model.dart';
import 'package:acey_order_management/utils/supabase/supabase_methods.dart';
import 'package:acey_order_management/utils/supabase/supabase_table_name.dart';
import 'package:get/get.dart';

class SalesRepresentativeController extends GetxController {
  List<SalesRepresentativeModel> salesRepresentatives = [];
  RxBool loader = false.obs;
  RxBool buttonLoader = false.obs;

  Future<void> getAllSalesRepresentatives({bool isLoader = true}) async {
    if (isLoader) loader(true);
    salesRepresentatives = await SupabaseMethods.getFromList<SalesRepresentativeModel>(
      tableKey: SupabaseTableKeys.salesRepresentative,
      fromJson: SalesRepresentativeModel.fromJson,
    );
    log(salesRepresentatives.length.toString(), name: "salesRepresentatives => ");
    if (isLoader) loader(false);
    update(["update_sales_representative"]);
  }

  Future<void> addSalesRepresentative(SalesRepresentativeModel salesRepresentative) async {
    buttonLoader(true);
    await SupabaseMethods.createObjectInTable(
      tableKey: SupabaseTableKeys.salesRepresentative,
      request: salesRepresentative.toJson(),
    );
    await getAllSalesRepresentatives(isLoader: false);
    buttonLoader(false);
  }

  Future<void> editSalesRepresentative(SalesRepresentativeModel salesRepresentative) async {
    buttonLoader(true);
    await SupabaseMethods.updateObjectInTable(
      tableKey: SupabaseTableKeys.salesRepresentative,
      id: salesRepresentative.id!,
      request: salesRepresentative.toJson(),
    );
    await getAllSalesRepresentatives(isLoader: false);
    buttonLoader(false);
  }
}
