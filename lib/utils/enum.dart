import 'package:get/get.dart';

enum AddEditEnum { Add, Edit }

enum PackingType { RegularPacking, SinglePackingWithPlainBag, NoPrintingNoMRP, NoPrintingWithMRP, BundlePacking }

/// UserType Enum
enum UserType { SuperAdmin, Zone, None }

UserType convertStringToEnum(String userType) {
  return UserType.values.firstWhereOrNull(
        (element) => element.toString().split(".").last.toLowerCase() == userType.toLowerCase(),
      ) ??
      UserType.None;
}

String convertEnumToString(UserType userType) {
  if (UserType.values.any((element) => element == userType)) {
    return userType.toString().split(".").last.toLowerCase();
  }
  return UserType.None.toString().split(".").last.toLowerCase();
}

PackingType convertStringToPackingType(String packingType) {
  return PackingType.values.firstWhereOrNull((element) {
        return element.toString().split(".").last == packingType.replaceAll(" ", "");
      }) ??
      PackingType.RegularPacking;
}

String convertPackingTypeToString(PackingType packingType) {
  if (PackingType.values.any((element) => element == packingType)) {
    String packingTypeString = packingType.toString().trim().split(".").last;
    return packingTypeString;
  }
  return '';
}

enum Zones {
  north(value: "North"),
  south(value: "South"),
  east(value: "East"),
  west(value: "West"),
  none(value: "None");

  final String value;

  const Zones({required this.value});
}

Zones convertStringToZones(String zones) {
  return Zones.values.firstWhereOrNull((element) {
        return element.toString().split(".").last.toLowerCase() == zones.replaceAll(" ", "").toLowerCase();
      }) ??
      Zones.west;
}

String convertZonesToString(Zones zone) {
  if (Zones.values.any((element) => element.value.toLowerCase() == zone.value.toLowerCase())) {
    return zone.value;
  }
  return '';
}
