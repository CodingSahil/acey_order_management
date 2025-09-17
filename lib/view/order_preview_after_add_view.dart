import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:acey_order_management/controller/order_preview_after_add_controller.dart';
import 'package:acey_order_management/model/edit_order_navigation.dart';
import 'package:acey_order_management/model/user_model.dart';
import 'package:acey_order_management/utils/date_functions.dart';
import 'package:acey_order_management/utils/label_text_fields.dart';
import 'package:acey_order_management/utils/loader.dart';
import 'package:acey_order_management/utils/storage_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:acey_order_management/model/order_model.dart';
import 'package:acey_order_management/utils/app_bar.dart';
import 'package:acey_order_management/utils/enum.dart';
import 'package:acey_order_management/utils/bottomsheet/products_bottomsheet.dart';
import 'package:acey_order_management/view/add_edit_order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class OrderPreviewAfterAddView extends StatefulWidget {
  const OrderPreviewAfterAddView({super.key, required this.arguments});

  final dynamic arguments;

  @override
  State<OrderPreviewAfterAddView> createState() => _OrderPreviewAfterAddViewState();
}

class _OrderPreviewAfterAddViewState extends State<OrderPreviewAfterAddView> {
  final GetStorage getStorage = GetStorage();
  late final OrderPreviewAfterAddController orderPreviewAfterAddController;
  final String accessKey = 'e06ffa120069430a19932e93ed80700b';
  final String secretAccessKey = '3dab78d309e8551fb9ad34c60f6095f7710dba4f3510a0f67ef44d0ff91a72e5';
  final SupabaseClient supabase = SupabaseClient(
    'https://rualydbnuawknbasiugv.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1YWx5ZGJudWF3a25iYXNpdWd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2MDMwODYsImV4cCI6MjA1OTE3OTA4Nn0.PUg_RNeLVjiNc18_6JWK-mFDYhL3nTFikjbBit2WD7s',
  );
  final String bucketName = 'order-excels-storage';
  EditOrderNavigationModel? editOrderNavigationModel;
  UserModel? userModel;
  int totalQuantity = 0;
  double totalPrice = 0;
  double gstAmount = 0;
  double priceAfterGST = 0;
  RxBool loader = false.obs;
  bool? showSnackBar;

