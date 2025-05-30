import 'dart:async';

enum DashboardRefreshEnum { refresh, none }

final StreamController<DashboardRefreshEnum> dashboardStreamController = StreamController();

void changeDashboardRefreshStatus(DashboardRefreshEnum dashboardRefreshEnum) {
  dashboardStreamController.sink.add(dashboardRefreshEnum);
}
