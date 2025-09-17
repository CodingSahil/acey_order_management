import 'dart:convert';
import 'package:acey_order_management/controller/dashboard_controller.dart';
import 'package:acey_order_management/controller/order_preview_after_add_controller.dart';
import 'package:acey_order_management/main.dart';
import 'package:acey_order_management/model/edit_order_navigation.dart';
import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/model/user_model.dart';
import 'package:acey_order_management/utils/app_bar.dart';
import 'package:acey_order_management/utils/app_colors.dart';
import 'package:acey_order_management/utils/date_functions.dart';
import 'package:acey_order_management/utils/loader.dart';
import 'package:acey_order_management/utils/routes/routes.dart';
import 'package:acey_order_management/utils/storage_keys.dart';
import 'package:acey_order_management/view/add_edit_order.dart';
import 'package:acey_order_management/view/login_view.dart';
import 'package:acey_order_management/view/order_details_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  UserModel? userModel;
  late final GetStorage getStorage;
  late final DashboardController dashboardController;
  late final OrderPreviewAfterAddController orderPreviewAfterAddController;
  RxBool logoutLoader = false.obs;

  @override
  void initState() {
    super.initState();
    getStorage = GetStorage();
    dashboardController = Get.find<DashboardController>();
    orderPreviewAfterAddController = Get.find<OrderPreviewAfterAddController>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var data = await getStorage.read(StorageKeys.userDetails);
      userModel = UserModel.fromJson(jsonDecode(data.toString()));
      if (userModel != null) {
        await dashboardController.getOrderList(userID: userModel!.id);
      }
    });
  }

  Future<void> onAddEdit() async {
    if (userModel != null) {
      await dashboardController.getOrderList(userID: userModel!.id);
      dashboardController.update([UpdateKeys.updateOrderListInDashboard]);
    }
  }

  Future<void> onDelete(int orderID) async {
    if (userModel != null) {
      await dashboardController.deleteOrder(deletedAt: Timestamp.now(), orderID: orderID, userID: userModel!.id);
      dashboardController.update([UpdateKeys.updateOrderListInDashboard]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: commonAppBar(title: 'Dashboard'),
        floatingActionButton:
            dashboardController.orderDetailsList.isNotEmpty
                ? FloatingActionButton.extended(
                  onPressed: () {
                    Get.to(() => AddEditOrderView(arguments: onAddEdit));
                  },
                  backgroundColor: Colors.blueAccent,
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text('Add Order', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                )
                : SizedBox.shrink(),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(
              left: 30.w,
              right: 30.w,
              top: MediaQuery.sizeOf(context).height * 0.04 + (isIOS ? MediaQuery.sizeOf(context).height * 0.035 : 0),
              bottom: MediaQuery.sizeOf(context).height * 0.02 + (isIOS ? MediaQuery.sizeOf(context).height * 0.01 : 0),
            ),
            child: StatefulBuilder(
              builder: (context, setDrawerState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 18.h),
                    if (userModel != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userModel!.email, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                          SizedBox(height: 18.h),
                          Divider(color: Colors.black.withAlpha((255 * 0.4).toInt()), height: 1, thickness: 0.5),
                          SizedBox(height: 30.h),
                          // SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),
                        ],
                      ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(Routes.salesRepresentationView);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 20, color: Colors.black),
                          SizedBox(width: 30.w),
                          Text(
                            'Sales Representative',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: Colors.black.withAlpha((255 * 0.5).toInt()),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        logoutLoader(true);
                        GetStorage().erase();
                        await Future.delayed(const Duration(seconds: 1));
                        logoutLoader(false);
                        Get.offAll(() => LoginView());
                      },
                      child: Container(
                        decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(15.r)),
                        width: MediaQuery.sizeOf(context).width * 0.65,
                        height: MediaQuery.sizeOf(context).height * 0.05,
                        margin: EdgeInsets.symmetric(horizontal: 24.w),
                        padding: EdgeInsets.zero,
                        child: Obx(
                          () =>
                              logoutLoader.value
                                  ? SizedBox(height: 24, width: 24, child: Center(child: Loader(color: Colors.white)))
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Log Out',
                                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(width: 16.w),
                                      Icon(Icons.logout, color: Colors.white, size: 40.h),
                                    ],
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'v${packageInfo.version}',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body:
            dashboardController.loader.value
                ? Center(child: Loader())
                : GetBuilder<DashboardController>(
                  id: UpdateKeys.updateOrderListInDashboard,
                  builder:
                      (controller) =>
                          controller.orderDetailsList.isNotEmpty
                              ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: ListView(
                                        children:
                                            controller.orderDetailsList.where((element) => element.deletedAt == null).map((
                                              order,
                                            ) {
                                              List<OrderModel> listOfOrderModel =
                                                  order.orderDetails['orderDetails'] != null &&
                                                          order.orderDetails['orderDetails'] is List &&
                                                          (order.orderDetails['orderDetails'] as List).isNotEmpty
                                                      ? (order.orderDetails['orderDetails'] as List)
                                                          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
                                                          .toList()
                                                      : [];

                                              int index = controller.orderDetailsList
                                                  .where((element) => element.deletedAt == null)
                                                  .toList()
                                                  .indexOf(order);
                                              bool deleteLoader = false;
                                              bool isEditable = order.remainingUpdate != null && order.remainingUpdate! < 2;
                                              bool isLast =
                                                  controller.orderDetailsList
                                                          .where((element) => element.deletedAt == null)
                                                          .length -
                                                      1 ==
                                                  index;

                                              return GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap: () {
                                                  Get.to(() => OrderDetailsView(orderDetailsModel: order));
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
                                                  margin: EdgeInsets.only(bottom: (isLast ? 110.h : 0) + 24.h),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.orderCardBackground,
                                                    border: Border.all(color: Colors.black.withAlpha((255 * 0.2).toInt())),
                                                    borderRadius: BorderRadius.circular(18.r),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          VerticalTitleValueComponent(
                                                            title: 'ID',
                                                            value: order.id.toString(),
                                                          ),
                                                          if (order.createdAt != null)
                                                            VerticalTitleValueComponent(
                                                              title: 'Created At',
                                                              value: DateFormatter.convertTimeStampIntoString(
                                                                order.createdAt!,
                                                              ),
                                                              isEnd: true,
                                                            ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 12.h),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          VerticalTitleValueComponent(
                                                            title: 'Party Name',
                                                            value: order.partyName,
                                                          ),
                                                          VerticalTitleValueComponent(
                                                            title: 'Delivery Date',
                                                            value: DateFormat('dd-MM-yyyy').format(order.deliveryDate),
                                                            isCenter: true,
                                                          ),
                                                          VerticalTitleValueComponent(
                                                            title: 'Number Of Items',
                                                            value: order.numberOfItems.toString(),
                                                            isEnd: true,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 12.h),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              HorizontalTitleValueComponent(
                                                                title: 'Total Quantity',
                                                                value: order.totalQuantity.toString(),
                                                              ),
                                                              SizedBox(height: 12.h),
                                                              HorizontalTitleValueComponent(
                                                                title: 'Total Price',
                                                                value: order.totalPrice.toString(),
                                                              ),
                                                              SizedBox(height: 12.h),
                                                              HorizontalTitleValueComponent(
                                                                title: 'GST Amount',
                                                                value: order.gstAmount.toString(),
                                                              ),
                                                              SizedBox(height: 12.h),
                                                              HorizontalTitleValueComponent(
                                                                title: 'Grand Total',
                                                                value: order.grandTotal.toString(),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              GestureDetector(
                                                                behavior: HitTestBehavior.translucent,
                                                                onTap: () {
                                                                  if (isEditable) {
                                                                    Get.to(
                                                                      () => AddEditOrderView(
                                                                        arguments: EditOrderNavigationModel(
                                                                          orderID: order.id,
                                                                          partyName: order.partyName,
                                                                          dateOfDelivery: order.deliveryDate,
                                                                          orderList: listOfOrderModel,
                                                                          remainingUpdate: order.remainingUpdate ?? 0,
                                                                          discount: order.discount,
                                                                          packagingType: order.packagingType,
                                                                          onAddEdit: onAddEdit,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons.edit,
                                                                        size: 14,
                                                                        color:
                                                                            isEditable
                                                                                ? Colors.black
                                                                                : Colors.black.withAlpha(
                                                                                  (255 * 0.3).toInt(),
                                                                                ),
                                                                      ),
                                                                      SizedBox(width: 6.w),
                                                                      Text(
                                                                        'Edit',
                                                                        style: TextStyle(
                                                                          color:
                                                                              isEditable
                                                                                  ? Colors.black
                                                                                  : Colors.black.withAlpha(
                                                                                    (255 * 0.3).toInt(),
                                                                                  ),
                                                                          fontWeight: FontWeight.w600,
                                                                          fontSize: 12,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              StatefulBuilder(
                                                                builder:
                                                                    (context, setInnerState) => GestureDetector(
                                                                      behavior: HitTestBehavior.translucent,
                                                                      onTap: () async {
                                                                        if (!deleteLoader) {
                                                                          setInnerState(() {
                                                                            deleteLoader = true;
                                                                          });
                                                                          await onDelete(order.id.toInt());
                                                                          setInnerState(() {
                                                                            deleteLoader = false;
                                                                          });
                                                                        }
                                                                      },
                                                                      child:
                                                                          deleteLoader
                                                                              ? Loader(color: Colors.red)
                                                                              : Padding(
                                                                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.delete,
                                                                                      size: 14,
                                                                                      color: Colors.red,
                                                                                    ),
                                                                                    SizedBox(width: 6.w),
                                                                                    Text(
                                                                                      'Delete',
                                                                                      style: TextStyle(
                                                                                        color: Colors.red,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontSize: 12,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),

                                                      // SizedBox(height: 28.h),
                                                      // Divider(height: 1, thickness: 0.5, color: Colors.black.withAlpha((255 * 0.3).toInt())),
                                                      // SizedBox(height: 28.h),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Center(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Get.to(() => AddEditOrderView(arguments: onAddEdit));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, color: Colors.white),
                                        SizedBox(width: 12),
                                        Text(
                                          'Add Order',
                                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                ),
      ),
    );
  }
}
