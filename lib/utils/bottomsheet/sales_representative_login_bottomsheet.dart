import 'dart:convert';

import 'package:acey_order_management/controller/login_controller.dart';
import 'package:acey_order_management/main.dart';
import 'package:acey_order_management/model/sales_representative_model.dart';
import 'package:acey_order_management/utils/app_colors.dart';
import 'package:acey_order_management/utils/label_text_fields.dart';
import 'package:acey_order_management/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> salesRepresentativeLoginBottomSheet({
  required BuildContext context,
  required LoginController loginController,
  required void Function(SalesRepresentativeModel salesRepresentative) onSubmit,
}) async {
  TextEditingController passwordController = TextEditingController();
  SalesRepresentativeModel? selectedSalesRepresentative;
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    enableDrag: false,
    isDismissible: false,
    showDragHandle: true,
    scrollControlDisabledMaxHeightRatio: 0.9,
    sheetAnimationStyle: AnimationStyle(
      curve: Curves.easeIn,
      reverseCurve: Curves.easeIn,
      duration: Duration(milliseconds: 600),
      reverseDuration: Duration(milliseconds: 400),
    ),
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setBottomSheetState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 18),
                  Text('Select Sales Representative', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  SizedBox(height: 18),
                  Divider(color: Colors.black.withAlpha((255 * 0.25).toInt()), thickness: 0.5, height: 1),
                  SizedBox(height: 18),
                  Expanded(
                    child: ListView.builder(
                      itemCount: loginController.salesRepresentativeList.length,
                      itemBuilder: (context, index) {
                        SalesRepresentativeModel salesRepresentativeModel = loginController.salesRepresentativeList[index];
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setBottomSheetState(() {
                              selectedSalesRepresentative = salesRepresentativeModel;
                              index = 1;
                              print(
                                "selectedSalesRepresenta4tive => ${jsonEncode(selectedSalesRepresentative?.toJson())}\nindex => $index",
                              );
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
                            margin: EdgeInsets.only(bottom: 24.h),
                            decoration: BoxDecoration(
                              color: AppColors.orderCardBackground,
                              border: Border.all(
                                color:
                                    selectedSalesRepresentative != null &&
                                            selectedSalesRepresentative!.id == salesRepresentativeModel.id
                                        ? AppColors.primaryColor
                                        : Colors.black.withAlpha((255 * 0.2).toInt()),
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.h),
                                Text(
                                  salesRepresentativeModel.name,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  salesRepresentativeModel.email,
                                  style: TextStyle(
                                    color: Colors.black.withAlpha((255 * 0.6).toInt()),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                              ],
                            ),
                          ),
                        );
                      },
                      physics: ClampingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 12,
                        bottom: MediaQuery.viewInsetsOf(context).bottom,
                      ),
                    ),
                  ),
                  if (selectedSalesRepresentative != null)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 12,
                        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppTextFormFieldsWithLabel(
                            textEditingController: passwordController,
                            hintText: 'Enter Password',
                            onChanged: (value) {
                              setBottomSheetState(() {});
                            },
                            onFieldSubmitted: (value) {
                              setBottomSheetState(() {});
                            }, isError: false,
                          ),
                          if (passwordController.text == selectedSalesRepresentative!.password) ...[
                            SizedBox(height: 28.h),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                onSubmit(selectedSalesRepresentative!);
                                await Future.delayed(Duration(milliseconds: 600));
                                Navigator.pop(context);
                                await Future.delayed(Duration(milliseconds: 200));
                                Get.offAllNamed(Routes.dashboardScreen);
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                height: 45,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  'Done',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  SizedBox(height: isIOS ? 24 : 4),
                ],
              ),
        ),
  );
}
