import 'package:intl/intl.dart';

class AppFormatters {
  static String formatCurrency(
    double value, {
    required String locale,
    required String symbol,
  }) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 2,
    ).format(value);
  }

  static String formatDate(DateTime date, {required String pattern}) {
    return DateFormat(pattern).format(date);
  }
}
