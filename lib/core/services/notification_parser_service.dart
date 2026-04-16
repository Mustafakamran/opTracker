import '../../core/constants/enums.dart';

/// Parsed result from a payment notification.
class ParsedTransaction {
  final double? amount;
  final String? merchant;
  final String? description;
  final TransactionType type;
  final TransactionCategory category;
  final PaymentSource source;

  const ParsedTransaction({
    this.amount,
    this.merchant,
    this.description,
    required this.type,
    required this.category,
    required this.source,
  });
}

/// Service that parses payment notifications to extract transaction details.
class NotificationParserService {
  /// Known payment app package names mapped to their source type.
  static const Map<String, PaymentSource> _packageToSource = {
    'com.paypal.android.p2pmobile': PaymentSource.paypal,
    'com.venmo': PaymentSource.venmo,
    'com.squareup.cash': PaymentSource.cashApp,
    'com.google.android.apps.nbu.paisa.user': PaymentSource.googlePay,
    'com.google.android.apps.walletnfcrel': PaymentSource.googlePay,
    'com.zellepay.zelle': PaymentSource.zelle,
    'com.stripe.android': PaymentSource.stripe,
    'com.amazon.mShop.android.shopping': PaymentSource.amazonPay,
  };

  /// Common bank app package prefixes.
  static const List<String> _bankPackagePrefixes = [
    'com.chase',
    'com.wellsfargo',
    'com.bankofamerica',
    'com.citi',
    'com.usaa',
    'com.capitalone',
    'com.ally',
    'com.discover',
    'com.td',
    'com.pnc',
    'com.usbank',
    'com.regions',
    'com.key',
    'com.huntington',
    'com.fifththird',
  ];

  /// Amount detection patterns.
  static final List<RegExp> _amountPatterns = [
    RegExp(r'\$\s*([\d,]+\.?\d{0,2})'),           // $100.00
    RegExp(r'USD\s*([\d,]+\.?\d{0,2})'),            // USD 100.00
    RegExp(r'([\d,]+\.?\d{0,2})\s*(?:USD|dollars?)'), // 100.00 USD
    RegExp(r'amount[:\s]+([\d,]+\.?\d{0,2})', caseSensitive: false),
    RegExp(r'total[:\s]+([\d,]+\.?\d{0,2})', caseSensitive: false),
    RegExp(r'paid\s+\$?([\d,]+\.?\d{0,2})', caseSensitive: false),
    RegExp(r'sent\s+\$?([\d,]+\.?\d{0,2})', caseSensitive: false),
    RegExp(r'received\s+\$?([\d,]+\.?\d{0,2})', caseSensitive: false),
    RegExp(r'charged\s+\$?([\d,]+\.?\d{0,2})', caseSensitive: false),
  ];

  /// Expense keywords.
  static final RegExp _expenseKeywords = RegExp(
    r'(purchase|bought|paid|charged|payment|spent|debit|withdrawal|sent)',
    caseSensitive: false,
  );

  /// Income keywords.
  static final RegExp _incomeKeywords = RegExp(
    r'(received|deposit|credit|refund|cashback|earned|incoming)',
    caseSensitive: false,
  );

  /// Transfer keywords.
  static final RegExp _transferKeywords = RegExp(
    r'(transfer|sent to|received from|moved)',
    caseSensitive: false,
  );

  /// Attempt to parse a notification into transaction data.
  ParsedTransaction? parse({
    required String packageName,
    String? title,
    String? text,
    String? bigText,
  }) {
    final source = _identifySource(packageName);
    if (source == null) return null;

    final fullText = [title, text, bigText]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');

    if (fullText.isEmpty) return null;

    final amount = _extractAmount(fullText);
    if (amount == null) return null;

    final type = _identifyType(fullText);
    final merchant = _extractMerchant(fullText, title);
    final category = _guessCategory(fullText, merchant);

    return ParsedTransaction(
      amount: amount,
      merchant: merchant,
      description: text ?? title,
      type: type,
      category: category,
      source: source,
    );
  }

  PaymentSource? _identifySource(String packageName) {
    if (_packageToSource.containsKey(packageName)) {
      return _packageToSource[packageName];
    }

    for (final prefix in _bankPackagePrefixes) {
      if (packageName.startsWith(prefix)) {
        return PaymentSource.bank;
      }
    }

    // Check if text contains payment keywords even for unknown apps
    return null;
  }

  double? _extractAmount(String text) {
    for (final pattern in _amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '');
        if (amountStr != null) {
          return double.tryParse(amountStr);
        }
      }
    }
    return null;
  }

  TransactionType _identifyType(String text) {
    if (_transferKeywords.hasMatch(text)) return TransactionType.transfer;
    if (_incomeKeywords.hasMatch(text)) return TransactionType.income;
    if (_expenseKeywords.hasMatch(text)) return TransactionType.expense;
    return TransactionType.expense; // Default to expense
  }

  String? _extractMerchant(String text, String? title) {
    // Try to extract from "at <merchant>" pattern
    final atMatch = RegExp("at\\s+([A-Z][\\w\\s&'-]+)", caseSensitive: false).firstMatch(text);
    if (atMatch != null) return atMatch.group(1)?.trim();

    // Try to extract from "to <recipient>" pattern
    final toMatch = RegExp("to\\s+([A-Z][\\w\\s&'-]+)", caseSensitive: false).firstMatch(text);
    if (toMatch != null) return toMatch.group(1)?.trim();

    // Try to extract from "from <sender>" pattern
    final fromMatch = RegExp("from\\s+([A-Z][\\w\\s&'-]+)", caseSensitive: false).firstMatch(text);
    if (fromMatch != null) return fromMatch.group(1)?.trim();

    return title;
  }

  TransactionCategory _guessCategory(String text, String? merchant) {
    final combined = '$text ${merchant ?? ''}'.toLowerCase();

    if (_matchesAny(combined, ['food', 'restaurant', 'cafe', 'coffee', 'pizza', 'burger', 'doordash', 'ubereats', 'grubhub'])) {
      return TransactionCategory.food;
    }
    if (_matchesAny(combined, ['amazon', 'walmart', 'target', 'shop', 'store', 'buy', 'purchase', 'mall'])) {
      return TransactionCategory.shopping;
    }
    if (_matchesAny(combined, ['electric', 'water', 'gas', 'internet', 'phone', 'bill', 'utility', 'rent', 'mortgage'])) {
      return TransactionCategory.bills;
    }
    if (_matchesAny(combined, ['netflix', 'spotify', 'hulu', 'disney', 'subscribe', 'membership', 'premium'])) {
      return TransactionCategory.subscription;
    }
    if (_matchesAny(combined, ['uber', 'lyft', 'fuel', 'parking', 'transit', 'train', 'bus', 'airline', 'flight'])) {
      return TransactionCategory.transport;
    }
    if (_matchesAny(combined, ['movie', 'game', 'concert', 'ticket', 'entertain', 'steam', 'playstation', 'xbox'])) {
      return TransactionCategory.entertainment;
    }
    if (_matchesAny(combined, ['hospital', 'doctor', 'pharmacy', 'medical', 'health', 'dental', 'clinic'])) {
      return TransactionCategory.health;
    }
    if (_matchesAny(combined, ['school', 'university', 'course', 'tuition', 'book', 'education', 'udemy'])) {
      return TransactionCategory.education;
    }
    if (_matchesAny(combined, ['transfer', 'sent', 'received', 'zelle', 'venmo'])) {
      return TransactionCategory.transfer;
    }

    return TransactionCategory.other;
  }

  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }
}
