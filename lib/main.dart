import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_constants.dart';
import 'models/financial_plan.dart';
import 'services/financial_calculator.dart';
import 'theme/app_theme.dart';
import 'utils/currency_formatter.dart';
import 'widgets/footer_bar.dart';
import 'widgets/header_bar.dart';
import 'widgets/input_section/simulation_form.dart';
import 'widgets/result_section/results_section.dart';

void main() {
  runApp(const AposentaFacilApp());
}

class AposentaFacilApp extends StatefulWidget {
  const AposentaFacilApp({super.key});

  @override
  State<AposentaFacilApp> createState() => _AposentaFacilAppState();
}

class _AposentaFacilAppState extends State<AposentaFacilApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppConstants.appName} - ${AppConstants.appTagline}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: CalculatorScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const CalculatorScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _currentAgeController =
      TextEditingController(text: AppConstants.defaultCurrentAge.toString());
  final TextEditingController _targetAgeController =
      TextEditingController(text: AppConstants.defaultTargetAge.toString());
  final TextEditingController _desiredIncomeController =
      TextEditingController(text: CurrencyFormatter.formatDecimal(AppConstants.defaultDesiredIncome));
  final TextEditingController _initialWealthController =
      TextEditingController(text: CurrencyFormatter.formatDecimal(AppConstants.defaultInitialWealth));

  final FocusNode _currentAgeFocus = FocusNode();
  final FocusNode _targetAgeFocus = FocusNode();

  bool _hasInitialWealth = true;
  double _monthlyRate = AppConstants.defaultMonthlyRate;
  String _selectedPreset = 'moderado';

  late FinancialResult _result;

  @override
  void initState() {
    super.initState();
    // Valida e formata os campos de idade quando o usuário conclui a digitação (perda de foco)
    _currentAgeFocus.addListener(() {
      if (!_currentAgeFocus.hasFocus) {
        _validateAndNormalizeAges();
      }
    });
    _targetAgeFocus.addListener(() {
      if (!_targetAgeFocus.hasFocus) {
        _validateAndNormalizeAges();
      }
    });
    _calculate();
  }

  @override
  void dispose() {
    _currentAgeFocus.dispose();
    _targetAgeFocus.dispose();
    _currentAgeController.dispose();
    _targetAgeController.dispose();
    _desiredIncomeController.dispose();
    _initialWealthController.dispose();
    super.dispose();
  }

  /// Valida e normaliza as idades somente após o usuário terminar de digitar (perda de foco ou submissão)
  void _validateAndNormalizeAges() {
    int cur = int.tryParse(_currentAgeController.text) ?? AppConstants.defaultCurrentAge;
    int tgt = int.tryParse(_targetAgeController.text) ?? AppConstants.defaultTargetAge;

    cur = cur.clamp(AppConstants.minAge, AppConstants.maxAge);
    if (tgt <= cur) {
      tgt = (cur + 1).clamp(AppConstants.minAge, AppConstants.maxAge);
    } else {
      tgt = tgt.clamp(AppConstants.minAge, AppConstants.maxAge);
    }

    if (_currentAgeController.text != cur.toString()) {
      _currentAgeController.text = cur.toString();
    }
    if (_targetAgeController.text != tgt.toString()) {
      _targetAgeController.text = tgt.toString();
    }
    _calculate();
  }

  /// Realiza o cálculo dinâmico sem sobrescrever o texto que o usuário está digitando ativamente
  void _calculate() {
    final curParsed = int.tryParse(_currentAgeController.text);
    final tgtParsed = int.tryParse(_targetAgeController.text);

    final currentAge = curParsed ?? AppConstants.defaultCurrentAge;
    // Durante a digitação, usa um targetAge seguro para cálculo sem alterar o controller.text
    final targetAge = (tgtParsed != null && tgtParsed > currentAge)
        ? tgtParsed
        : math.max(currentAge + 1, AppConstants.defaultTargetAge);

    final desiredIncome = CurrencyFormatter.parse(_desiredIncomeController.text);
    final initialWealth = _hasInitialWealth
        ? CurrencyFormatter.parse(_initialWealthController.text)
        : 0.0;

    final input = FinancialInput(
      currentAge: currentAge,
      targetAge: targetAge,
      desiredMonthlyIncome: desiredIncome > 0 ? desiredIncome : AppConstants.minDesiredIncome,
      initialWealth: initialWealth,
      monthlyInterestRate: _monthlyRate,
    );

    setState(() {
      _result = FinancialCalculator.calculate(input);
    });
  }

  void _adjustAge(int delta, TextEditingController controller) {
    final isTarget = controller == _targetAgeController;
    final currentAge = int.tryParse(_currentAgeController.text) ?? AppConstants.defaultCurrentAge;
    final currentVal = int.tryParse(controller.text) ?? (isTarget ? AppConstants.defaultTargetAge : currentAge);

    int next = currentVal + delta;
    if (isTarget) {
      next = next.clamp(currentAge + 1, AppConstants.maxAge);
    } else {
      next = next.clamp(AppConstants.minAge, AppConstants.maxAge);
      final currentTarget = int.tryParse(_targetAgeController.text) ?? AppConstants.defaultTargetAge;
      if (currentTarget <= next) {
        _targetAgeController.text = (next + 1).clamp(AppConstants.minAge, AppConstants.maxAge).toString();
      }
    }
    controller.text = next.toString();
    _calculate();
  }

  void _setPreset(String preset, double rate) {
    setState(() {
      _selectedPreset = preset;
      _monthlyRate = rate;
    });
    _calculate();
  }

  void _setDesiredIncome(double amount) {
    _desiredIncomeController.text = CurrencyFormatter.formatDecimal(amount);
    _calculate();
  }

  void _setInitialWealth(double amount) {
    setState(() {
      _hasInitialWealth = amount > 0;
      _initialWealthController.text = CurrencyFormatter.formatDecimal(amount);
    });
    _calculate();
  }

  void _resetForm() {
    setState(() {
      _currentAgeController.text = AppConstants.defaultCurrentAge.toString();
      _targetAgeController.text = AppConstants.defaultTargetAge.toString();
      _desiredIncomeController.text = CurrencyFormatter.formatDecimal(AppConstants.defaultDesiredIncome);
      _hasInitialWealth = true;
      _initialWealthController.text = CurrencyFormatter.formatDecimal(AppConstants.defaultInitialWealth);
      _monthlyRate = AppConstants.defaultMonthlyRate;
      _selectedPreset = 'moderado';
    });
    _calculate();
  }

  void _copySummary() {
    final curAge = int.tryParse(_currentAgeController.text) ?? AppConstants.defaultCurrentAge;
    final tgtAge = curAge + _result.totalYears;

    final summary = CurrencyFormatter.buildSummary(
      currentAge: curAge,
      targetAge: tgtAge,
      totalYears: _result.totalYears,
      desiredIncome: _desiredIncomeController.text,
      monthlyContribution: _result.monthlyContribution,
      targetWealth: _result.targetWealth,
      monthlyRate: _monthlyRate,
    );

    Clipboard.setData(ClipboardData(text: summary));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Resumo do planejamento copiado com sucesso!'),
          ],
        ),
        backgroundColor: AppColors.of(context).tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final curAge = int.tryParse(_currentAgeController.text) ?? AppConstants.defaultCurrentAge;
    final targetAge = curAge + _result.totalYears;
    final initialWealth = _hasInitialWealth
        ? CurrencyFormatter.parse(_initialWealthController.text)
        : 0.0;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          HeaderBar(
            onToggleTheme: widget.onToggleTheme,
            isDarkMode: widget.isDarkMode,
            onCopySummary: _copySummary,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 16.0,
                vertical: 24.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroTitle(isDesktop, colors),
                      const SizedBox(height: 32),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: SimulationForm(
                                currentAgeController: _currentAgeController,
                                targetAgeController: _targetAgeController,
                                currentAgeFocusNode: _currentAgeFocus,
                                targetAgeFocusNode: _targetAgeFocus,
                                desiredIncomeController: _desiredIncomeController,
                                initialWealthController: _initialWealthController,
                                hasInitialWealth: _hasInitialWealth,
                                monthlyRate: _monthlyRate,
                                selectedPreset: _selectedPreset,
                                onCalculate: _calculate,
                                onAdjustAge: (delta, ctrl) => _adjustAge(delta, ctrl),
                                onAgeEditingComplete: _validateAndNormalizeAges,
                                onToggleInitialWealth: (val) {
                                  setState(() => _hasInitialWealth = val);
                                  _calculate();
                                },
                                onSelectIncome: _setDesiredIncome,
                                onSelectInitialWealth: _setInitialWealth,
                                onRateChanged: (val) {
                                  setState(() {
                                    _monthlyRate = val;
                                    _selectedPreset = '';
                                  });
                                  _calculate();
                                },
                                onSelectPreset: _setPreset,
                                onReset: _resetForm,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 7,
                              child: ResultsSection(
                                result: _result,
                                currentAge: curAge,
                                targetAge: targetAge,
                                initialWealth: initialWealth,
                                desiredIncomeText: _desiredIncomeController.text,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        SimulationForm(
                          currentAgeController: _currentAgeController,
                          targetAgeController: _targetAgeController,
                          currentAgeFocusNode: _currentAgeFocus,
                          targetAgeFocusNode: _targetAgeFocus,
                          desiredIncomeController: _desiredIncomeController,
                          initialWealthController: _initialWealthController,
                          hasInitialWealth: _hasInitialWealth,
                          monthlyRate: _monthlyRate,
                          selectedPreset: _selectedPreset,
                          onCalculate: _calculate,
                          onAdjustAge: (delta, ctrl) => _adjustAge(delta, ctrl),
                          onAgeEditingComplete: _validateAndNormalizeAges,
                          onToggleInitialWealth: (val) {
                            setState(() => _hasInitialWealth = val);
                            _calculate();
                          },
                          onSelectIncome: _setDesiredIncome,
                          onSelectInitialWealth: _setInitialWealth,
                          onRateChanged: (val) {
                            setState(() {
                              _monthlyRate = val;
                              _selectedPreset = '';
                            });
                            _calculate();
                          },
                          onSelectPreset: _setPreset,
                          onReset: _resetForm,
                        ),
                        const SizedBox(height: 32),
                        ResultsSection(
                          result: _result,
                          currentAge: curAge,
                          targetAge: targetAge,
                          initialWealth: initialWealth,
                          desiredIncomeText: _desiredIncomeController.text,
                        ),
                      ],
                      const SizedBox(height: 60),
                      const FooterBar(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTitle(bool isDesktop, FinancialPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? 32 : 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: colors.onSurface,
            ),
            children: [
              const TextSpan(text: 'Planejador de '),
              TextSpan(
                text: 'Independência Financeira',
                style: TextStyle(color: colors.tertiary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Simule quanto investir mensalmente para viver de rendimentos reais sem consumir seu patrimônio principal.',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }
}
