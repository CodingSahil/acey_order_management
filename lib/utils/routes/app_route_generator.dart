import 'package:acey_order_management/utils/routes/routes.dart';
import 'package:acey_order_management/view/add_edit_order.dart';
import 'package:acey_order_management/view/dashboard_view.dart';
import 'package:acey_order_management/view/login_view.dart';
import 'package:acey_order_management/view/order_preview_after_add_view.dart';
import 'package:acey_order_management/view/sales_representation_view.dart';
import 'package:acey_order_management/view/splash_screen.dart';
import 'package:flutter/material.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.splashScreen:
      return MaterialPageRoute(builder: (context) => SplashScreenView());

    case Routes.loginScreen:
      return MaterialPageRoute(builder: (context) => LoginView());

    case Routes.dashboardScreen:
      return MaterialPageRoute(builder: (context) => DashboardView());

    case Routes.addEditOrderScreen:
      return MaterialPageRoute(builder: (context) => AddEditOrderView(arguments: settings.arguments));

    case Routes.orderPreviewAfterAddEditScreen:
      return MaterialPageRoute(builder: (context) => OrderPreviewAfterAddView(arguments: settings.arguments));

    case Routes.salesRepresentationView:
      return MaterialPageRoute(builder: (context) => SalesRepresentationView());

    default:
      return MaterialPageRoute(builder: (context) => SplashScreenView());
  }
}
