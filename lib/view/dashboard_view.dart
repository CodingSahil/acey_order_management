import 'package:acey_order_management/utils/app_bar.dart';
import 'package:acey_order_management/utils/enum.dart';
import 'package:acey_order_management/view/add_edit_order.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(title: 'Dashboard'),
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
