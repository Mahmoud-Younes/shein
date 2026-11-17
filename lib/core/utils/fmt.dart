import 'package:intl/intl.dart';

/// Shared formatting helpers (US store locale — SHEIN-style "$" pricing).
class Fmt {
  static final NumberFormat _price =
      NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: 2);

  static String price(num value) => _price.format(value);

  static String date(int millisecondsSinceEpoch) => DateFormat('MMM d, yyyy')
      .format(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch));

  /// "1,234 ratings" style count.
  static String count(int value) => NumberFormat.decimalPattern('en_US').format(value);
}
