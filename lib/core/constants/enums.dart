/// Transaction categories for spending classification.
enum TransactionCategory {
  food('Food & Dining', '🍔'),
  shopping('Shopping', '🛍️'),
  bills('Bills & Utilities', '📄'),
  transfer('Transfers', '💸'),
  entertainment('Entertainment', '🎬'),
  transport('Transport', '🚗'),
  health('Health & Medical', '🏥'),
  education('Education', '📚'),
  subscription('Subscriptions', '🔄'),
  income('Income', '💰'),
  other('Other', '📌');

  const TransactionCategory(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Transaction type.
enum TransactionType {
  expense('Expense'),
  income('Income'),
  transfer('Transfer');

  const TransactionType(this.label);
  final String label;
}

/// Authentication method.
enum AuthMethod {
  google,
  local,
}

/// Time period for reports.
enum TimePeriod {
  daily('Today'),
  weekly('This Week'),
  monthly('This Month'),
  yearly('This Year'),
  custom('Custom');

  const TimePeriod(this.label);
  final String label;
}

/// Budget period.
enum BudgetPeriod {
  weekly('Weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  const BudgetPeriod(this.label);
  final String label;
}

/// Payment source detected from notifications.
enum PaymentSource {
  paypal('PayPal'),
  venmo('Venmo'),
  cashApp('Cash App'),
  googlePay('Google Pay'),
  applePay('Apple Pay'),
  zelle('Zelle'),
  bank('Bank'),
  creditCard('Credit Card'),
  debitCard('Debit Card'),
  stripe('Stripe'),
  amazonPay('Amazon Pay'),
  unknown('Unknown');

  const PaymentSource(this.label);
  final String label;
}

/// Notification parsing status.
enum ParseStatus {
  parsed,
  needsReview,
  ignored,
  manual,
}
