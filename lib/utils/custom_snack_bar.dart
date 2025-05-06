import 'package:flutter/material.dart';

void errorSnackBar({required BuildContext context, required String title}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(title, style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600, color: Colors.white))));
}

void successSnackBar({required BuildContext context, required String title}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text(title, style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600, color: Colors.black))));
}
