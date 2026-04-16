import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _usdFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _compactFormat = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 1);

  static String format(double amount, {String currency = 'USD'}) {
    return _usdFormat.format(amount);
  }

  static String compact(double amount) {
    return _compactFormat.format(amount);
  }

  static String formatSigned(double amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${_usdFormat.format(amount)}';
  }

  static String percentOf(double spent, double total) {
    if (total <= 0) return '0%';
    return '${((spent / total) * 100).toStringAsFixed(0)}%';
  }
}
