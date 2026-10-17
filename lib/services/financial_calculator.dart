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

    // 4. Cálculo do Aporte Mensal (PMT - ordinary annuity / postcipado)
    double monthlyContribution = 0.0;
    if (remainingTarget > 0) {
      final double compoundFactor = math.pow(1.0 + safeRate, totalMonths) - 1.0;
      if (compoundFactor > 0) {
        monthlyContribution = (remainingTarget * safeRate) / compoundFactor;
      }
    }

    // 5. Verificação de Meta Autossustentável (atingida organicamente pelo patrimônio inicial)
    bool isGoalReachedByInitial = false;
    double? organicGoalAge;
    if (initialWealth > 0 && targetWealth > 0) {
      if (initialWealth >= targetWealth) {
        isGoalReachedByInitial = true;
        organicGoalAge = input.currentAge.toDouble();
      } else {
        final double organicMonths = math.log(targetWealth / initialWealth) / math.log(1.0 + safeRate);
        if (organicMonths <= totalMonths) {
          isGoalReachedByInitial = true;
          organicGoalAge = input.currentAge + (organicMonths / 12.0);
        }
      }
    }

    // 6. Estimativa de Aceleração com aporte moderado de R$ 500/mês
    double? acceleratedAgeWith500;
    const double testPMT = 500.0;
    if (targetWealth > initialWealth) {
      final double pmtOverRate = testPMT / safeRate;
      final double numerator = targetWealth + pmtOverRate;
      final double denominator = initialWealth + pmtOverRate;
      if (denominator > 0 && numerator > denominator) {
        final double accMonths = math.log(numerator / denominator) / math.log(1.0 + safeRate);
        if (accMonths > 0 && accMonths < totalMonths) {
          acceleratedAgeWith500 = input.currentAge + (accMonths / 12.0);
        }
      }
    }

    // 7. Projeção anual da curva de evolução
    final List<YearlyDataPoint> projection = [];
    int? inflectionYear;
    double currentAccumulated = initialWealth;

    for (int y = 0; y <= totalYears; y++) {
      final int currentAge = input.currentAge + y;
      final double totalDepositsAtYear = initialWealth + (monthlyContribution * y * 12);
      final double monthlyPassive = currentAccumulated * safeRate;

      // Mede os juros gerados ao longo dos próximos 12 meses
      double accumulatedNextYear = currentAccumulated;
      for (int m = 0; m < 12; m++) {
        final double monthlyInterestGenerated = accumulatedNextYear * safeRate;
        if (inflectionYear == null && y > 0 && monthlyInterestGenerated >= monthlyContribution && monthlyContribution > 0) {
          inflectionYear = y;
        }
        accumulatedNextYear = (accumulatedNextYear * (1.0 + safeRate)) + monthlyContribution;
      }

      final double interestInYear = math.max(0.0, (accumulatedNextYear - currentAccumulated) - (monthlyContribution * 12));

      projection.add(YearlyDataPoint(
        age: currentAge,
        yearOffset: y,
        totalDeposited: totalDepositsAtYear,
        totalWealth: currentAccumulated,
        interestInYear: interestInYear,
        monthlyPassiveIncome: monthlyPassive,
      ));

      currentAccumulated = accumulatedNextYear;
    }

    // 8. Total aportado do bolso e juros acumulados sobre o patrimônio final real
    final double projectedFinalWealth = projection.isNotEmpty ? projection.last.totalWealth : fvInitial;
    final double totalDeposited = initialWealth + (monthlyContribution * totalMonths);
    final double totalInterest = math.max(0.0, projectedFinalWealth - totalDeposited);

    int depositPercent = 0;
    int interestPercent = 0;
    final double baseWealth = math.max(projectedFinalWealth, targetWealth);
    if (baseWealth > 0) {
      depositPercent = ((totalDeposited / baseWealth) * 100).round().clamp(1, 100);
      interestPercent = (100 - depositPercent).clamp(0, 99);
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
      isGoalReachedByInitialWealth: isGoalReachedByInitial,
      organicGoalAge: organicGoalAge,
      projectedFinalWealth: projectedFinalWealth,
      acceleratedAgeWith500: acceleratedAgeWith500,
    );
  }
}
