import 'package:acey_order_management/controller/dashboard_controller.dart';
import 'package:acey_order_management/controller/login_controller.dart';
import 'package:acey_order_management/controller/order_preview_after_add_controller.dart';
import 'package:acey_order_management/controller/sales_representatiove_controller.dart';
import 'package:get/get.dart';

class StoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => OrderPreviewAfterAddController());
    Get.lazyPut(() => SalesRepresentativeController());
  }
}
