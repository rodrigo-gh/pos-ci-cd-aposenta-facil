import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class CompoundBreakdownBar extends StatelessWidget {
  final double totalDeposited;
  final double totalInterest;
  final int depositPercent;
  final int interestPercent;

  const CompoundBreakdownBar({
    super.key,
    required this.totalDeposited,
    required this.totalInterest,
    required this.depositPercent,
    required this.interestPercent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: colors.cardShadow,
      ),
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.all_inclusive, color: colors.tertiary, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'O Poder dos Juros Compostos',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.rocket_launch, color: colors.tertiary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Efeito Multiplicador',
                      style: TextStyle(
                        color: colors.tertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  Expanded(
                    flex: depositPercent > 0 ? depositPercent : 1,
                    child: Container(color: colors.primary),
                  ),
                  Expanded(
                    flex: interestPercent > 0 ? interestPercent : 1,
                    child: Container(color: colors.tertiary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Legends and Values
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              // Bolso
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4, right: 8),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width < 600
                          ? MediaQuery.of(context).size.width - 80
                          : 320,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              'Aporte do seu bolso',
                              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: colors.outlineVariant),
                              ),
                              child: Text(
                                '$depositPercent%',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(totalDeposited),
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'Inicial + aportes somados',
                          style: TextStyle(color: colors.secondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Juros
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4, right: 8),
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width < 600
                          ? MediaQuery.of(context).size.width - 80
                          : 320,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              'Juros acumulados',
                              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: colors.outlineVariant),
                              ),
                              child: Text(
                                '$interestPercent%',
                                style: TextStyle(
                                  color: colors.onTertiaryContainer,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(totalInterest),
                          style: TextStyle(
                            color: colors.tertiary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'Lucro exponencial gerado pelo tempo',
                          style: TextStyle(color: colors.secondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
