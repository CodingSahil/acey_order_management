import 'dart:developer';

import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../utils/products_bottomsheet.dart';
import 'add_edit_order.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({super.key, required this.orderDetailsModel});

  final OrderDetailsModel orderDetailsModel;

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  late final String deliveryDate;
  num totalQuantity = 0;
  num totalPrice = 0;
  num gstAmount = 0;
  num grandTotal = 0;
  List<OrderModel> orderModelList = [];

  @override
  void initState() {
    deliveryDate = DateFormat('dd-MM-yyyy').format(widget.orderDetailsModel.deliveryDate);
    if (widget.orderDetailsModel.orderDetails.isNotEmpty &&
        widget.orderDetailsModel.orderDetails['orderDetails'] != null &&
        widget.orderDetailsModel.orderDetails['orderDetails'] is List &&
        (widget.orderDetailsModel.orderDetails['orderDetails'] as List).isNotEmpty) {
      orderModelList = (widget.orderDetailsModel.orderDetails['orderDetails'] as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (widget.orderDetailsModel.totalQuantity != null) {
      totalQuantity = widget.orderDetailsModel.totalQuantity!;
    }
    if (widget.orderDetailsModel.totalPrice != null) {
      totalPrice = widget.orderDetailsModel.totalPrice!;
    }
    if (widget.orderDetailsModel.gstAmount != null) {
      gstAmount = widget.orderDetailsModel.gstAmount!;
    }
    if (widget.orderDetailsModel.grandTotal != null) {
      grandTotal = widget.orderDetailsModel.grandTotal!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(title: "Order Details for #${widget.orderDetailsModel.id}"),
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
                  title: 'Party Name',
                  value: widget.orderDetailsModel.partyName,
                  titleFontSize: 15,
                  valueFontSize: 16,
                  valueFontWeight: FontWeight.w800,
                  titleFontWeight: FontWeight.w600,
                ),
                SizedBox(height: 6),
                HorizontalTitleValueComponent(title: 'Order Date', value: deliveryDate, titleFontSize: 15, valueFontSize: 16, valueFontWeight: FontWeight.w800, titleFontWeight: FontWeight.w600),
                SizedBox(height: 6),
                HorizontalTitleValueComponent(
                  title: 'Discount',
                  value: '${widget.orderDetailsModel.discount}%',
                  titleFontSize: 15,
                  valueFontSize: 16,
                  valueFontWeight: FontWeight.w800,
                  titleFontWeight: FontWeight.w600,
                ),
                SizedBox(height: 6),
                HorizontalTitleValueComponent(
                  title: 'Packaging Type',
                  value: packingTypeToString(widget.orderDetailsModel.packagingType),
                  isValueExpanded: true,
                  titleFontSize: 13,
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
                    border: TableBorder.all(color: Colors.black, width: 0.5),
                    columns: [
                      DataColumn(label: Text('Reference No.', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('AEPL Part No.', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('MRP', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.w800))),
                      DataColumn(label: Text('Value', style: TextStyle(fontWeight: FontWeight.w800))),
                    ],
                    rows:
                        orderModelList.map((order) {
                          double price = order.productModel.mrp - ((order.productModel.mrp * widget.orderDetailsModel.discount) / 100);
                          double totalPrice = price * (int.tryParse(order.quantityController.text) ?? 0);
                          log('price => $price & totalPrice => $totalPrice');
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(Text(order.productModel.referencePartNumber)),
                              DataCell(Text(order.productModel.aeplPartNumber)),
                              DataCell(Text(order.productModel.description)),
                              DataCell(Text(int.parse(order.quantityController.text).toStringAsFixed(2) ?? '')),
                              DataCell(Text(order.productModel.mrp.toStringAsFixed(2))),
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
          SizedBox(height: 10.h),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Divider(color: Colors.black.withAlpha((255 * 0.15).toInt()))),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DataTable(
                border: TableBorder.all(color: Colors.black, width: 0.5),
                columns: [
                  DataColumn(label: Text('Total Quantity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)), columnWidth: FixedColumnWidth(MediaQuery.sizeOf(context).width * 0.48)),
                  DataColumn(
                    label: Text(totalQuantity.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    columnWidth: FixedColumnWidth(MediaQuery.sizeOf(context).width * 0.48),
                  ),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text('Total Price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400))),
                      DataCell(Text(totalPrice.toStringAsFixed(2), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('GST(28%)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400))),
                      DataCell(Text(gstAmount.toStringAsFixed(2), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(Text('Grand Price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400))),
                      DataCell(Text(grandTotal.toStringAsFixed(2), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
        ],
      ),
    );
  }
}
