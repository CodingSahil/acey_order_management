import 'dart:developer';

import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/utils/app_bar.dart';
import 'package:acey_order_management/utils/enum.dart';
import 'package:acey_order_management/utils/products_bottomsheet.dart';
import 'package:acey_order_management/view/add_edit_order.dart';
import 'package:flutter/material.dart';

class OrderPreviewAfterAddView extends StatefulWidget {
  const OrderPreviewAfterAddView({super.key, required this.orderList, required this.discount, required this.selectedPackingType});

  final List<OrderModel> orderList;
  final int discount;
  final PackingType selectedPackingType;

  @override
  State<OrderPreviewAfterAddView> createState() => _OrderPreviewAfterAddViewState();
}

class _OrderPreviewAfterAddViewState extends State<OrderPreviewAfterAddView> {
  int totalQuantity = 0;
  double totalPrice = 0;
  double gstAmount = 0;
  double priceAfterGST = 0;

  @override
  void initState() {
    if (widget.orderList.isNotEmpty) {
      List<int> listOfQuantity = widget.orderList.map((e) => e.quantity ?? 0).toList();
      totalQuantity = listOfQuantity.reduce((value, element) => value + element);

      /// total price
      totalPrice = widget.orderList
          .map((e) {
            double price = e.productModel.mrp - ((e.productModel.mrp * widget.discount) / 100);
            return price * (e.quantity ?? 0);
          })
          .toList()
          .reduce((value, element) => value + element);

      gstAmount = ((totalPrice * 28) / 100);

      priceAfterGST = totalPrice + gstAmount;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(title: 'Order Preview'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () {},
        label: Text('Submit Order', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        icon: Icon(Icons.done, color: Colors.white),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HorizontalTitleValueComponent(
                  title: 'Discount',
                  value: '${widget.discount}%',
                  titleFontSize: 15,
                  valueFontSize: 18,
                  valueFontWeight: FontWeight.w800,
                  titleFontWeight: FontWeight.w600,
                ),
                SizedBox(height: 6),
                HorizontalTitleValueComponent(
                  title: 'Packaging Type',
                  value: packingTypeToString(widget.selectedPackingType),
                  isValueExpanded: true,
                  titleFontSize: 12,
                  valueFontSize: 14,
                  valueFontWeight: FontWeight.w700,
                  titleFontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.75, minWidth: MediaQuery.sizeOf(context).width),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Reference No.', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('MRP', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('Total Price', style: TextStyle(fontWeight: FontWeight.w800))),
                    ],
                    rows:
                        widget.orderList.map((order) {
                          double price = order.productModel.mrp - ((order.productModel.mrp * widget.discount) / 100);
                          double totalPrice = price * (order.quantity ?? 0);
                          log('price => $price & totalPrice => $totalPrice');
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(Text(order.productModel.aeplPartNumber)),
                              DataCell(Text(order.productModel.mrp.toStringAsFixed(2))),
                              DataCell(Text(order.quantity?.toStringAsFixed(2) ?? '')),
                              DataCell(Text(price.toStringAsFixed(2))),
                              DataCell(Text(totalPrice.toStringAsFixed(2))),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                HorizontalTitleValueComponent(
                  title: 'Total Quantity',
                  value: totalQuantity.toStringAsFixed(2),
                  titleFontSize: 14,
                  valueFontSize: 16,
                  titleFontWeight: FontWeight.w600,
                  valueFontWeight: FontWeight.w700,
                ),
                SizedBox(height: 8),
                HorizontalTitleValueComponent(
                  title: 'Total Price',
                  value: totalPrice.toStringAsFixed(2),
                  titleFontSize: 14,
                  valueFontSize: 16,
                  titleFontWeight: FontWeight.w600,
                  valueFontWeight: FontWeight.w700,
                ),
                SizedBox(height: 8),
                HorizontalTitleValueComponent(
                  title: 'GST(28%)',
                  value: gstAmount.toStringAsFixed(2),
                  titleFontSize: 14,
                  valueFontSize: 16,
                  titleFontWeight: FontWeight.w600,
                  valueFontWeight: FontWeight.w700,
                ),
                SizedBox(height: 8),
                HorizontalTitleValueComponent(
                  title: 'Grand Price',
                  value: priceAfterGST.toStringAsFixed(2),
                  titleFontSize: 14,
                  valueFontSize: 16,
                  titleFontWeight: FontWeight.w600,
                  valueFontWeight: FontWeight.w700,
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
