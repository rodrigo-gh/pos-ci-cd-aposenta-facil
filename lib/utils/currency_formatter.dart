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

  /// Converte texto digitado pelo usuário em número decimal seguro.
  /// Trata de forma inteligente números inteiros (ex: "5000"), decimais brasileiros (ex: "5000,00"),
  /// separadores de milhar (ex: "5.000" ou "5.000,00") e notação internacional (ex: "5000.00").
  static double parse(String text) {
    if (text.trim().isEmpty) return 0.0;

    // Remove símbolos monetários, letras e espaços, mantendo apenas dígitos, vírgula e ponto
    String clean = text.replaceAll(RegExp(r'[^\d,\.]'), '').trim();
    if (clean.isEmpty) return 0.0;

    final hasComma = clean.contains(',');
    final hasDot = clean.contains('.');

    if (hasComma && hasDot) {
      final lastComma = clean.lastIndexOf(',');
      final lastDot = clean.lastIndexOf('.');

      if (lastComma > lastDot) {
        // Padrão brasileiro: "1.234.567,89" -> remove pontos de milhar, troca vírgula por ponto
        clean = clean.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Padrão internacional: "1,234,567.89" -> remove vírgulas de milhar
        clean = clean.replaceAll(',', '');
      }
    } else if (hasComma) {
      // Contém apenas vírgula: "5000,00", "5000,5" ou "1,000,000"
      final parts = clean.split(',');
      if (parts.length > 2) {
        // Múltiplas vírgulas -> separador de milhar internacional
        clean = clean.replaceAll(',', '');
      } else {
        // Vírgula decimal padrão brasileiro: "5000,00" -> "5000.00"
        clean = clean.replaceAll(',', '.');
      }
    } else if (hasDot) {
      // Contém apenas ponto: "5.000", "1.000.000", "5000.00", "50.5"
      final parts = clean.split('.');
      if (parts.length > 2) {
        // Múltiplos pontos -> separadores de milhar ("1.000.000" -> "1000000")
        clean = clean.replaceAll('.', '');
      } else {
        final beforeDot = parts[0];
        final afterDot = parts[1];

        // Se após o ponto houver exatamente 3 dígitos e a parte anterior tiver até 3 dígitos,
        // é um separador de milhar brasileiro ("5.000", "50.000", "500.000")
        if (afterDot.length == 3 && beforeDot.isNotEmpty && beforeDot.length <= 3) {
          clean = clean.replaceAll('.', '');
        } else {
          // Caso contrário é um ponto decimal ("5000.00", "5000.5", "50.5")
          // Mantém como está
        }
      }
    }

    return double.tryParse(clean) ?? 0.0;
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
    final parsedIncome = parse(desiredIncome);
    final incomeText = format(parsedIncome > 0 ? parsedIncome : 1000.0);
    final pmt = format(monthlyContribution);
    final target = format(targetWealth);
    final ratePercent = (monthlyRate * 100).toStringAsFixed(2);

    return 'Planejamento AposentaFácil:\n'
        '• Idade atual: $currentAge anos -> Aposentadoria: $targetAge anos ($totalYears anos de acumulação)\n'
        '• Renda mensal desejada: $incomeText/mês\n'
        '• Aporte mensal recomendado: $pmt/mês\n'
        '• Patrimônio alvo acumulado: $target\n'
        '• Taxa real estimada: $ratePercent% a.m.';
  }
}
