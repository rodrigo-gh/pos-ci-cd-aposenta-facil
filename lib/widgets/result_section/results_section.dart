import 'package:flutter/material.dart';
import '../../models/financial_plan.dart';
import '../breakdown_bar.dart';
import '../wealth_chart.dart';
import 'hero_result_card.dart';
import 'inflection_advisory_card.dart';

class ResultsSection extends StatelessWidget {
  final FinancialResult result;
  final int currentAge;
  final int targetAge;
  final double initialWealth;
  final String desiredIncomeText;

  const ResultsSection({
    super.key,
    required this.result,
    required this.currentAge,
    required this.targetAge,
    required this.initialWealth,
    required this.desiredIncomeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HERO RESULT CARD COM RECOMENDAÇÃO E METRIC SUBCARDS
        HeroResultCard(
          result: result,
          currentAge: currentAge,
          targetAge: targetAge,
          initialWealth: initialWealth,
          desiredIncomeText: desiredIncomeText,
        ),
        const SizedBox(height: 24),
        // 2. BARRA DE DECOMPOSIÇÃO (APORTE VS JUROS COMPOSTOS)
        CompoundBreakdownBar(
          totalDeposited: result.totalDeposited,
          totalInterest: result.totalInterest,
          depositPercent: result.depositPercent,
          interestPercent: result.interestPercent,
        ),
        const SizedBox(height: 24),
        // 3. GRÁFICO VETORIAL INTERATIVO E TABELA DE MARCOS
        WealthEvolutionChart(
          projection: result.projection,
          targetWealth: result.targetWealth,
          inflectionYear: result.inflectionYear,
          currentAge: currentAge,
          targetAge: targetAge,
        ),
        const SizedBox(height: 24),
        // 4. NOTA EXPLICATIVA DO PONTO DE INFLEXÃO EXPONENCIAL
        if (result.inflectionYear != null)
          InflectionAdvisoryCard(
            inflectionYear: result.inflectionYear!,
            currentAge: currentAge,
          ),
      ],
    );
  }
}
