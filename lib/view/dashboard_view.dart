import 'dart:convert';
import 'dart:developer';

import 'package:acey_order_management/main.dart';
import 'package:acey_order_management/utils/app_bar.dart';
import 'package:acey_order_management/utils/enum.dart';
import 'package:acey_order_management/utils/loader.dart';
import 'package:acey_order_management/utils/storage_keys.dart';
import 'package:acey_order_management/view/add_edit_order.dart';
import 'package:acey_order_management/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  UserDetails? userDetails;
  late final GetStorage getStorage;
  RxBool logoutLoader = false.obs;

  @override
  void initState() {
    getStorage = GetStorage();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var data = await getStorage.read(StorageKeys.userDetails);
      userDetails = UserDetails.fromJson(jsonDecode(data.toString()));
    });
    log('message => ${GetStorage().read(StorageKeys.userDetails)}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(title: 'Dashboard'),
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
                  if (userDetails != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userDetails!.email, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                        SizedBox(height: 18.h),
                        Divider(color: Colors.black.withAlpha((255 * 0.4).toInt()), height: 1, thickness: 0.5),
                        SizedBox(height: 18.h),
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),
                      ],
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
                                  children: [Text('Log Out', style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.w600)), SizedBox(width: 16.w), Icon(Icons.logout, color: Colors.white, size: 40.h)],
                                ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Get.to(() => AddEditOrderView(addEditEnum: AddEditEnum.Add));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.add, color: Colors.white), SizedBox(width: 12), Text('Add Order', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))],
            ),
          ),
        ),
      ),
    );
  }
}
