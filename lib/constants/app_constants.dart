class AppConstants {
  // Configurações etárias padrão
  static const int defaultCurrentAge = 28;
  static const int defaultTargetAge = 55;
  static const int minAge = 16;
  static const int maxAge = 95;

  // Valores financeiros padrão
  static const double defaultDesiredIncome = 10000.0;
  static const double defaultInitialWealth = 50000.0;
  static const double minDesiredIncome = 1000.0;

  // Taxas reais padrão (alinhadas a NTN-B / Tesouro IPCA+)
  static const double defaultMonthlyRate = 0.0045; // 0.45% a.m. (≈ 5.54% a.a. real)
  static const double minSliderRate = 0.0020; // 0.20% a.m.
  static const double maxSliderRate = 0.0080; // 0.80% a.m.
  static const int sliderDivisions = 12;

  // Presets de Risco / Perfil de Investidor
  static const double conservativeRate = 0.0035; // 0.35% a.m. (≈ 4.28% a.a.)
  static const double moderateRate = 0.0045;     // 0.45% a.m. (≈ 5.54% a.a.)
  static const double aggressiveRate = 0.0055;   // 0.55% a.m. (≈ 6.80% a.a.)

  // Chips de atalho para preenchimento rápido
  static const List<double> incomeChips = [5000.0, 10000.0, 15000.0, 20000.0];
  static const List<double> wealthChips = [10000.0, 50000.0, 100000.0, 250000.0];

  // Identificação e repositório do projeto
  static const String appName = 'AposentaFácil';
  static const String appTagline = 'Planejador de Independência Financeira';
  static const String githubRepo = 'rodrigo-gh/pos-ci-cd-aposenta-facil';
}
