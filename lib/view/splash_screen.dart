import 'dart:developer';
import 'package:acey_order_management/utils/loader.dart';
import 'package:acey_order_management/utils/routes/routes.dart';
import 'package:acey_order_management/utils/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  RxBool loader = false.obs;
  final GetStorage getStorage = GetStorage();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loader(true);
      log(getStorage.getKeys().toString(), name: 'getKeys');
      var data = await getStorage.read(StorageKeys.userDetails);
      await Future.delayed(Duration(milliseconds: 500));
      if (data != null) {
        log(data);
      }
      await Future.delayed(Duration(milliseconds: 500));
      await Future.delayed(Duration(seconds: 1));
      loader(false);
      if (data != null) {
        Get.offAllNamed(Routes.dashboardScreen);
      } else {
        Get.offAllNamed(Routes.loginScreen);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text('ACEY Order Management App', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            ),
            SizedBox(height: 10),
            Obx(
              () =>
                  loader.value
                      ? SizedBox(width: 12, height: 12, child: Loader(color: Colors.black, strokeWidth: 1))
                      : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
