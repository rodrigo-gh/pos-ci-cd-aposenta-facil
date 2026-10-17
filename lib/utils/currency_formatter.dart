import 'dart:math' as math;
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static final NumberFormat _decimalFormat = NumberFormat('#,##0.00', 'pt_BR');

  /// Formata um double para moeda brasileira (ex: R$ 10.000,00)
  static String format(double value) => _currencyFormat.format(value);

  /// Formata um double para número decimal (ex: 10.000,00)
  static String formatDecimal(double value) => _decimalFormat.format(value);

  /// Converte texto digitado pelo usuário em número decimal seguro
  static double parse(String text) {
    final clean = text.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.isEmpty) return 0.0;
    return (double.tryParse(clean) ?? 0.0) / 100.0;
  }

  /// Formata moeda de forma abreviada para eixos de gráficos (ex: R$ 1.5M, R$ 50k)
  static String formatShort(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(0)}k';
    } else {
      return 'R\$ ${value.toStringAsFixed(0)}';
    }
  }

  /// Calcula a taxa anualizada equivalente acima da inflação
  static double toAnnualRate(double monthlyRate) {
    return (math.pow(1.0 + monthlyRate, 12) - 1.0) * 100.0;
  }

  /// Monta o texto de resumo para cópia na área de transferência
  static String buildSummary({
    required int currentAge,
    required int targetAge,
    required int totalYears,
    required String desiredIncome,
    required double monthlyContribution,
    required double targetWealth,
    required double monthlyRate,
  }) {
    final pmt = format(monthlyContribution);
    final target = format(targetWealth);
    final ratePercent = (monthlyRate * 100).toStringAsFixed(2);

    return 'Planejamento AposentaFácil:\n'
        '• Idade atual: $currentAge anos -> Aposentadoria: $targetAge anos ($totalYears anos de acumulação)\n'
        '• Renda mensal desejada: R\$ $desiredIncome/mês\n'
        '• Aporte mensal recomendado: $pmt/mês\n'
        '• Patrimônio alvo acumulado: $target\n'
        '• Taxa real estimada: $ratePercent% a.m.';
  }
}
