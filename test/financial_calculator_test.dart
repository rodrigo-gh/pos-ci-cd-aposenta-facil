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

    test('Gera a curva de projeção anual com pontos válidos', () {
      const input = FinancialInput(
        currentAge: 25,
        targetAge: 50,
        desiredMonthlyIncome: 5000.0,
        initialWealth: 10000.0,
        monthlyInterestRate: 0.006,
      );

      final result = FinancialCalculator.calculate(input);

      // 25 anos de projeção -> 26 pontos (0 até 25)
      expect(result.projection.length, 26);
      expect(result.projection.first.age, 25);
      expect(result.projection.last.age, 50);
      expect(result.projection.first.totalWealth, closeTo(10000.0, 0.01));
      expect(result.projection.last.totalWealth, greaterThanOrEqualTo(result.targetWealth * 0.99));
    });
  });
}
