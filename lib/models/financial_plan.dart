class FinancialInput {
  final int currentAge;
  final int targetAge;
  final double desiredMonthlyIncome;
  final double initialWealth;
  final double monthlyInterestRate; // e.g. 0.006 for 0.6%

  const FinancialInput({
    required this.currentAge,
    required this.targetAge,
    required this.desiredMonthlyIncome,
    required this.initialWealth,
    required this.monthlyInterestRate,
  });

  int get totalYears => (targetAge - currentAge).clamp(1, 100);
  int get totalMonths => totalYears * 12;

  FinancialInput copyWith({
    int? currentAge,
    int? targetAge,
    double? desiredMonthlyIncome,
    double? initialWealth,
    double? monthlyInterestRate,
  }) {
    return FinancialInput(
      currentAge: currentAge ?? this.currentAge,
      targetAge: targetAge ?? this.targetAge,
      desiredMonthlyIncome: desiredMonthlyIncome ?? this.desiredMonthlyIncome,
      initialWealth: initialWealth ?? this.initialWealth,
      monthlyInterestRate: monthlyInterestRate ?? this.monthlyInterestRate,
    );
  }
}

class YearlyDataPoint {
  final int age;
  final int yearOffset;
  final double totalDeposited;
  final double totalWealth;
  final double interestInYear;
  final double monthlyPassiveIncome;

  const YearlyDataPoint({
    required this.age,
    required this.yearOffset,
    required this.totalDeposited,
    required this.totalWealth,
    this.interestInYear = 0.0,
    this.monthlyPassiveIncome = 0.0,
  });
}

class FinancialResult {
  final double targetWealth;
  final double monthlyContribution;
  final double totalDeposited;
  final double totalInterest;
  final int depositPercent;
  final int interestPercent;
  final int totalYears;
  final int totalMonths;
  final List<YearlyDataPoint> projection;
  final int? inflectionYear; // Year when monthly interest exceeds monthly PMT

  const FinancialResult({
    required this.targetWealth,
    required this.monthlyContribution,
    required this.totalDeposited,
    required this.totalInterest,
    required this.depositPercent,
    required this.interestPercent,
    required this.totalYears,
    required this.totalMonths,
    required this.projection,
    this.inflectionYear,
  });
}
