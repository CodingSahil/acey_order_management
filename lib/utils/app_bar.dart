import 'package:flutter/material.dart';

PreferredSizeWidget commonAppBar({required String title, bool isDone = false, void Function()? onDone}) {
  return AppBar(
    backgroundColor: Colors.blueAccent,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
    actions: [if (isDone) GestureDetector(behavior: HitTestBehavior.translucent, onTap: onDone, child: Icon(Icons.done, color: Colors.white, size: 22))],
    actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  );
}
