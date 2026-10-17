import 'package:flutter/material.dart';
import '../../models/financial_plan.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import 'metric_sub_card.dart';

class HeroResultCard extends StatelessWidget {
  final FinancialResult result;
  final int currentAge;
  final int targetAge;
  final double initialWealth;
  final String desiredIncomeText;

  const HeroResultCard({
    super.key,
    required this.result,
    required this.currentAge,
    required this.targetAge,
    required this.initialWealth,
    required this.desiredIncomeText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceContainer,
            colors.surfaceContainerHigh,
            colors.tertiaryContainer.withValues(alpha: colors.isDark ? 0.25 : 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: colors.cardShadow,
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBadge(colors),
          const SizedBox(height: 20),
          if (result.isGoalReachedByInitialWealth) ...[
            _buildSelfSustainedContent(colors),
          ] else ...[
            _buildStandardContributionContent(colors),
          ],
          const SizedBox(height: 20),
          _buildSubCards(colors),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge(FinancialPalette colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (result.isGoalReachedByInitialWealth) ...[
                Icon(Icons.verified, size: 14, color: colors.tertiary),
                const SizedBox(width: 6),
              ],
              Text(
                result.isGoalReachedByInitialWealth
                    ? 'Meta Atingível aos ${result.organicGoalAge?.toStringAsFixed(1) ?? targetAge.toString()} anos'
                    : 'Meta aos $targetAge anos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.tertiary,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${result.totalYears} anos de acumulação',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildSelfSustainedContent(FinancialPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'APORTE MENSAL ADICIONAL',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 11,
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              CurrencyFormatter.format(0.0),
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                color: colors.onSurface,
                letterSpacing: -1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.tertiary.withValues(alpha: 0.4)),
              ),
              child: Text(
                '100% coberto pelo patrimônio atual',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colors.tertiary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Seu saldo inicial de ${CurrencyFormatter.format(initialWealth)} já rende juros compostos suficientes para alcançar o patrimônio alvo de ${CurrencyFormatter.format(result.targetWealth)} aos ${result.organicGoalAge?.toStringAsFixed(1) ?? targetAge.toString()} anos.',
          style: TextStyle(color: colors.onSurface, fontSize: 12, height: 1.4),
        ),
        if (result.acceleratedAgeWith500 != null &&
            result.acceleratedAgeWith500! < (result.organicGoalAge ?? targetAge.toDouble())) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.bolt, color: colors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dica de Aceleração: Se você aportar R\$ 500,00/mês, sua aposentadoria é antecipada para os ${result.acceleratedAgeWith500!.toStringAsFixed(1)} anos (você conquista a liberdade financeira ${((result.organicGoalAge ?? targetAge.toDouble()) - result.acceleratedAgeWith500!).round()} anos mais cedo)!',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStandardContributionContent(FinancialPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'APORTE MENSAL RECOMENDADO',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 11,
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              CurrencyFormatter.format(result.monthlyContribution),
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                color: colors.onSurface,
                letterSpacing: -1,
              ),
            ),
            Text(
              '/ mês',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.tertiary,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        if (result.monthlyContribution < 25.0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colors.secondary, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Meta residual: Seu patrimônio inicial já cobre quase a totalidade da meta. O aporte de ${CurrencyFormatter.format(result.monthlyContribution)}/mês é apenas o pequeno complemento para fechar os 100%.',
                    style: TextStyle(color: colors.secondary, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: 6),
          Text(
            'Valores constantes em moeda de hoje (poder de compra preservado).',
            style: TextStyle(color: colors.secondary, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildSubCards(FinancialPalette colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 460;
        final cards = [
          MetricSubCard(
            title: 'PATRIMÔNIO ALVO',
            icon: Icons.savings_outlined,
            iconColor: colors.tertiary,
            value: CurrencyFormatter.format(result.targetWealth),
            subtitle: 'Gera ${CurrencyFormatter.format(CurrencyFormatter.parse(desiredIncomeText))}/mês de renda perpétua',
          ),
          MetricSubCard(
            title: 'PRAZO TOTAL',
            icon: Icons.schedule,
            iconColor: colors.primary,
            value: '${result.totalYears} anos',
            valueColor: colors.primary,
            subtitle: result.isGoalReachedByInitialWealth
                ? 'Atingido aos ${result.organicGoalAge?.toStringAsFixed(1) ?? targetAge.toString()} anos'
                : '${result.totalMonths} aportes mensais programados',
          ),
        ];

        if (isTight) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 12),
              cards[1],
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 14),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }
}
