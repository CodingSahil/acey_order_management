import 'dart:developer';

import 'package:acey_order_management/binding/store_binding.dart';
import 'package:acey_order_management/utils/routes/app_route_generator.dart';
import 'package:acey_order_management/utils/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late final bool isIOS;
late final PackageInfo packageInfo;
final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).*$');

void main() async {
  final GetStorage getStorage = GetStorage();
  await Supabase.initialize(
    url: 'https://rualydbnuawknbasiugv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1YWx5ZGJudWF3a25iYXNpdWd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM2MDMwODYsImV4cCI6MjA1OTE3OTA4Nn0.PUg_RNeLVjiNc18_6JWK-mFDYhL3nTFikjbBit2WD7s',
  );
  isIOS = GetPlatform.isIOS;
  packageInfo = await PackageInfo.fromPlatform();
  WidgetsFlutterBinding.ensureInitialized();
  log(getStorage.getKeys().toString(), name: 'getKeys');
  var data = getStorage.read<String>(StorageKeys.userDetails);
  await Future.delayed(Duration(milliseconds: 500));
  log('${data != null}', name: 'data != null');
  await Future.delayed(Duration(seconds: 1));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(720, 1520),
      builder: (context, child) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ACEY App',
          initialBinding: StoreBinding(),
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}
