import 'package:get/get.dart';

enum AddEditEnum { Add, Edit }

enum PackingType { RegularPacking, SinglePackingWithPlainBag, NoPrintingNoMRP, NoPrintingWithMRP, BundlePacking }

/// UserType Enum
enum UserType { SuperAdmin, Employee, None }

UserType convertStringToEnum(String userType) {
  return UserType.values.firstWhereOrNull((element) => element.toString().split(".").last.toLowerCase() == userType.toLowerCase()) ?? UserType.None;
}

String convertEnumToString(UserType userType) {
  if (UserType.values.any((element) => element == userType)) {
    return userType.toString().split(".").last.toLowerCase();
  }
  return UserType.None.toString().split(".").last.toLowerCase();
}
