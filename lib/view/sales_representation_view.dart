import 'package:acey_order_management/controller/sales_representatiove_controller.dart';
import 'package:acey_order_management/model/sales_representative_model.dart';
import 'package:acey_order_management/utils/app_bar.dart';
import 'package:acey_order_management/utils/app_colors.dart';
import 'package:acey_order_management/utils/bottomsheet/add_edit_sales_representative_bottomsheet.dart';
import 'package:acey_order_management/utils/date_functions.dart';
import 'package:acey_order_management/utils/image_path.dart';
import 'package:acey_order_management/utils/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'add_edit_order.dart';

class SalesRepresentationView extends StatefulWidget {
  const SalesRepresentationView({super.key});

  @override
  State<SalesRepresentationView> createState() => _SalesRepresentationViewState();
}

class _SalesRepresentationViewState extends State<SalesRepresentationView> {
  late final SalesRepresentativeController salesRepresentativeController;

  @override
  void initState() {
    salesRepresentativeController = Get.find<SalesRepresentativeController>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await salesRepresentativeController.getAllSalesRepresentatives();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(title: "Sales Representative"),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          addEditSalesRepresentativeBottomSheet(
            context: context,
            salesRepresentativeController: salesRepresentativeController,
            onSubmit: (salesRepresentativeList) {},
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: Icon(Icons.add, color: Colors.white, size: 20),
      ),
      body: GetBuilder<SalesRepresentativeController>(
        id: "update_sales_representative",
        builder: (controller) {
          return controller.loader.value
              ? Center(child: Loader())
              : controller.salesRepresentatives.isNotEmpty
              ? ListView.builder(
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
                itemCount: controller.salesRepresentatives.length,
                itemBuilder: (context, index) {
                  SalesRepresentativeModel salesRepresentativeModel = controller.salesRepresentatives[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      addEditSalesRepresentativeBottomSheet(
                        context: context,
                        salesRepresentativeController: salesRepresentativeController,
                        preSelectedSalesRepresentative: salesRepresentativeModel,
                        onSubmit: (salesRepresentativeList) {},
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
                      margin: EdgeInsets.only(bottom: 24.h),
                      decoration: BoxDecoration(
                        color: AppColors.orderCardBackground,
                        border: Border.all(
                          color:
                              salesRepresentativeModel.isResigned ? Colors.red : Colors.black.withAlpha((255 * 0.2).toInt()),
                          width: salesRepresentativeModel.isResigned ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              VerticalTitleValueComponent(title: 'ID', value: salesRepresentativeModel.id.toString()),
                              if (salesRepresentativeModel.createdAt != null)
                                VerticalTitleValueComponent(
                                  title: 'Created At',
                                  value: DateFormatter.convertTimeStampIntoString(salesRepresentativeModel.createdAt!),
                                  isEnd: true,
                                ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          HorizontalTitleValueComponent(title: 'Name', value: salesRepresentativeModel.name),
                          SizedBox(height: 12.h),

                          HorizontalTitleValueComponent(title: 'Email', value: salesRepresentativeModel.email),
                          SizedBox(height: 12.h),

                          HorizontalTitleValueComponent(
                            title: 'Contact Number',
                            value: salesRepresentativeModel.contactNumber.toString(),
                          ),
                          SizedBox(height: 12.h),
                          HorizontalTitleValueComponent(title: 'Zone', value: salesRepresentativeModel.zone.value),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    ),
                  );
                },
              )
              : Center(child: Text("No Sales Representative Found"));
        },
      ),
    );
  }
}
