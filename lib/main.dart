import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'models/financial_plan.dart';
import 'services/financial_calculator.dart';
import 'theme/app_theme.dart';
import 'widgets/breakdown_bar.dart';
import 'widgets/wealth_chart.dart';

void main() {
  runApp(const AposentaFacilApp());
}

class AposentaFacilApp extends StatefulWidget {
  const AposentaFacilApp({super.key});

  @override
  State<AposentaFacilApp> createState() => _AposentaFacilAppState();
}

class _AposentaFacilAppState extends State<AposentaFacilApp> {
  // Padrão inicial: Dark Theme para consistência, com alternância instantânea para Light
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AposentaFácil - Planejador de Independência Financeira',
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
  final TextEditingController _currentAgeController = TextEditingController(text: '28');
  final TextEditingController _targetAgeController = TextEditingController(text: '55');
  final TextEditingController _desiredIncomeController = TextEditingController(text: '10.000,00');
  final TextEditingController _initialWealthController = TextEditingController(text: '50.000,00');

  bool _hasInitialWealth = true;
  double _monthlyRate = 0.0045; // 0.45% a.m. real (≈ 5.54% a.a. real - benchmark Tesouro IPCA+)
  String _selectedPreset = 'moderado';

  late FinancialResult _result;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _currentAgeController.dispose();
    _targetAgeController.dispose();
    _desiredIncomeController.dispose();
    _initialWealthController.dispose();
    super.dispose();
  }

  double _parseCurrency(String text) {
    final clean = text.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.isEmpty) return 0.0;
    return (double.tryParse(clean) ?? 0.0) / 100.0;
  }

  void _formatCurrencyInput(TextEditingController controller) {
    final val = _parseCurrency(controller.text);
    final formatted = NumberFormat('#,##0.00', 'pt_BR').format(val);
    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _calculate() {
    final currentAge = int.tryParse(_currentAgeController.text) ?? 28;
    int targetAge = int.tryParse(_targetAgeController.text) ?? 55;

    if (targetAge <= currentAge) {
      targetAge = currentAge + 1;
      _targetAgeController.text = targetAge.toString();
    }

    final desiredIncome = _parseCurrency(_desiredIncomeController.text);
    final initialWealth = _hasInitialWealth ? _parseCurrency(_initialWealthController.text) : 0.0;

    final input = FinancialInput(
      currentAge: currentAge,
      targetAge: targetAge,
      desiredMonthlyIncome: desiredIncome > 0 ? desiredIncome : 1000.0,
      initialWealth: initialWealth,
      monthlyInterestRate: _monthlyRate,
    );

    setState(() {
      _result = FinancialCalculator.calculate(input);
    });
  }

  void _adjustAge(TextEditingController controller, int delta, {int min = 16, int max = 95}) {
    final current = int.tryParse(controller.text) ?? 28;
    final next = (current + delta).clamp(min, max);
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
    _desiredIncomeController.text = NumberFormat('#,##0.00', 'pt_BR').format(amount);
    _calculate();
  }

  void _setInitialWealth(double amount) {
    setState(() {
      _hasInitialWealth = amount > 0;
      _initialWealthController.text = NumberFormat('#,##0.00', 'pt_BR').format(amount);
    });
    _calculate();
  }

  void _resetForm() {
    setState(() {
      _currentAgeController.text = '28';
      _targetAgeController.text = '55';
      _desiredIncomeController.text = '10.000,00';
      _hasInitialWealth = true;
      _initialWealthController.text = '50.000,00';
      _monthlyRate = 0.0045;
      _selectedPreset = 'moderado';
    });
    _calculate();
  }

  void _copySummary() {
    final curAge = _currentAgeController.text;
    final tgtAge = (int.tryParse(_currentAgeController.text) ?? 28) + _result.totalYears;
    final pmt = _currencyFormat.format(_result.monthlyContribution);
    final target = _currencyFormat.format(_result.targetWealth);
    final income = _desiredIncomeController.text;

    final text = 'Planejamento AposentaFácil:\n'
        '• Idade atual: $curAge anos -> Aposentadoria: $tgtAge anos (${_result.totalYears} anos de acumulação)\n'
        '• Renda mensal desejada: R\$ $income/mês\n'
        '• Aporte mensal recomendado: $pmt/mês\n'
        '• Patrimônio alvo acumulado: $target\n'
        '• Taxa real estimada: ${(_monthlyRate * 100).toStringAsFixed(2)}% a.m.';

    Clipboard.setData(ClipboardData(text: text));
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

  void _showMethodologyModal(FinancialPalette colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: colors.tertiary),
            const SizedBox(width: 10),
            Text('Premissas e Metodologia Financeira', style: TextStyle(fontSize: 16, color: colors.onSurface, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Viver de Renda Perpétua (Safe Withdrawal)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'O modelo calcula o montante necessário para que os juros reais mensais cubram integralmente o seu padrão de vida, preservando 100% do capital principal intacto.',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Text(
                '2. Taxa Real (Acima da Inflação)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Todas as taxas são reais (descontadas da inflação). Isso significa que os valores apresentados têm o mesmo poder de compra de hoje, garantindo previsibilidade.',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Text(
                '3. Fórmula do Aporte Mensal (PMT)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Utiliza o cálculo padrão de anuidade com juros compostos: PMT = [ (P_alvo - FV_inicial) * i ] / [ (1 + i)^n - 1 ].',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 12),
              Text(
                '4. Patrimônio Inicial e Efeito Tempo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Em prazos longos (30 a 40 anos), os juros compostos multiplicam o capital inicial em várias vezes seu poder de compra real. Caso o saldo inicial sozinho atinja a meta no prazo, o aporte necessário é R\$ 0,00, e o simulador indica a idade exata de autossustentabilidade e oportunidades de antecipação.',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Entendido', style: TextStyle(color: colors.tertiary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildHeader(screenWidth, colors),
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
                            Expanded(flex: 5, child: _buildInputSection(colors)),
                            const SizedBox(width: 32),
                            Expanded(flex: 7, child: _buildResultsSection(colors)),
                          ],
                        )
                      else ...[
                        _buildInputSection(colors),
                        const SizedBox(height: 32),
                        _buildResultsSection(colors),
                      ],
                      const SizedBox(height: 60),
                      _buildFooter(colors),
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

  Widget _buildHeader(double screenWidth, FinancialPalette colors) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: screenWidth >= 1024 ? 32 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Icon(Icons.trending_up, color: colors.tertiary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.onSurface),
                      children: [
                        const TextSpan(text: 'Aposenta'),
                        TextSpan(text: 'Fácil', style: TextStyle(color: colors.tertiary)),
                      ],
                    ),
                  ),
                ],
              ),
              // Action buttons: Theme Toggle + Methodology + Copy Summary
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Theme Mode Toggle Button
                  InkWell(
                    onTap: widget.onToggleTheme,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            size: 16,
                            color: widget.isDarkMode ? colors.amberAccent : colors.primary,
                          ),
                          if (screenWidth >= 640) ...[
                            const SizedBox(width: 6),
                            Text(
                              widget.isDarkMode ? 'Claro' : 'Escuro',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showMethodologyModal(colors),
                    icon: Icon(Icons.help_outline, size: 16, color: colors.onSurfaceVariant),
                    label: Text('Metodologia', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.outlineVariant),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _copySummary,
                    icon: Icon(Icons.copy, size: 14, color: colors.onTertiary),
                    label: Text('Copiar Resumo', style: TextStyle(color: colors.onTertiary, fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.tertiary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  Widget _buildInputSection(FinancialPalette colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: colors.cardShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune, color: colors.tertiary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Parâmetros da Simulação',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                  ),
                ],
              ),
              Text(
                'CÁLCULO DINÂMICO',
                style: TextStyle(color: colors.secondary.withValues(alpha: 0.8), fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Ages with stepper buttons
          Row(
            children: [
              Expanded(
                child: _buildAgeCard(
                  label: 'Idade Atual',
                  controller: _currentAgeController,
                  colors: colors,
                  onDecrease: () => _adjustAge(_currentAgeController, -1),
                  onIncrease: () => _adjustAge(_currentAgeController, 1),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAgeCard(
                  label: 'Idade Aposentadoria',
                  controller: _targetAgeController,
                  colors: colors,
                  onDecrease: () => _adjustAge(_targetAgeController, -1),
                  onIncrease: () => _adjustAge(_targetAgeController, 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Desired Monthly Income + Quick Chips
          _buildCurrencyField(
            label: 'Renda Mensal Desejada na Aposentadoria',
            controller: _desiredIncomeController,
            suffix: '/ mês',
            colors: colors,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip('R\$ 5.000', () => _setDesiredIncome(5000), colors),
              _buildChip('R\$ 10.000', () => _setDesiredIncome(10000), colors),
              _buildChip('R\$ 15.000', () => _setDesiredIncome(15000), colors),
              _buildChip('R\$ 20.000', () => _setDesiredIncome(20000), colors),
            ],
          ),
          const SizedBox(height: 20),
          // Initial Wealth Switch & Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, color: colors.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Já possui patrimônio investido?',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.onSurface),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'O valor inicial rende juros desde o primeiro dia',
                              style: TextStyle(fontSize: 10, color: colors.secondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _hasInitialWealth,
                  activeThumbColor: colors.tertiary,
                  activeTrackColor: colors.tertiaryContainer,
                  onChanged: (v) {
                    setState(() => _hasInitialWealth = v);
                    _calculate();
                  },
                ),
              ],
            ),
          ),
          if (_hasInitialWealth) ...[
            const SizedBox(height: 12),
            _buildCurrencyField(
              label: 'Patrimônio Inicial Atual',
              controller: _initialWealthController,
              colors: colors,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildChip('R\$ 10.000', () => _setInitialWealth(10000), colors),
                _buildChip('R\$ 50.000', () => _setInitialWealth(50000), colors),
                _buildChip('R\$ 100.000', () => _setInitialWealth(100000), colors),
                _buildChip('R\$ 250.000', () => _setInitialWealth(250000), colors),
              ],
            ),
          ],
          const SizedBox(height: 24),
          // Monthly Rate Slider & Presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxa Real de Retorno Estimada',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(_monthlyRate * 100).toStringAsFixed(2).replaceAll('.', ',')}% a.m.',
                  style: TextStyle(
                    color: colors.onTertiaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Equivalente a ≈ ${((math.pow(1 + _monthlyRate, 12) - 1) * 100).toStringAsFixed(2)}% ao ano (acima da inflação)',
            style: TextStyle(color: colors.secondary, fontSize: 11),
          ),
          Slider(
            value: _monthlyRate.clamp(0.002, 0.008),
            min: 0.002,
            max: 0.008,
            divisions: 12,
            activeColor: colors.tertiary,
            inactiveColor: colors.surfaceContainerHighest,
            onChanged: (v) {
              setState(() {
                _monthlyRate = v;
                _selectedPreset = '';
              });
              _calculate();
            },
          ),
          // Presets buttons alinhados a padrões de mercado (ANBIMA / Tesouro IPCA+)
          Row(
            children: [
              Expanded(
                child: _buildPresetButton('Conservador', '0,35% a.m.', 'conservador', 0.0035, colors),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton('Moderado', '0,45% a.m.', 'moderado', 0.0045, colors),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton('Agressivo', '0,55% a.m.', 'agressivo', 0.0055, colors),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Bottom reset action
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _resetForm,
              icon: Icon(Icons.restart_alt, size: 16, color: colors.onSurfaceVariant),
              label: Text('Restaurar Valores Padrão', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeCard({
    required String label,
    required TextEditingController controller,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
    required FinancialPalette colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: Icon(Icons.remove, size: 18, color: colors.onSurface),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                splashRadius: 16,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) => _calculate(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: colors.onSurface),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrease,
                icon: Icon(Icons.add, size: 18, color: colors.onSurface),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                splashRadius: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap, FinancialPalette colors) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant, fontFamily: 'monospace'),
        ),
      ),
    );
  }

  Widget _buildCurrencyField({
    required String label,
    required TextEditingController controller,
    String? suffix,
    required FinancialPalette colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            _formatCurrencyInput(controller);
            _calculate();
          },
          style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16, color: colors.onSurface),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, top: 14, right: 8),
              child: Text('R\$', style: TextStyle(color: colors.secondary, fontWeight: FontWeight.bold)),
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            filled: true,
            fillColor: colors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(String title, String subtitle, String key, double rate, FinancialPalette colors) {
    final isSelected = _selectedPreset == key;
    return InkWell(
      onTap: () => _setPreset(key, rate),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.surfaceContainerHigh : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? colors.tertiary : colors.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? colors.tertiary : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'monospace',
                color: isSelected ? colors.onSurface : colors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(FinancialPalette colors) {
    final curAge = int.tryParse(_currentAgeController.text) ?? 28;
    final finalAge = curAge + _result.totalYears;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HERO RESULT CARD
        Container(
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
              Row(
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
                        if (_result.isGoalReachedByInitialWealth) ...[
                          Icon(Icons.verified, size: 14, color: colors.tertiary),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          _result.isGoalReachedByInitialWealth
                              ? 'Meta Atingível aos ${_result.organicGoalAge?.toStringAsFixed(1) ?? finalAge.toString()} anos'
                              : 'Meta aos $finalAge anos',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.tertiary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_result.totalYears} anos de acumulação',
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_result.isGoalReachedByInitialWealth) ...[
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
                      _currencyFormat.format(0.0),
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
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.tertiary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Seu saldo inicial de ${_currencyFormat.format(_hasInitialWealth ? _parseCurrency(_initialWealthController.text) : 0)} já rende juros compostos suficientes para alcançar o patrimônio alvo de ${_currencyFormat.format(_result.targetWealth)} aos ${_result.organicGoalAge?.toStringAsFixed(1) ?? finalAge.toString()} anos.',
                  style: TextStyle(color: colors.onSurface, fontSize: 12, height: 1.4),
                ),
                if (_result.acceleratedAgeWith500 != null && _result.acceleratedAgeWith500! < (_result.organicGoalAge ?? finalAge.toDouble())) ...[
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
                            'Dica de Aceleração: Se você aportar R\$ 500,00/mês, sua aposentadoria é antecipada para os ${_result.acceleratedAgeWith500!.toStringAsFixed(1)} anos (você conquista a liberdade financeira ${((_result.organicGoalAge ?? finalAge.toDouble()) - _result.acceleratedAgeWith500!).round()} anos mais cedo)!',
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
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
                      _currencyFormat.format(_result.monthlyContribution),
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
                if (_result.monthlyContribution < 25.0) ...[
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
                            'Meta residual: Seu patrimônio inicial já cobre quase a totalidade da meta. O aporte de ${_currencyFormat.format(_result.monthlyContribution)}/mês é apenas o pequeno complemento para fechar os 100%.',
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
              const SizedBox(height: 20),
              // Sub cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 460;
                  final cards = [
                    _buildSubCard(
                      title: 'PATRIMÔNIO ALVO',
                      icon: Icons.savings_outlined,
                      iconColor: colors.tertiary,
                      value: _currencyFormat.format(_result.targetWealth),
                      subtitle: 'Gera R\$ ${_desiredIncomeController.text}/mês de renda perpétua',
                      colors: colors,
                    ),
                    _buildSubCard(
                      title: 'PRAZO TOTAL',
                      icon: Icons.schedule,
                      iconColor: colors.primary,
                      value: '${_result.totalYears} anos',
                      valueColor: colors.primary,
                      subtitle: _result.isGoalReachedByInitialWealth
                          ? 'Atingido aos ${_result.organicGoalAge?.toStringAsFixed(1) ?? finalAge.toString()} anos'
                          : '${_result.totalMonths} aportes mensais programados',
                      colors: colors,
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
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // BREAKDOWN BAR
        CompoundBreakdownBar(
          totalDeposited: _result.totalDeposited,
          totalInterest: _result.totalInterest,
          depositPercent: _result.depositPercent,
          interestPercent: _result.interestPercent,
        ),
        const SizedBox(height: 24),
        // WEALTH CHART WITH INTERACTIVE HOVER AND TABLE
        WealthEvolutionChart(
          projection: _result.projection,
          targetWealth: _result.targetWealth,
          inflectionYear: _result.inflectionYear,
          currentAge: curAge,
          targetAge: finalAge,
        ),
        const SizedBox(height: 24),
        // INFLECTION ADVISORY NOTE
        if (_result.inflectionYear != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant),
              boxShadow: colors.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.flash_on, color: colors.amberAccent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ponto de Inflexão dos Juros (No ${_result.inflectionYear}º ano)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colors.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aos ${curAge + _result.inflectionYear!} anos, os juros mensais gerados pelo seu patrimônio passarão a ser maiores do que o seu próprio aporte do bolso. Nesse momento, a curva de crescimento exponencial acelera significativamente.',
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSubCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String value,
    Color? valueColor,
    required String subtitle,
    required FinancialPalette colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: colors.secondary, fontSize: 10, letterSpacing: 0.8)),
              Icon(icon, color: iconColor, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: valueColor ?? colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(FinancialPalette colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.outlineVariant, width: 1)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AposentaFácil • Planejador de Independência Financeira',
                  style: TextStyle(color: colors.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ferramenta para fins educacionais baseada em matemática de juros compostos e retirada segura.',
                  style: TextStyle(color: colors.secondary, fontSize: 10),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _showMethodologyModal(colors),
                child: Text('Metodologia', style: TextStyle(color: colors.tertiary, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 16),
              Text('GitHub: rodrigo-gh/pos-ci-cd-aposenta-facil', style: TextStyle(color: colors.secondary, fontSize: 11, fontFamily: 'monospace')),
            ],
          ),
        ],
      ),
    );
  }
}
