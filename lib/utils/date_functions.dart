import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat timeStampFormat = DateFormat("yyyy-MM-dd HH:mm:ssZ");
  static final DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  // static DateTime convertTimeStampIntoDate(Timestamp timestamp) => timestamp.toDate();
  //
  // static Timestamp convertDateIntoTimeStamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

  static DateTime convertStringIntoDateTime(String dateTimeString) {
    return dateFormat.parse(dateTimeString);
  }

  static String convertDateTimeIntoString(DateTime dateTime) {
    return dateFormat.format(dateTime);
  }

  static Timestamp convertStringIntoTimeStamp(String dateTimeString) {
    if (dateTimeString.isNotEmpty && dateTimeString.toLowerCase() != 'null') {
      DateTime dateTimeUnFormatted = DateTime.parse(dateTimeString);
      String formattedDate = timeStampFormat.format(dateTimeUnFormatted);
      DateTime dateTime = timeStampFormat.parse(formattedDate);
      return Timestamp.fromDate(dateTime);
    }
    return Timestamp.now();
  }

  static Timestamp convertDateTimeIntoTimeStamp(DateTime dateTimeString) {
    String formattedDate = timeStampFormat.format(dateTimeString);
    DateTime dateTime = timeStampFormat.parse(formattedDate);
    return Timestamp.fromDate(dateTime);
  }

  static String convertTimeStampIntoString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDateString = timeStampFormat.format(dateTime);
    return formattedDateString;
  }

  static DateTime convertTimeStampIntoDateTime(String timestamp) {
    DateTime dateTime = timeStampFormat.parse(timestamp);
    String formattedDateString = timeStampFormat.format(dateTime);
    return timeStampFormat.parse(formattedDateString);
  }
}
