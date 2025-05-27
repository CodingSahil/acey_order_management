import 'dart:developer';

import 'package:acey_order_management/controller/dashboard_controller.dart';
import 'package:acey_order_management/main.dart';
import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/model/product_model.dart';
import 'package:acey_order_management/view/add_edit_order.dart';
import 'package:acey_order_management/view/order_preview_after_add_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'enum.dart';
import 'label_text_fields.dart';

Future<void> productBottomSheet({
  required BuildContext context,
  required DashboardController dashboardController,
  required List<ProductModel> selectedProduct,
  required void Function(List<ProductModel> productList) onSubmit,
}) async {
  TextEditingController searchController = TextEditingController();
  List<ProductModel> searchedProductList = [];
  List<ProductModel> selectedProductListLocal = selectedProduct;
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    enableDrag: selectedProductListLocal.isNotEmpty,
    isDismissible: selectedProductListLocal.isNotEmpty,
    scrollControlDisabledMaxHeightRatio: 0.9,
    sheetAnimationStyle: AnimationStyle(curve: Curves.easeIn, duration: Duration(milliseconds: 600), reverseCurve: Curves.easeIn, reverseDuration: Duration(milliseconds: 400)),
    showDragHandle: true,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setBottomSheetState) => Column(
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
                            searchedProductList = dashboardController.productList.where((element) => element.aeplPartNumber.toLowerCase().contains(value.toLowerCase())).toList();
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
                  if ((searchController.text.isNotEmpty && searchedProductList.isEmpty) || dashboardController.productList.isEmpty)
                    Expanded(child: Center(child: Text('No Data', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black))))
                  else
                    Expanded(
                      child: ListView(
                        children:
                            (searchController.text.isNotEmpty && searchedProductList.isNotEmpty
                                    ? searchedProductList
                                    : dashboardController.productList.length > 15
                                    ? dashboardController.productList.getRange(0, 15)
                                    : dashboardController.productList)
                                .map(
                                  (product) => GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setBottomSheetState(() {
                                        if (selectedProductListLocal.any((element) => element.id == product.id)) {
                                          selectedProductListLocal.remove(product);
                                        } else {
                                          selectedProductListLocal.add(product);
                                          log('message');
                                        }
                                      });
                                    },
                                    onLongPress: () async {
                                      await showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              alignment: Alignment.center,
                                              backgroundColor: Colors.white,
                                              title: Text('Product Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                spacing: 15,
                                                children: [
                                                  HorizontalTitleValueComponent(
                                                    title: 'AEPL Part Number',
                                                    value: product.aeplPartNumber,
                                                    titleFontWeight: FontWeight.w600,
                                                    valueFontWeight: FontWeight.w700,
                                                    valueFontSize: 14,
                                                    titleFontSize: 14,
                                                    isValueExpanded: true,
                                                  ),
                                                  HorizontalTitleValueComponent(
                                                    title: 'Reference Part Number',
                                                    value: product.referencePartNumber,
                                                    titleFontWeight: FontWeight.w600,
                                                    valueFontWeight: FontWeight.w700,
                                                    valueFontSize: 14,
                                                    titleFontSize: 14,
                                                    isValueExpanded: true,
                                                  ),
                                                  HorizontalTitleValueComponent(
                                                    title: 'Description',
                                                    value: product.description,
                                                    titleFontWeight: FontWeight.w600,
                                                    valueFontWeight: FontWeight.w700,
                                                    valueFontSize: 14,
                                                    titleFontSize: 14,
                                                    isValueExpanded: true,
                                                  ),
                                                  HorizontalTitleValueComponent(
                                                    title: 'MRP',
                                                    value: product.mrp.toString(),
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
                                          color: selectedProductListLocal.any((element) => element.id == product.id) ? Colors.blueAccent : Colors.black.withAlpha((255 * 0.2).toInt()),
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
                                                    Text(product.srNumber, style: TextStyle(fontSize: 12, color: Colors.black)),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('AEPL Part Number :- ', style: TextStyle(fontSize: 12, color: Colors.black.withAlpha((255 * 0.6).toInt()))),
                                                    Expanded(child: Text(product.aeplPartNumber, maxLines: 4, style: TextStyle(fontSize: 12, color: Colors.black))),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Reference Part Number :- ', style: TextStyle(fontSize: 12, color: Colors.black.withAlpha((255 * 0.6).toInt()))),
                                                    Expanded(child: Text(product.referencePartNumber, maxLines: 4, style: TextStyle(fontSize: 12, color: Colors.black))),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          StatefulBuilder(
                                            builder:
                                                (context, setCheckBoxState) => Checkbox(
                                                  activeColor: Colors.blueAccent,
                                                  materialTapTargetSize: MaterialTapTargetSize.padded,
                                                  value: selectedProductListLocal.any((element) => element.aeplPartNumber == product.aeplPartNumber),
                                                  onChanged: (value) {
                                                    setCheckBoxState(() {
                                                      if (value != null && value == true) {
                                                        selectedProductListLocal.add(product);
                                                      } else if (value != null && value == false) {
                                                        selectedProductListLocal.remove(product);
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
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  if (selectedProductListLocal.isNotEmpty)
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        onSubmit(selectedProductListLocal);
                        await Future.delayed(Duration(milliseconds: 400));
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
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

Future<void> selectDiscountAndPackingType({required BuildContext context, required List<OrderModel> orderList, required String partyName, required String dateOfDelivery}) async {
  int selectDiscount = 57;
  PackingType selectedPackingType = PackingType.RegularPacking;
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    scrollControlDisabledMaxHeightRatio: 0.48,
    showDragHandle: true,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setState) => Column(
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
                          width: MediaQuery.sizeOf(context).width,
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
                              () => OrderPreviewAfterAddView(
                                discount: selectDiscount,
                                selectedPackingType: selectedPackingType,
                                orderList: orderList,
                                partyName: partyName,
                                dateOfDelivery: dateOfDelivery,
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
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
