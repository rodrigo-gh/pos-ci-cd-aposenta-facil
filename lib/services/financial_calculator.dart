import 'dart:math' as math;
import '../models/financial_plan.dart';

class FinancialCalculator {
  static FinancialResult calculate(FinancialInput input) {
    final int totalYears = input.totalYears;
    final int totalMonths = input.totalMonths;
    final double rate = input.monthlyInterestRate;
    final double desiredIncome = input.desiredMonthlyIncome;
    final double initialWealth = input.initialWealth;

    // Se a taxa for zero ou negativa, protegemos contra divisão por zero
    final double safeRate = rate <= 0 ? 0.0001 : rate;

    // 1. Patrimônio Alvo para viver de renda perpétua (Safe Withdrawal)
    final double targetWealth = desiredIncome / safeRate;

    // 2. Valor Futuro do patrimônio inicial existente
    final double fvInitial = initialWealth * math.pow(1.0 + safeRate, totalMonths);

    // 3. Montante remanescente a ser acumulado via aportes mensais
    final double remainingTarget = math.max(0.0, targetWealth - fvInitial);

    // 4. Cálculo do Aporte Mensal (PMT)
    double monthlyContribution = 0.0;
    if (remainingTarget > 0) {
      final double compoundFactor = math.pow(1.0 + safeRate, totalMonths) - 1.0;
      if (compoundFactor > 0) {
        monthlyContribution = (remainingTarget * safeRate) / compoundFactor;
      }
    }

    // 5. Total aportado do bolso e juros acumulados
    final double totalDeposited = initialWealth + (monthlyContribution * totalMonths);
    final double totalInterest = math.max(0.0, targetWealth - totalDeposited);

    int depositPercent = 0;
    int interestPercent = 0;
    if (targetWealth > 0) {
      depositPercent = ((totalDeposited / targetWealth) * 100).round().clamp(1, 100);
      interestPercent = (100 - depositPercent).clamp(0, 99);
    }

    // 6. Projeção anual da curva de evolução
    final List<YearlyDataPoint> projection = [];
    int? inflectionYear;
    double currentAccumulated = initialWealth;

    for (int y = 0; y <= totalYears; y++) {
      final int currentAge = input.currentAge + y;
      final double totalDepositsAtYear = initialWealth + (monthlyContribution * y * 12);

      projection.add(YearlyDataPoint(
        age: currentAge,
        yearOffset: y,
        totalDeposited: totalDepositsAtYear,
        totalWealth: currentAccumulated,
      ));

      // Simula os próximos 12 meses para o próximo ano
      for (int m = 0; m < 12; m++) {
        final double monthlyInterestGenerated = currentAccumulated * safeRate;
        if (inflectionYear == null && y > 0 && monthlyInterestGenerated >= monthlyContribution && monthlyContribution > 0) {
          inflectionYear = y;
        }
        currentAccumulated = (currentAccumulated + monthlyContribution) * (1.0 + safeRate);
      }
    }

    return FinancialResult(
      targetWealth: targetWealth,
      monthlyContribution: monthlyContribution,
      totalDeposited: totalDeposited,
      totalInterest: totalInterest,
      depositPercent: depositPercent,
      interestPercent: interestPercent,
      totalYears: totalYears,
      totalMonths: totalMonths,
      projection: projection,
      inflectionYear: inflectionYear,
    );
  }
}