  @override
  void initState() {
    orderPreviewAfterAddController = Get.find<OrderPreviewAfterAddController>();

    if (widget.arguments != null && widget.arguments is EditOrderNavigationModel) {
      editOrderNavigationModel = widget.arguments as EditOrderNavigationModel;
    }

    log('OrderPreviewAfterAddView widget.editOrderNavigationModel != null ${editOrderNavigationModel != null}');

    if (editOrderNavigationModel != null && editOrderNavigationModel!.orderList.isNotEmpty) {
      List<int> listOfQuantity = editOrderNavigationModel!.orderList.map((e) => int.parse(e.quantityController.text)).toList();
      totalQuantity = listOfQuantity.reduce((value, element) => value + element);

      /// total price
      totalPrice = editOrderNavigationModel!.orderList
          .map((e) {
            double price = e.productModel.mrp - ((e.productModel.mrp * editOrderNavigationModel!.discount) / 100);
            return price * (int.parse(e.quantityController.text));
          })
          .toList()
          .reduce((value, element) => value + element);

      gstAmount = ((totalPrice * 28) / 100);

      priceAfterGST = totalPrice + gstAmount;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var data = await getStorage.read(StorageKeys.userDetails);
      userModel = UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
      if (userModel != null) {
        log(jsonEncode(userModel!.toJson()), name: 'userModel => ');
      } else {
        log('userModel == null');
      }
      await orderPreviewAfterAddController.getOrderList();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(title: 'Order Preview'),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          backgroundColor: Colors.blueAccent,
          onPressed: () async {
            final TextEditingController emailController = TextEditingController();
            loader(true);
            final xlsio.Workbook workbook = xlsio.Workbook();
            final xlsio.Worksheet sheet = workbook.worksheets[0];
            sheet.name = 'Order Data';

            sheet.getRangeByIndex(1, 1).setText('Client Name: ${editOrderNavigationModel!.partyName}');
            sheet.getRangeByIndex(2, 1).setText('Delivery Date: ${editOrderNavigationModel!.dateOfDelivery}');
            sheet.getRangeByIndex(3, 1).setText('Packaging Details: ${convertPackingTypeToString(editOrderNavigationModel!.packagingType)}');
            sheet.getRangeByIndex(4, 1).setText('Discount Percentage: ${editOrderNavigationModel!.discount}');

            final List<String> headers = ['Sr. No', 'Reference Part No.', 'AEPL Part No.', 'Description', 'MRP', 'Qty', 'Price', 'Total Price'];

            for (int i = 0; i < headers.length; i++) {
              sheet.getRangeByIndex(5, i + 1).setText(headers[i]);
            }

            int rowIndex = 6;
            for (final row in editOrderNavigationModel!.orderList) {
              sheet.getRangeByIndex(rowIndex, 1).setText(row.productModel.srNumber);
              sheet.getRangeByIndex(rowIndex, 2).setText(row.productModel.referencePartNumber);
              sheet.getRangeByIndex(rowIndex, 3).setText(row.productModel.aeplPartNumber);
              sheet.getRangeByIndex(rowIndex, 4).setText(row.productModel.description);
              sheet.getRangeByIndex(rowIndex, 5).setNumber(row.productModel.mrp.toDouble());
              sheet.getRangeByIndex(rowIndex, 6).setNumber(double.parse(row.quantityController.text).toDouble());
              double price = row.productModel.mrp - ((row.productModel.mrp * editOrderNavigationModel!.discount) / 100);
              double totalPrice = price * (int.parse(row.quantityController.text));
              sheet.getRangeByIndex(rowIndex, 7).setNumber(price);
              sheet.getRangeByIndex(rowIndex, 8).setNumber(totalPrice);
              rowIndex++;
            }
            sheet.getRangeByIndex(rowIndex, 6).setNumber(totalQuantity.toDouble());
            sheet.getRangeByIndex(rowIndex, 8).setNumber(totalPrice.toDouble());
            rowIndex++;
            sheet.getRangeByIndex(rowIndex, 7).setText("GST");
            sheet.getRangeByIndex(rowIndex, 8).setNumber(gstAmount.toDouble());
            rowIndex++;
            sheet.getRangeByIndex(rowIndex, 8).setNumber(priceAfterGST.toDouble());

            final List<int> bytes = workbook.saveAsStream();
            workbook.dispose();

            final Directory cacheDir = await getTemporaryDirectory();
            final String filePath = '${cacheDir.path}/OrderData.xlsx';

            final File file = File(filePath);
            await file.writeAsBytes(bytes, flush: true);

            final String authorization =
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1YWx5ZGJudWF3a25iYXNpdWd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2MDMwODYsImV4cCI6MjA1OTE3OTA4Nn0.PUg_RNeLVjiNc18_6JWK-mFDYhL3nTFikjbBit2WD7s";

            // await OpenFilex.open(filePath);

            bool isError = false;
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder:
                      (context, setInnerState) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text('Enter Email ID', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
                        content: LabeledTextFormField(
                          controller: emailController,
                          hintText: 'Enter Email ID',
                          isError: isError,
                          textInputType: TextInputType.emailAddress,
                          errorMessage: "Email ID is required",

                          onChanged: (value) {
                            setInnerState(() {});
                          },
                          onFieldSubmitted: (value) {
                            setInnerState(() {});
                          },
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              loader(false);
                              return;
                            },
                          ),
                          TextButton(
                            child: Text('OK'),
                            onPressed: () async {
                              setInnerState(() => isError = emailController.text.isEmpty || (emailController.text.isNotEmpty && !EmailValidator.validate(emailController.text)));

                              if (isError) {
                                return;
                              }
                              Navigator.of(context).pop();

                              final String fileName = 'order-excel${DateTime.now()}.xlsx';
                              await supabase.storage.from(bucketName).upload('storage-folder/$fileName', file);
                              String fileURL = supabase.storage.from(bucketName).getPublicUrl('storage-folder/$fileName');
                              final bytes = await file.readAsBytes();
                              final base64File = base64Encode(bytes);
                              file.delete();

                              // log('fileURL => $fileURL');
                              // curl -X POST https://rualydbnuawknbasiugv.supabase.co/functions/v1/email-for-order \
                              // -H "Content-Type: application/json" \
                              // -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1YWx5ZGJudWF3a25iYXNpdWd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2MDMwODYsImV4cCI6MjA1OTE3OTA4Nn0.PUg_RNeLVjiNc18_6JWK-mFDYhL3nTFikjbBit2WD7s" \
                              // -d '{
                              // "to": "sahilchandwanigt@gmail.com",
                              // "subject": "Test Email from cURL",
                              // "content": "This is a test email sent from a curl command using SendGrid + Supabase Edge Functions!"
                              // }'

                              Map<String, dynamic> data = {
                                'to': emailController.text,
                                'subject': "Test Email from cURL",
                                'content': "This is a test email sent from a curl command using SendGrid + Supabase Edge Functions!\n\nYour Excel ID : $fileURL",
                                'filename': fileName,
                                'attachmentBase64': base64File,
                              };

                              log(jsonEncode(data), name: 'jsonEncode(data)');

                              final response = await http.post(
                                Uri.parse('https://rualydbnuawknbasiugv.supabase.co/functions/v1/email-for-order'),
                                headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $authorization'},
                                // re_RFTvwbFh_BK5o8MAh8TeDDZK1NSU3HTUC
                                body: jsonEncode(data),
                              );

                              log(response.body, name: 'response.body');

                              if (response.statusCode == 200) {
                                log('Email sent!');
                                setState(() {
                                  showSnackBar = true;
                                });
                              } else {
                                log('Failed to send email');
                                setState(() {
                                  showSnackBar = false;
                                });
                              }

                              num? remainingUpdate =
                                  editOrderNavigationModel != null
                                      ? editOrderNavigationModel!.remainingUpdate == 0
                                          ? 0
                                          : editOrderNavigationModel!.remainingUpdate
                                      : null;
                              if (remainingUpdate != null && remainingUpdate != 0) {
                                remainingUpdate--;
                              }

                              OrderDetailsModel orderDetailsModel = OrderDetailsModel(
                                id:
                                    editOrderNavigationModel != null && editOrderNavigationModel!.orderID != null
                                        ? editOrderNavigationModel!.orderID!
                                        : orderPreviewAfterAddController.orderDetailsModelList.isNotEmpty
                                        ? getNewID(orderPreviewAfterAddController.orderDetailsModelList.map((e) => e.id).toList())
                                        : 1,
                                userID: userModel != null && userModel!.id != -1000 ? userModel!.id : 1,
                                createdAt: Timestamp.now(),
                                updatedAt: Timestamp.now(),
                                orderDetails: {'orderDetails': editOrderNavigationModel!.orderList.map((e) => e.toJson()).toList()},
                                excelSheetURL: fileURL,
                                partyName: editOrderNavigationModel!.partyName,
                                deliveryDate: editOrderNavigationModel!.dateOfDelivery,
                                numberOfItems: editOrderNavigationModel!.orderList.length,
                                totalQuantity: totalQuantity,
                                totalPrice: totalPrice,
                                gstAmount: gstAmount,
                                grandTotal: priceAfterGST,
                                remainingUpdate: remainingUpdate,
                                discount: editOrderNavigationModel!.discount,
                                packagingType: editOrderNavigationModel!.packagingType,
                              );
                              if (editOrderNavigationModel != null && editOrderNavigationModel!.orderID != null) {
                                await orderPreviewAfterAddController.updateOrder(request: orderDetailsModel.toJson(), context: context, id: editOrderNavigationModel!.orderID!);
                              } else {
                                await orderPreviewAfterAddController.createOrder(request: orderDetailsModel.toJson(), context: context);
                              }
                              await Future.delayed(Duration(seconds: 1));
                              await orderPreviewAfterAddController.getOrderList(isLoaderRequire: false);
                              loader(false);
                              await Future.delayed(Duration(milliseconds: 250));
                              editOrderNavigationModel!.onAddEdit();
                              await Future.delayed(Duration(milliseconds: 500));
                              Get.back();
                              Get.back();
                            },
                          ),
                        ],
                      ),
                );
              },
            );

            // if (showSnackBar != null) {
            //   if (showSnackBar!) {
            //     successSnackBar(context: context, title: "Email sent successfully!!");
            //   } else {
            //     errorSnackBar(context: context, title: "Failed to send Email");
            //   }
            //   setState(() {
            //     showSnackBar = null;
            //   });
            // }
          },
          label:
              loader.value
                  ? SizedBox(height: 24, width: 24, child: Center(child: Loader(color: Colors.white)))
                  : Text(editOrderNavigationModel != null && editOrderNavigationModel!.orderID != null ? 'Update Order' : 'Submit Order', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          icon: loader.value ? SizedBox.shrink() : Icon(Icons.done, color: Colors.white),
        ),
      ),
      body: Obx(
        () =>
            orderPreviewAfterAddController.loader.value
                ? Center(child: Loader(color: Colors.blueAccent))
                : Column(
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
                            value: editOrderNavigationModel!.partyName,
                            titleFontSize: 15,
                            valueFontSize: 16,
                            valueFontWeight: FontWeight.w800,
                            titleFontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 6),
                          HorizontalTitleValueComponent(
                            title: 'Order Date',
                            value: DateFormat('dd-MM-yyyy').format(editOrderNavigationModel!.dateOfDelivery),
                            titleFontSize: 15,
                            valueFontSize: 16,
                            valueFontWeight: FontWeight.w800,
                            titleFontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 6),
                          HorizontalTitleValueComponent(
                            title: 'Discount',
                            value: '${editOrderNavigationModel!.discount}%',
                            titleFontSize: 15,
                            valueFontSize: 16,
                            valueFontWeight: FontWeight.w800,
                            titleFontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 6),
                          HorizontalTitleValueComponent(
                            title: 'Packaging Type',
                            value: packingTypeToString(editOrderNavigationModel!.packagingType),
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
                                  editOrderNavigationModel!.orderList.map((order) {
                                    double price = order.productModel.mrp - ((order.productModel.mrp * editOrderNavigationModel!.discount) / 100);
                                    double totalPrice = price * (double.parse(order.quantityController.text));
                                    log('price => $price & totalPrice => $totalPrice');
                                    return DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text(order.productModel.referencePartNumber)),
                                        DataCell(Text(order.productModel.aeplPartNumber)),
                                        DataCell(Text(order.productModel.description)),
                                        DataCell(Text(double.parse(order.quantityController.text).toStringAsFixed(2))),
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
                            DataColumn(
                              label: Text('Total Quantity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                              columnWidth: FixedColumnWidth(MediaQuery.sizeOf(context).width * 0.48),
                            ),
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
                                DataCell(Text(priceAfterGST.toStringAsFixed(2), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
                  ],
                ),
      ),
    );
  }
}
