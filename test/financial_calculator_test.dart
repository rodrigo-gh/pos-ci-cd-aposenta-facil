import 'package:flutter_test/flutter_test.dart';
import 'package:aposenta_facil/models/financial_plan.dart';
import 'package:aposenta_facil/services/financial_calculator.dart';

void main() {
  group('FinancialCalculator Unit Tests', () {
    test('Calcula meta de patrimônio para renda perpétua corretamente', () {
      const input = FinancialInput(
        currentAge: 30,
        targetAge: 60,
        desiredMonthlyIncome: 6000.0,
        initialWealth: 0.0,
        monthlyInterestRate: 0.006, // 0.6% a.m.
      );

      final result = FinancialCalculator.calculate(input);

      // Patrimônio Alvo = 6000 / 0.006 = 1.000.000,00
      expect(result.targetWealth, closeTo(1000000.0, 0.01));
      expect(result.totalYears, 30);
      expect(result.totalMonths, 360);
      expect(result.monthlyContribution, greaterThan(0.0));
      expect(result.totalDeposited + result.totalInterest, closeTo(result.targetWealth, 1.0));
    });

    test('Leva em consideração patrimônio inicial existente', () {
      const inputSemInicial = FinancialInput(
        currentAge: 28,
        targetAge: 55,
        desiredMonthlyIncome: 12000.0,
        initialWealth: 0.0,
        monthlyInterestRate: 0.006,
      );

      const inputComInicial = FinancialInput(
        currentAge: 28,
        targetAge: 55,
        desiredMonthlyIncome: 12000.0,
        initialWealth: 85000.0,
        monthlyInterestRate: 0.006,
      );

      final resSem = FinancialCalculator.calculate(inputSemInicial);
      final resCom = FinancialCalculator.calculate(inputComInicial);

      // O aporte mensal com patrimônio inicial deve ser estritamente menor
      expect(resCom.monthlyContribution, lessThan(resSem.monthlyContribution));
      expect(resCom.targetWealth, equals(resSem.targetWealth));
      expect(resCom.totalDeposited, greaterThan(85000.0));
    });

    test('Se o patrimônio inicial já atinge a meta pelo rendimento puro, aporte é zero', () {
      const input = FinancialInput(
        currentAge: 30,
        targetAge: 60,
        desiredMonthlyIncome: 1000.0, // Meta = 1000 / 0.006 = ~166.666
        initialWealth: 200000.0,     // Já ultrapassa a meta
        monthlyInterestRate: 0.006,
      );

      final result = FinancialCalculator.calculate(input);
      expect(result.monthlyContribution, 0.0);
    });

    test('Detecta meta autossustentável e calcula idade de independência orgânica', () {
      const input = FinancialInput(
        currentAge: 28,
        targetAge: 68,
        desiredMonthlyIncome: 10000.0,
        initialWealth: 100000.0,
        monthlyInterestRate: 0.006, // 0.6% a.m.
      );

      final result = FinancialCalculator.calculate(input);

      expect(result.monthlyContribution, 0.0);
      expect(result.isGoalReachedByInitialWealth, isTrue);
      expect(result.organicGoalAge, isNotNull);
      // ln(16.666)/ln(1.006) = ~470 meses = ~39.2 anos -> 28 + 39.2 = ~67.2 anos
      expect(result.organicGoalAge!, closeTo(67.2, 0.5));
      expect(result.acceleratedAgeWith500, isNotNull);
      expect(result.acceleratedAgeWith500!, lessThan(result.organicGoalAge!));
    });

    test('Com taxa padrão moderada de 0.45% a.m., aporte mensal é consistente e positivo', () {
      const input = FinancialInput(
        currentAge: 28,
        targetAge: 68,
        desiredMonthlyIncome: 10000.0,
        initialWealth: 100000.0,
        monthlyInterestRate: 0.0045, // 0.45% a.m. (Tesouro IPCA+)
      );

      final result = FinancialCalculator.calculate(input);

      // Meta = 10000 / 0.0045 = ~2.222.222
      expect(result.targetWealth, closeTo(2222222.22, 0.01));
      expect(result.monthlyContribution, greaterThan(700.0));
      expect(result.monthlyContribution, lessThan(950.0));
      expect(result.isGoalReachedByInitialWealth, isFalse);
    });
  });
}
