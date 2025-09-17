import 'dart:convert';
import 'dart:developer';

import 'package:acey_order_management/controller/dashboard_controller.dart';
import 'package:acey_order_management/model/edit_order_navigation.dart';
import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/utils/app_bar.dart';
import 'package:acey_order_management/utils/app_colors.dart';
import 'package:acey_order_management/utils/custom_snack_bar.dart';
import 'package:acey_order_management/utils/date_functions.dart';
import 'package:acey_order_management/utils/enum.dart';
import 'package:acey_order_management/utils/label_text_fields.dart';
import 'package:acey_order_management/utils/loader.dart';
import 'package:acey_order_management/utils/bottomsheet/products_bottomsheet.dart';
import 'package:acey_order_management/utils/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddEditOrderView extends StatefulWidget {
  const AddEditOrderView({super.key, required this.arguments});

  final dynamic arguments;

  @override
  State<AddEditOrderView> createState() => _AddEditOrderViewState();
}

class _AddEditOrderViewState extends State<AddEditOrderView> {
  late final DashboardController dashboardController;

  late TextEditingController partyNameController = TextEditingController();
  late TextEditingController dateOfDeliveryController = TextEditingController();
  DateTime? selectedDate;
  List<OrderModel> orderList = [];
  bool isError = false;
  EditOrderNavigationModel? editOrderNavigationModel;

