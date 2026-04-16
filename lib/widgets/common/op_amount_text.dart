import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

/// Displays a currency amount with monospace font and optional color coding.
class OpAmountText extends StatelessWidget {
  final double amount;
  final bool showSign;
  final bool isExpense;
  final double fontSize;
  final FontWeight fontWeight;

  const OpAmountText({
    super.key,
    required this.amount,
    this.showSign = false,
    this.isExpense = true,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final color = showSign
        ? (isExpense ? AppColors.error : AppColors.success)
        : Theme.of(context).textTheme.bodyLarge?.color;

    final text = showSign
        ? (isExpense ? '-${CurrencyFormatter.format(amount)}' : '+${CurrencyFormatter.format(amount)}')
        : CurrencyFormatter.format(amount);

    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
