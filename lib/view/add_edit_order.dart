import 'dart:developer';

import 'package:acey_order_management/controller/dashboard_controller.dart';
import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/model/product_model.dart';
import 'package:acey_order_management/utils/app_bar.dart';
import 'package:acey_order_management/utils/app_colors.dart';
import 'package:acey_order_management/utils/custom_snack_bar.dart';
import 'package:acey_order_management/utils/enum.dart';
import 'package:acey_order_management/utils/label_text_fields.dart';
import 'package:acey_order_management/utils/loader.dart';
import 'package:acey_order_management/utils/products_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddEditOrderView extends StatefulWidget {
  const AddEditOrderView({super.key, required this.addEditEnum});

  final AddEditEnum addEditEnum;

  @override
  State<AddEditOrderView> createState() => _AddEditOrderViewState();
}

class _AddEditOrderViewState extends State<AddEditOrderView> {
  late final DashboardController dashboardController;

  late TextEditingController partyNameController = TextEditingController();
  late TextEditingController dateOfDeliveryController = TextEditingController();
  DateTime? selectedDate;
  List<OrderModel> orderList = [];
  List<ProductModel> productList = [];
  bool isError = false;
  List<TextEditingController> quantityListController = [];

  @override
  void initState() {
    dashboardController = Get.find<DashboardController>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await dashboardController.getProductList();
      await Future.delayed(Duration(milliseconds: 400));
      await productBottomSheet(
        context: context,
        dashboardController: dashboardController,
        selectedProduct: productList,
        onSubmit: (productListInner) {
          productList = productListInner;
          orderList = productList.map((product) => OrderModel(productModel: product)).toList();
          quantityListController = List.generate(orderList.length, (index) => TextEditingController(text: orderList[index].quantity?.toString() ?? '10'));
          orderList = orderList.map((e) => OrderModel(productModel: e.productModel, quantity: e.quantity != null ? e.quantity! : 10)).toList();
          setState(() {});
        },
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(
        title: widget.addEditEnum == AddEditEnum.Edit ? 'Edit Order' : 'Add Order',
        isDone: productList.isNotEmpty && orderList.isNotEmpty,
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
          if (orderList.isNotEmpty && orderList.any((element) => element.quantity == null || element.quantity == 0)) {
            log('orderList => ${orderList.map((e) => e.quantity)}');
            errorSnackBar(context: context, title: "Some Product's might missing Quantity");
            return;
          }
          if (productList.isNotEmpty && orderList.isNotEmpty) {
            await selectDiscountAndPackingType(context: context, orderList: orderList, partyName: partyNameController.text, dateOfDelivery: dateOfDeliveryController.text);
          }
        },
      ),
      floatingActionButton:
          productList.isNotEmpty
              ? FloatingActionButton.extended(
                backgroundColor: Colors.blueAccent,
                onPressed: () async {
                  await productBottomSheet(
                    context: context,
                    dashboardController: dashboardController,
                    selectedProduct: productList,
                    onSubmit: (productListInner) {
                      List<OrderModel> orderListTemp = [];
                      List<ProductModel> productListTemp =
                          productListInner.map((e) {
                            if (productList.any((element) => element.id == e.id) && orderList.any((element) => element.productModel.id == e.id)) {
                              orderListTemp.add(orderList.firstWhere((element) => element.productModel.id == e.id));
                              return productList.singleWhere((element) => e.id == element.id);
                            } else {
                              orderListTemp.add(OrderModel(productModel: e));
                              return e;
                            }
                          }).toList();

                      productList = productListTemp;
                      orderList = orderListTemp;
                      quantityListController = List.generate(orderList.length, (index) => TextEditingController(text: orderList[index].quantity?.toString() ?? '10'));
                      orderList = orderList.map((e) => OrderModel(productModel: e.productModel, quantity: e.quantity != null ? e.quantity! : 10)).toList();
                      setState(() {});
                    },
                  );
                },
                icon: Icon(Icons.add, color: Colors.white, size: 22),
                label: Text('Add Product', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600)),
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
                            Padding(padding: EdgeInsets.only(left: 4), child: Text('Enter Party Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14))),
                            SizedBox(height: 8),
                            LabeledTextFormField(controller: partyNameController, hintText: 'Enter Party Name', isError: isError && partyNameController.text.isEmpty),
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
                              Padding(padding: EdgeInsets.only(left: 4), child: Text('Select Order Date', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14))),
                              SizedBox(height: 8),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(width: 0.5, color: isError ? Colors.red : Colors.black.withAlpha((255 * 0.5).toInt())),
                                ),
                                child: LabeledTextFormField(
                                  controller: dateOfDeliveryController,
                                  hintText: 'Order Date',
                                  enable: false,
                                  suffix: Icon(Icons.calendar_month_rounded, size: 20, color: Colors.black.withAlpha((255 * 0.5).toInt())),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Divider(height: 1, color: Colors.black.withAlpha((255 * 0.5).toInt()), thickness: 0.5),
                      SizedBox(height: 16),
                      productList.isNotEmpty
                          ? Expanded(
                            child: ListView(
                              padding: EdgeInsets.only(top: 8, bottom: MediaQuery.sizeOf(context).height * 0.1),
                              children:
                                  productList.map((product) {
                                    int index = productList.indexOf(product);
                                    return Container(
                                      decoration: BoxDecoration(color: AppColors.orderCardBackground, borderRadius: BorderRadius.circular(15)),
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
                                                  HorizontalTitleValueComponent(title: 'AEPL Part Number', value: product.aeplPartNumber, valueFontSize: 14, valueFontWeight: FontWeight.w600),
                                                  SizedBox(height: 2),
                                                ],
                                              ),
                                              GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap: () {
                                                  setState(() {
                                                    productList.removeAt(index);
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
                                            value: product.referencePartNumber,
                                            valueFontSize: 14,
                                            valueFontWeight: FontWeight.w600,
                                          ),
                                          SizedBox(height: 2),

                                          HorizontalTitleValueComponent(title: 'Description', isValueExpanded: true, value: product.description, valueFontSize: 14, valueFontWeight: FontWeight.w600),
                                          SizedBox(height: 12),

                                          Container(
                                            decoration: BoxDecoration(border: Border.all(color: Colors.black.withAlpha((255 * 0.5).toInt()), width: 1), borderRadius: BorderRadius.circular(6)),
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
                                                          if (quantityListController[index].text.isNotEmpty && int.parse(quantityListController[index].text) > product.moq) {
                                                            setQuantityState(() {
                                                              quantityListController[index].text = (int.parse(quantityListController[index].text) - 1).toString();
                                                              orderList[index] = orderList[index].copyWith(quantity: int.parse(quantityListController[index].text));
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          alignment: Alignment.center,
                                                          padding: EdgeInsets.zero,
                                                          margin: EdgeInsets.symmetric(vertical: 5),
                                                          height: 2,
                                                          width: 8,
                                                          decoration: BoxDecoration(color: Colors.black.withAlpha((255 * 0.5).toInt()), borderRadius: BorderRadius.circular(6)),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.sizeOf(context).width * 0.2,
                                                        height: 35,
                                                        child: TextFormField(
                                                          controller: quantityListController[index],
                                                          cursorColor: Colors.black,
                                                          cursorWidth: 1,
                                                          textAlign: TextAlign.center,
                                                          onChanged: (value) {
                                                            setQuantityState(() {
                                                              isError =
                                                                  (quantityListController[index].text.isNotEmpty && int.parse(quantityListController[index].text) <= product.moq) ||
                                                                  quantityListController[index].text.isEmpty;

                                                              if (quantityListController[index].text.isNotEmpty && int.parse(quantityListController[index].text) > product.moq) {
                                                                orderList[index] = orderList[index].copyWith(quantity: int.parse(quantityListController[index].text));
                                                              }
                                                            });
                                                          },
                                                          textAlignVertical: TextAlignVertical.center,
                                                          textInputAction: TextInputAction.done,
                                                          style: GoogleFonts.rubik(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black),
                                                          inputFormatters: <TextInputFormatter>[LengthLimitingTextInputFormatter(8), FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                                          keyboardType: TextInputType.number,
                                                          decoration: InputDecoration(
                                                            constraints: BoxConstraints(maxWidth: 60, maxHeight: 30),
                                                            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.transparent, width: 2)),
                                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.transparent, width: 2)),
                                                            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.red, width: 1)),
                                                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.red, width: 1)),
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        behavior: HitTestBehavior.translucent,
                                                        onTap: () {
                                                          setQuantityState(() {
                                                            quantityListController[index].text = (int.parse(quantityListController[index].text) + 1).toString();
                                                            orderList[index] = orderList[index].copyWith(quantity: int.parse(quantityListController[index].text));
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
                          : Center(child: Text('No Data', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600))),
                      SizedBox(height: 30),
                    ],
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
    Widget valueWidget = Text(value.toString(), style: TextStyle(fontSize: valueFontSize ?? 12, color: Colors.black, fontWeight: valueFontWeight), maxLines: 5);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title : ', style: TextStyle(fontSize: titleFontSize ?? 12, color: Colors.black.withAlpha((255 * 0.6).toInt()), fontWeight: titleFontWeight)),
        isValueExpanded ? Expanded(child: valueWidget) : valueWidget,
      ],
    );
  }
}

class VerticalTitleValueComponent extends StatelessWidget {
  const VerticalTitleValueComponent({super.key, required this.title, required this.value, this.isCenter = false, this.isEnd = false});

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
      children: [Text('$title : ', style: TextStyle(fontSize: 12, color: Colors.black.withAlpha((255 * 0.6).toInt()))), Text(value.toString(), style: TextStyle(fontSize: 12, color: Colors.black))],
    );
  }
}
