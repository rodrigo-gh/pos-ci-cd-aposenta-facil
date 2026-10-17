import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class InflectionAdvisoryCard extends StatelessWidget {
  final int inflectionYear;
  final int currentAge;

  const InflectionAdvisoryCard({
    super.key,
    required this.inflectionYear,
    required this.currentAge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final ageAtInflection = currentAge + inflectionYear;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.flash_on, color: colors.amberAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ponto de Inflexão dos Juros (No $inflectionYearº ano)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aos $ageAtInflection anos, os juros mensais gerados pelo seu patrimônio passarão a ser maiores do que o seu próprio aporte do bolso. Nesse momento, a curva de crescimento exponencial acelera significativamente.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
