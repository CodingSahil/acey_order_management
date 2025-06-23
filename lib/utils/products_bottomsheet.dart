import 'dart:developer';

import 'package:acey_order_management/controller/dashboard_controller.dart';
import 'package:acey_order_management/main.dart';
import 'package:acey_order_management/model/edit_order_navigation.dart';
import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/view/add_edit_order.dart';
import 'package:acey_order_management/view/order_preview_after_add_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'enum.dart';
import 'label_text_fields.dart';

Future<void> productBottomSheet({
  required BuildContext context,
  required DashboardController dashboardController,
  required List<OrderModel> selectedOrder,
  required void Function(List<OrderModel> productList) onSubmit,
}) async {
  TextEditingController searchController = TextEditingController();
  List<OrderModel> searchedOrderList = [];
  List<OrderModel> selectedOrderListLocal = selectedOrder;
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    enableDrag: selectedOrderListLocal.isNotEmpty,
    isDismissible: false,
    scrollControlDisabledMaxHeightRatio: 0.9,
    sheetAnimationStyle: AnimationStyle(curve: Curves.easeIn, duration: Duration(milliseconds: 600), reverseCurve: Curves.easeIn, reverseDuration: Duration(milliseconds: 400)),
    showDragHandle: true,
    builder:
        (context) =>
        StatefulBuilder(
          builder:
              (context, setBottomSheetState) =>
              Column(
                children: [
                  SizedBox(height: 18),
                  Text('Product List', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  SizedBox(height: 18),
                  Divider(color: Colors.black.withAlpha((255 * 0.25).toInt()), thickness: 0.5, height: 1),
                  SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    child: LabeledTextFormField(
                      controller: searchController,
                      hintText: 'Search Product',
                      onChanged: (value) {
                        setBottomSheetState(() {
                          if (dashboardController.productList.isNotEmpty && value.isNotEmpty) {
                            searchedOrderList = selectedOrder.where((element) => element.productModel.aeplPartNumber.toLowerCase().contains(value.toLowerCase())).toList();
                            // dashboardController.productList.where((element) => element.aeplPartNumber.toLowerCase().contains(value.toLowerCase())).toList();
                          }
                        });
                      },
                      onFieldSubmitted: (value) {
                        setBottomSheetState(() {});
                      },
                    ),
                    // AppTextFormFieldsWithLabel(
                    //   textEditingController: searchController,
                    //   hintText: 'Search Product',
                    //   isError: false,
                    //   onChanged: (value) {
                    //     if (dashboardController.productList.isNotEmpty && value.isNotEmpty) {
                    //       searchedProductList = dashboardController.productList.where((element) => element.aeplPartNumber.toLowerCase().contains(value.toLowerCase())).toList();
                    //       controller.update([updateSearchList]);
                    //     }
                    //   },
                    //   onFieldSubmitted: (value) {
                    //     controller.update([updateSearchList]);
                    //   },
                    // ),
                  ),
                  SizedBox(height: 12),
                  if ((searchController.text.isNotEmpty && searchedOrderList.isEmpty) || dashboardController.productList.isEmpty)
                    Expanded(child: Center(child: Text('No Data', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black))))
                  else
                    Expanded(
                      child: ListView(
                        children:
                        (searchController.text.isNotEmpty && searchedOrderList.isNotEmpty
                            ? searchedOrderList
                            : dashboardController.productList.length > 15
                            ? dashboardController.productList.getRange(0, 15).map((e) => OrderModel(productModel: e, quantityController: TextEditingController()),).toList()
                            : dashboardController.productList.map((e) => OrderModel(productModel: e, quantityController: TextEditingController()),).toList())
                            .map(
                              (order) {
                            bool isError = false;
                            int index = (searchController.text.isNotEmpty && searchedOrderList.isNotEmpty
                                ? searchedOrderList
                                : dashboardController.productList.length > 15
                                ? dashboardController.productList.getRange(0, 15).map((e) => OrderModel(productModel: e, quantityController: TextEditingController()),).toList()
                                : dashboardController.productList.map((e) => OrderModel(productModel: e, quantityController: TextEditingController()),).toList()).indexOf(order);
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setBottomSheetState(() {
                                  if (selectedOrderListLocal.any((element) => element.productModel.id == order.productModel.id)) {
                                    selectedOrderListLocal.removeAt(index);
                                  } else {
                                    selectedOrderListLocal.add(order);
                                    log('message');
                                  }
                                });
                              },
                              onLongPress: () async {
                                await showDialog(
                                  context: context,
                                  builder:
                                      (context) =>
                                      AlertDialog(
                                        alignment: Alignment.center,
                                        backgroundColor: Colors.white,
                                        title: Text('Product Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 15,
                                          children: [
                                            HorizontalTitleValueComponent(
                                              title: 'AEPL Part Number',
                                              value: order.productModel.aeplPartNumber,
                                              titleFontWeight: FontWeight.w600,
                                              valueFontWeight: FontWeight.w700,
                                              valueFontSize: 14,
                                              titleFontSize: 14,
                                              isValueExpanded: true,
                                            ),
                                            HorizontalTitleValueComponent(
                                              title: 'Reference Part Number',
                                              value: order.productModel.referencePartNumber,
                                              titleFontWeight: FontWeight.w600,
                                              valueFontWeight: FontWeight.w700,
                                              valueFontSize: 14,
                                              titleFontSize: 14,
                                              isValueExpanded: true,
                                            ),
                                            HorizontalTitleValueComponent(
                                              title: 'Description',
                                              value: order.productModel.description,
                                              titleFontWeight: FontWeight.w600,
                                              valueFontWeight: FontWeight.w700,
                                              valueFontSize: 14,
                                              titleFontSize: 14,
                                              isValueExpanded: true,
                                            ),
                                            HorizontalTitleValueComponent(
                                              title: 'MRP',
                                              value: order.productModel.mrp.toString(),
                                              titleFontWeight: FontWeight.w600,
                                              valueFontWeight: FontWeight.w700,
                                              valueFontSize: 14,
                                              titleFontSize: 14,
                                            ),
                                          ],
                                        ),
                                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.black)))],
                                      ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: selectedOrderListLocal.any((element) => element.productModel.id == order.productModel.id) ? Colors.blueAccent : Colors.black.withAlpha((255 * 0.2).toInt()),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.only(left: 18, right: 18, top: 25),
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text('Series Number :- ', style: TextStyle(fontSize: 12, color: Colors.black.withAlpha((255 * 0.6).toInt()))),
                                              Text(order.productModel.srNumber, style: TextStyle(fontSize: 12, color: Colors.black)),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('AEPL Part Number :- ', style: TextStyle(fontSize: 12, color: Colors.black.withAlpha((255 * 0.6).toInt()))),
                                              Expanded(child: Text(order.productModel.aeplPartNumber, maxLines: 4, style: TextStyle(fontSize: 12, color: Colors.black))),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Reference Part Number :- ', style: TextStyle(fontSize: 12, color: Colors.black.withAlpha((255 * 0.6).toInt()))),
                                              Expanded(child: Text(order.productModel.referencePartNumber, maxLines: 4, style: TextStyle(fontSize: 12, color: Colors.black))),
                                            ],
                                          ),

                                          ///
                                          Container(
                                            decoration: BoxDecoration(border: Border.all(color: Colors.black.withAlpha((255 * 0.5).toInt()), width: 1), borderRadius: BorderRadius.circular(6)),
                                            padding: EdgeInsets.symmetric(horizontal: 12),
                                            width: MediaQuery
                                                .sizeOf(context)
                                                .width * 0.4,
                                            height: 35,
                                            child: StatefulBuilder(
                                              builder:
                                                  (context, setQuantityState) =>
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      GestureDetector(
                                                        behavior: HitTestBehavior.translucent,
                                                        onTap: () {
                                                          if (order.quantityController.text.isNotEmpty && int.parse(order.quantityController.text) > order.productModel.moq) {
                                                            setQuantityState(() {
                                                              order = order.copyWith(quantityController: TextEditingController(text: '${int.parse(order.quantityController.text) - 1}'));
                                                              // order.quantityController.text = (int.parse(order.quantityController.text) - 1).toString();
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
                                                        width: MediaQuery
                                                            .sizeOf(context)
                                                            .width * 0.2,
                                                        height: 35,
                                                        child: TextFormField(
                                                          controller: order.quantityController,
                                                          cursorColor: Colors.black,
                                                          cursorWidth: 1,
                                                          textAlign: TextAlign.center,
                                                          onChanged: (value) {
                                                            setQuantityState(() {
                                                              isError =
                                                                  (order.quantityController.text.isNotEmpty && int.parse(order.quantityController.text) <= order.productModel.moq) ||
                                                                      order.quantityController.text.isEmpty;

                                                              if (order.quantityController.text.isNotEmpty && int.parse(order.quantityController.text) > order.productModel.moq) {
                                                                order = order.copyWith(quantityController: TextEditingController(text: '${int.parse(order.quantityController.text)}'));
                                                                // orderList[index] = orderList[index].copyWith(quantity: int.parse(quantityListController[index].text));
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
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(20),
                                                              borderSide: BorderSide(color: Colors.transparent, width: 2),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(20),
                                                              borderSide: BorderSide(color: Colors.transparent, width: 2),
                                                            ),
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
                                                            order = order.copyWith(quantityController: TextEditingController(text: '${int.parse(order.quantityController.text) + 1}'));

                                                            // quantityListController[index].text = (int.parse(quantityListController[index].text) + 1).toString();
                                                          });
                                                        },
                                                        child: Icon(Icons.add, color: Colors.black, size: 14),
                                                      ),
                                                    ],
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatefulBuilder(
                                      builder:
                                          (context, setCheckBoxState) =>
                                          Checkbox(
                                            activeColor: Colors.blueAccent,
                                            materialTapTargetSize: MaterialTapTargetSize.padded,
                                            value: selectedOrderListLocal.any((element) => element.productModel.aeplPartNumber == order.productModel.aeplPartNumber),
                                            onChanged: (value) {
                                              setCheckBoxState(() {
                                                if (value != null && value == true) {
                                                  selectedOrderListLocal.add(order);
                                                } else if (value != null && value == false) {
                                                  selectedOrderListLocal.remove(order);
                                                } else {
                                                  log('message');
                                                }
                                              });
                                              setBottomSheetState(() {});
                                            },
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                            .toList(),
                      ),
                    ),
                  if (selectedOrderListLocal.isNotEmpty)
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        onSubmit(selectedOrderListLocal);
                        await Future.delayed(Duration(milliseconds: 400));
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: MediaQuery
                            .sizeOf(context)
                            .width,
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Continue', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 15),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: isIOS ? 24 : 4),
                ],
              ),
        ),
  );
}

Future<void> selectDiscountAndPackingType({
  required BuildContext context,
  required EditOrderNavigationModel editOrderNavigationModel,
  num? preselectedDiscount,
  PackingType? preselectedPackingType,
}) async {
  log('editOrderNavigationModel => ${editOrderNavigationModel.partyName}');
  int selectDiscount = preselectedDiscount?.toInt() ?? 57;
  PackingType selectedPackingType = preselectedPackingType ?? PackingType.RegularPacking;

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    scrollControlDisabledMaxHeightRatio: 0.48,
    showDragHandle: true,
    builder:
        (context) =>
        StatefulBuilder(
          builder:
              (context, setState) =>
              Column(
                children: [
                  SizedBox(height: 18),
                  Text('Discount & Packing Type', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  SizedBox(height: 18),
                  Divider(color: Colors.black.withAlpha((255 * 0.25).toInt()), thickness: 0.5, height: 1),
                  SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Discount', style: TextStyle(color: Colors.black.withAlpha((255 * 0.75).toInt()))),
                        SizedBox(height: 4),
                        SizedBox(
                          width: MediaQuery
                              .sizeOf(context)
                              .width,
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile<int>(
                                  value: 57,
                                  activeColor: Colors.blueAccent,
                                  title: Text('57', style: TextStyle(color: Colors.black)),
                                  groupValue: selectDiscount,
                                  contentPadding: EdgeInsets.zero,
                                  selected: selectDiscount == 57,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  materialTapTargetSize: MaterialTapTargetSize.padded,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (value) {
                                    if (value != null && selectDiscount != 57) {
                                      setState(() {
                                        selectDiscount = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  value: 60,
                                  activeColor: Colors.blueAccent,
                                  title: Text('60', style: TextStyle(color: Colors.black)),
                                  groupValue: selectDiscount,
                                  contentPadding: EdgeInsets.zero,
                                  selected: selectDiscount == 60,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  materialTapTargetSize: MaterialTapTargetSize.padded,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (value) {
                                    if (value != null && selectDiscount != 60) {
                                      setState(() {
                                        selectDiscount = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  value: 62,
                                  activeColor: Colors.blueAccent,
                                  title: Text('62', style: TextStyle(color: Colors.black)),
                                  groupValue: selectDiscount,
                                  contentPadding: EdgeInsets.zero,
                                  selected: selectDiscount == 62,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  materialTapTargetSize: MaterialTapTargetSize.padded,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (value) {
                                    if (value != null && selectDiscount != 62) {
                                      setState(() {
                                        selectDiscount = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18),
                        Divider(color: Colors.black.withAlpha((255 * 0.25).toInt()), thickness: 0.5, height: 1),

                        SizedBox(height: 18),

                        Text('Select Packaging Type', style: TextStyle(color: Colors.black.withAlpha((255 * 0.75).toInt()))),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withAlpha((255 * 0.25).toInt()), width: 0.5)),
                          child: DropdownButton<PackingType>(
                            value: selectedPackingType,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            underline: SizedBox.shrink(),
                            icon: Icon(Icons.keyboard_arrow_down_sharp, size: 20, color: Colors.black),
                            items:
                            PackingType.values.map((PackingType type) {
                              return DropdownMenuItem<PackingType>(value: type, child: Text(packingTypeToString(type), style: TextStyle(color: Colors.black, fontSize: 14)));
                            }).toList(),

                            onChanged: (PackingType? newValue) {
                              if (newValue != null && selectedPackingType != newValue) {
                                setState(() {
                                  selectedPackingType = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 18),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Get.back();
                            Get.to(
                                  () =>
                                  OrderPreviewAfterAddView(
                                    arguments:
                                    editOrderNavigationModel.orderID != null
                                        ? editOrderNavigationModel
                                        : EditOrderNavigationModel(
                                      partyName: editOrderNavigationModel.partyName,
                                      dateOfDelivery: editOrderNavigationModel.dateOfDelivery,
                                      orderList: editOrderNavigationModel.orderList,
                                      packagingType: selectedPackingType,
                                      discount: selectDiscount,
                                      onAddEdit: editOrderNavigationModel.onAddEdit,
                                    ),
                                  ),
                            );
                          },
                          child: Container(
                            width: MediaQuery
                                .sizeOf(context)
                                .width,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(18)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Continue', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 15),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
        ),
  );
}

String packingTypeToString(PackingType type) {
  switch (type) {
    case PackingType.RegularPacking:
      return 'Regular Packing';
    case PackingType.SinglePackingWithPlainBag:
      return 'Single Packing in Plain Bag';
    case PackingType.NoPrintingNoMRP:
      return 'Part No Printing, without MRP Sticker';
    case PackingType.NoPrintingWithMRP:
      return 'Part No Printing, With MRP Sticker';
    case PackingType.BundlePacking:
      return 'Bundle Packing';
  }
}