  @override
  void initState() {
    dashboardController = Get.find<DashboardController>();
    selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await dashboardController.getProductList();
      // await Future.delayed(Duration(milliseconds: 400));

      if (widget.arguments != null && widget.arguments is EditOrderNavigationModel) {
        editOrderNavigationModel = widget.arguments as EditOrderNavigationModel;
      }

      if (editOrderNavigationModel != null) {
        partyNameController.text = editOrderNavigationModel!.partyName;
        dateOfDeliveryController.text = DateFormat('dd-MM-yyyy').format(editOrderNavigationModel!.dateOfDelivery);
        String tempFormattedDate = DateFormat('yyyy-MM-dd').format(editOrderNavigationModel!.dateOfDelivery);
        selectedDate = DateFormatter.convertStringIntoDateTime(tempFormattedDate);
        orderList =
            editOrderNavigationModel!.orderList
                .where(
                  (element) =>
                      dashboardController.productList.any((elementInner) => element.productModel.id == elementInner.id),
                )
                .toList();
      } else {
        await productBottomSheet(
          context: context,
          dashboardController: dashboardController,
          selectedOrder: orderList,
          onSubmit: (orderListInner) {
            setState(() {
              orderList = orderListInner;
            });
          },
        );
      }

      dashboardController.update([UpdateKeys.updateAddEditOrder]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      id: UpdateKeys.updateAddEditOrder,
      builder:
          (controller) => Scaffold(
            backgroundColor: Colors.white,
            appBar: commonAppBar(
              title: editOrderNavigationModel != null ? 'Edit Order' : 'Add Order',
              isDone: orderList.isNotEmpty,
              onDone: () async {
                if (partyNameController.text.isEmpty) {
                  setState(() {
                    isError = true;
                  });
                  return;
                }
                if (selectedDate == null) {
                  setState(() {
                    isError = true;
                  });
                  return;
                }
                if (orderList.isNotEmpty &&
                    orderList.any(
                      (element) =>
                          element.quantityController.text.isEmpty ||
                          element.quantityController.text == '0' ||
                          (int.tryParse(element.quantityController.text) ?? 0) == 0,
                    )) {
                  errorSnackBar(context: context, title: "Some Product's might missing Quantity");
                  return;
                }
                if (orderList.isNotEmpty) {
                  await selectDiscountAndPackingType(
                    context: context,
                    editOrderNavigationModel: EditOrderNavigationModel(
                      orderID:
                          editOrderNavigationModel != null && editOrderNavigationModel!.orderID != null
                              ? editOrderNavigationModel!.orderID!
                              : null,
                      partyName: partyNameController.text,
                      dateOfDelivery: selectedDate != null ? selectedDate! : DateTime.now(),
                      orderList: orderList,
                      packagingType: editOrderNavigationModel?.packagingType ?? PackingType.RegularPacking,
                      discount: editOrderNavigationModel?.discount ?? 0,
                      onAddEdit:
                          editOrderNavigationModel != null
                              ? editOrderNavigationModel!.onAddEdit
                              : widget.arguments != null && widget.arguments is! EditOrderNavigationModel
                              ? widget.arguments
                              : () {},
                    ),
                    preselectedPackingType: editOrderNavigationModel?.packagingType,
                    preselectedDiscount: editOrderNavigationModel?.discount,
                  );
                }
              },
            ),
            floatingActionButton:
                orderList.isNotEmpty
                    ? FloatingActionButton.extended(
                      backgroundColor: Colors.blueAccent,
                      onPressed: () async {
                        await productBottomSheet(
                          context: context,
                          dashboardController: dashboardController,
                          selectedOrder: orderList,
                          onSubmit: (orderListInner) {
                            List<OrderModel> orderListTemp = [];
                            for (var orderInner in orderListInner) {
                              if (orderList.any((element) => element == orderInner)) {
                                orderListTemp.add(
                                  orderList.firstWhere((element) => element.productModel.id == orderInner.productModel.id),
                                );
                              } else {
                                orderListTemp.add(orderInner);
                              }
                            }
                            log(
                              orderListTemp.map((e) => jsonEncode(e.toJson())).toList().toString(),
                              name: 'orderListTemp => ',
                            );

                            orderList = orderListTemp;
                            setState(() {});
                          },
                        );
                      },
                      icon: Icon(Icons.add, color: Colors.white, size: 22),
                      label: Text(
                        'Add Product',
                        style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    )
                    : null,
            body: Obx(
              () =>
                  dashboardController.loader.value
                      ? Center(child: Loader())
                      : Padding(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text(
                                      'Enter Party Name',
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  LabeledTextFormField(
                                    controller: partyNameController,
                                    hintText: 'Enter Party Name',
                                    isError: isError && partyNameController.text.isEmpty,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                selectedDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now().subtract(Duration(days: 5)),
                                  lastDate: DateTime(DateTime.now().year + 5),
                                  initialDate: selectedDate,
                                  currentDate: selectedDate,
                                );

                                if (selectedDate != null) {
                                  setState(() {
                                    isError = false;
                                    dateOfDeliveryController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
                                  });
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 16, bottom: 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Text(
                                        'Select Order Date',
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          width: 0.5,
                                          color: isError ? Colors.red : Colors.black.withAlpha((255 * 0.5).toInt()),
                                        ),
                                      ),
                                      child: LabeledTextFormField(
                                        controller: dateOfDeliveryController,
                                        hintText: 'Order Date',
                                        enable: false,
                                        suffix: Icon(
                                          Icons.calendar_month_rounded,
                                          size: 20,
                                          color: Colors.black.withAlpha((255 * 0.5).toInt()),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Divider(height: 1, color: Colors.black.withAlpha((255 * 0.5).toInt()), thickness: 0.5),
                            SizedBox(height: 16),
                            orderList.isNotEmpty
                                ? Expanded(
                                  child: ListView(
                                    padding: EdgeInsets.only(top: 8, bottom: MediaQuery.sizeOf(context).height * 0.1),
                                    children:
                                        orderList.map((order) {
                                          int index = orderList.indexOf(order);
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.orderCardBackground,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            margin: EdgeInsets.only(bottom: 8),
                                            width: MediaQuery.sizeOf(context).width,
                                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        HorizontalTitleValueComponent(
                                                          title: 'AEPL Part Number',
                                                          value: order.productModel.aeplPartNumber,
                                                          valueFontSize: 14,
                                                          valueFontWeight: FontWeight.w600,
                                                        ),
                                                        SizedBox(height: 2),
                                                      ],
                                                    ),
                                                    GestureDetector(
                                                      behavior: HitTestBehavior.translucent,
                                                      onTap: () {
                                                        setState(() {
                                                          orderList.removeAt(index);
                                                        });
                                                      },
                                                      child: Icon(Icons.delete, color: Colors.red, size: 22),
                                                    ),
                                                  ],
                                                ),
                                                HorizontalTitleValueComponent(
                                                  title: 'Reference Number',
                                                  isValueExpanded: true,
                                                  value: order.productModel.referencePartNumber,
                                                  valueFontSize: 14,
                                                  valueFontWeight: FontWeight.w600,
                                                ),
                                                SizedBox(height: 2),

                                                HorizontalTitleValueComponent(
                                                  title: 'Description',
                                                  isValueExpanded: true,
                                                  value: order.productModel.description,
                                                  valueFontSize: 14,
                                                  valueFontWeight: FontWeight.w600,
                                                ),
                                                SizedBox(height: 12),

                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.black.withAlpha((255 * 0.5).toInt()),
                                                      width: 1,
                                                    ),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                                  height: 35,
                                                  child: StatefulBuilder(
                                                    builder:
                                                        (context, setQuantityState) => Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            GestureDetector(
                                                              behavior: HitTestBehavior.translucent,
                                                              onTap: () {
                                                                if (order.quantityController.text.isNotEmpty &&
                                                                    int.parse(order.quantityController.text) >
                                                                        order.productModel.moq) {
                                                                  setQuantityState(() {
                                                                    order = order.copyWith(
                                                                      quantityController: TextEditingController(
                                                                        text:
                                                                            '${int.parse(order.quantityController.text) - 1}',
                                                                      ),
                                                                    );
                                                                    orderList[index] = order;
                                                                    // orderList = orderList.map((e) {
                                                                    //   if(e.productModel.id == order.productModel.id) {
                                                                    //     return order;
                                                                    //   } else {
                                                                    //     return e;
                                                                    //   }
                                                                    // }).toList();
                                                                    // orderList[index] = orderList[index].copyWith(quantity: int.parse(quantityListController[index].text));
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                alignment: Alignment.center,
                                                                padding: EdgeInsets.zero,
                                                                margin: EdgeInsets.symmetric(vertical: 5),
                                                                height: 2,
                                                                width: 8,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.black.withAlpha((255 * 0.5).toInt()),
                                                                  borderRadius: BorderRadius.circular(6),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.sizeOf(context).width * 0.2,
                                                              height: 35,
                                                              child: TextFormField(
                                                                controller: order.quantityController,
                                                                cursorColor: Colors.black,
                                                                cursorWidth: 1,
                                                                textAlign: TextAlign.center,
                                                                onChanged: (value) {
                                                                  setQuantityState(() {
                                                                    isError =
                                                                        (order.quantityController.text.isNotEmpty &&
                                                                            int.parse(order.quantityController.text) <=
                                                                                order.productModel.moq) ||
                                                                        order.quantityController.text.isEmpty;

                                                                    if (order.quantityController.text.isNotEmpty &&
                                                                        int.parse(order.quantityController.text) >
                                                                            order.productModel.moq) {
                                                                      order = order.copyWith(
                                                                        quantityController: TextEditingController(
                                                                          text: order.quantityController.text,
                                                                        ),
                                                                      );
                                                                      orderList[index] = order;
                                                                      // orderList = orderList.map((e) {
                                                                      //   if(e.productModel.id == order.productModel.id) {
                                                                      //     return order;
                                                                      //   } else {
                                                                      //     return e;
                                                                      //   }
                                                                      // }).toList();
                                                                      // orderList[index] = orderList[index].copyWith(quantity: int.parse(quantityListController[index].text));
                                                                    }
                                                                  });
                                                                },
                                                                textAlignVertical: TextAlignVertical.center,
                                                                textInputAction: TextInputAction.done,
                                                                style: GoogleFonts.rubik(
                                                                  fontWeight: FontWeight.normal,
                                                                  fontSize: 15,
                                                                  color: Colors.black,
                                                                ),
                                                                inputFormatters: <TextInputFormatter>[
                                                                  LengthLimitingTextInputFormatter(8),
                                                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                                ],
                                                                keyboardType: TextInputType.number,
                                                                decoration: InputDecoration(
                                                                  constraints: BoxConstraints(maxWidth: 60, maxHeight: 30),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                    vertical: 5,
                                                                    horizontal: 10,
                                                                  ),
                                                                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.transparent,
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(
                                                                      color: Colors.transparent,
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  disabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide.none,
                                                                  ),
                                                                  errorBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(color: Colors.red, width: 1),
                                                                  ),
                                                                  focusedErrorBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(color: Colors.red, width: 1),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              behavior: HitTestBehavior.translucent,
                                                              onTap: () {
                                                                setQuantityState(() {
                                                                  order = order.copyWith(
                                                                    quantityController: TextEditingController(
                                                                      text:
                                                                          '${int.parse(order.quantityController.text) + 1}',
                                                                    ),
                                                                  );
                                                                  orderList[index] = order;
                                                                  // orderList = orderList.map((e) {
                                                                  //   if(e.productModel.id == order.productModel.id) {
                                                                  //     return order;
                                                                  //   } else {
                                                                  //     return e;
                                                                  //   }
                                                                  // }).toList();
                                                                  // order.quantityController.text = (int.parse(order.quantityController.text) + 1).toString();
                                                                  // orderList[index] = orderList[index].copyWith(quantity: int.parse(quantityListController[index].text));
                                                                });
                                                              },
                                                              child: Icon(Icons.add, color: Colors.black, size: 14),
                                                            ),
                                                          ],
                                                        ),
                                                  ),
                                                ),
                                                // if (orderList[index].quantity != null && orderList[index].quantity! > 0) ...[
                                                //   HorizontalTitleValueComponent(title: 'Qty.', value: orderList[index].quantity!.toString(), valueFontSize: 14, valueFontWeight: FontWeight.w600),
                                                //   SizedBox(height: 2),
                                                // ],
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                )
                                : Center(
                                  child: Text(
                                    'No Data',
                                    style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600),
                                  ),
                                ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
            ),
          ),
    );
  }
}

class HorizontalTitleValueComponent extends StatelessWidget {
  const HorizontalTitleValueComponent({
    super.key,
    this.isValueExpanded = false,
    required this.title,
    required this.value,
    this.titleFontSize,
    this.valueFontSize,
    this.titleFontWeight,
    this.valueFontWeight,
  });

  final String title;
  final String value;
  final double? titleFontSize;
  final double? valueFontSize;
  final FontWeight? titleFontWeight;
  final FontWeight? valueFontWeight;
  final bool isValueExpanded;

  @override
  Widget build(BuildContext context) {
    Widget valueWidget = Text(
      value.toString(),
      style: TextStyle(fontSize: valueFontSize ?? 14, color: Colors.black, fontWeight: valueFontWeight),
      maxLines: 5,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title : ',
          style: TextStyle(
            fontSize: titleFontSize ?? 12,
            color: Colors.black.withAlpha((255 * 0.6).toInt()),
            fontWeight: titleFontWeight,
          ),
        ),
        isValueExpanded ? Expanded(child: valueWidget) : valueWidget,
      ],
    );
  }
}

class VerticalTitleValueComponent extends StatelessWidget {
  const VerticalTitleValueComponent({
    super.key,
    required this.title,
    required this.value,
    this.isCenter = false,
    this.isEnd = false,
  });

  final String title;
  final String value;
  final bool isCenter;
  final bool isEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          isEnd
              ? CrossAxisAlignment.end
              : isCenter
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.black.withAlpha((255 * 0.6).toInt()))),
        Text(value.toString(), style: TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }
}
