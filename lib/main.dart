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

class AposentaFacilApp extends StatelessWidget {
  const AposentaFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AposentaFácil - Planejador de Independência Financeira',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _currentAgeController = TextEditingController(text: '28');
  final TextEditingController _targetAgeController = TextEditingController(text: '55');
  final TextEditingController _desiredIncomeController = TextEditingController(text: '10.000,00');
  final TextEditingController _initialWealthController = TextEditingController(text: '50.000,00');

  bool _hasInitialWealth = true;
  double _monthlyRate = 0.006; // 0.60% a.m. real
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
      _monthlyRate = 0.006;
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
        '• Idade atual: $curAge anos -> Aposentadoria: $tgtAge anos (${_result.totalYears} anos de aportes)\n'
        '• Renda mensal desejada: R\$ $income/mês\n'
        '• Aporte mensal necessário: $pmt/mês\n'
        '• Patrimônio alvo acumulado: $target';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.tertiary, size: 20),
            SizedBox(width: 10),
            Text('Resumo da simulação copiado para a área de transferência!'),
          ],
        ),
        backgroundColor: AppColors.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showMethodologyModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.tertiary),
            SizedBox(width: 10),
            Text('Premissas e Metodologia Financeira', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '1. Viver de Renda Perpétua (Safe Withdrawal)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
              ),
              SizedBox(height: 4),
              Text(
                'O modelo calcula o montante necessário para que os juros reais mensais cubram integralmente o seu padrão de vida, preservando 100% do capital principal intacto.',
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              SizedBox(height: 12),
              Text(
                '2. Taxa Real (Acima da Inflação)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
              ),
              SizedBox(height: 4),
              Text(
                'Todas as taxas são reais (descontadas da inflação). Isso significa que os valores apresentados têm o mesmo poder de compra de hoje, garantindo previsibilidade.',
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              SizedBox(height: 12),
              Text(
                '3. Fórmula do Aporte Mensal (PMT)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
              ),
              SizedBox(height: 4),
              Text(
                'Utiliza o cálculo padrão de anuidade com juros compostos: PMT = [ (P_alvo - FV_inicial) * i ] / [ (1 + i)^n - 1 ].',
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(screenWidth),
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
                      _buildHeroTitle(isDesktop),
                      const SizedBox(height: 32),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: _buildInputSection()),
                            const SizedBox(width: 32),
                            Expanded(flex: 7, child: _buildResultsSection()),
                          ],
                        )
                      else ...[
                        _buildInputSection(),
                        const SizedBox(height: 32),
                        _buildResultsSection(),
                      ],
                      const SizedBox(height: 60),
                      _buildFooter(),
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

  Widget _buildHeader(double screenWidth) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
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
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: const Icon(Icons.trending_up, color: AppColors.tertiary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      children: [
                        TextSpan(text: 'Aposenta'),
                        TextSpan(text: 'Fácil', style: TextStyle(color: AppColors.tertiary)),
                      ],
                    ),
                  ),
                ],
              ),
              // Action buttons (reais e funcionais)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: _showMethodologyModal,
                    icon: const Icon(Icons.help_outline, size: 16, color: AppColors.onSurfaceVariant),
                    label: const Text('Metodologia', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _copySummary,
                    icon: const Icon(Icons.copy, size: 14, color: AppColors.onTertiary),
                    label: const Text('Copiar Resumo', style: TextStyle(color: AppColors.onTertiary, fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
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

  Widget _buildHeroTitle(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? 32 : 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.onSurface,
            ),
            children: const [
              TextSpan(text: 'Planejador de '),
              TextSpan(
                text: 'Independência Financeira',
                style: TextStyle(color: AppColors.tertiary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Simule quanto investir mensalmente para viver de rendimentos reais sem consumir seu patrimônio principal.',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
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
                  const Icon(Icons.tune, color: AppColors.tertiary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Parâmetros da Simulação',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                  ),
                ],
              ),
              Text(
                'CÁLCULO DINÂMICO',
                style: TextStyle(color: AppColors.secondary.withValues(alpha: 0.8), fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold),
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
                  onDecrease: () => _adjustAge(_currentAgeController, -1),
                  onIncrease: () => _adjustAge(_currentAgeController, 1),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAgeCard(
                  label: 'Idade Aposentadoria',
                  controller: _targetAgeController,
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
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip('R\$ 5.000', () => _setDesiredIncome(5000)),
              _buildChip('R\$ 10.000', () => _setDesiredIncome(10000)),
              _buildChip('R\$ 15.000', () => _setDesiredIncome(15000)),
              _buildChip('R\$ 20.000', () => _setDesiredIncome(20000)),
            ],
          ),
          const SizedBox(height: 20),
          // Initial Wealth Switch & Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, color: AppColors.secondary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Já possui patrimônio investido?',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'O valor inicial rende juros desde o primeiro dia',
                              style: TextStyle(fontSize: 10, color: AppColors.secondary),
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
                  activeThumbColor: AppColors.tertiary,
                  activeTrackColor: AppColors.tertiaryContainer,
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
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildChip('R\$ 10.000', () => _setInitialWealth(10000)),
                _buildChip('R\$ 50.000', () => _setInitialWealth(50000)),
                _buildChip('R\$ 100.000', () => _setInitialWealth(100000)),
                _buildChip('R\$ 250.000', () => _setInitialWealth(250000)),
              ],
            ),
          ],
          const SizedBox(height: 24),
          // Monthly Rate Slider & Presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Taxa Real de Retorno Estimada',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(_monthlyRate * 100).toStringAsFixed(2).replaceAll('.', ',')}% a.m.',
                  style: const TextStyle(
                    color: AppColors.onTertiaryContainer,
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
            style: const TextStyle(color: AppColors.secondary, fontSize: 11),
          ),
          Slider(
            value: _monthlyRate,
            min: 0.003,
            max: 0.011,
            divisions: 16,
            activeColor: AppColors.tertiary,
            inactiveColor: AppColors.surfaceContainerHighest,
            onChanged: (v) {
              setState(() {
                _monthlyRate = v;
                _selectedPreset = '';
              });
              _calculate();
            },
          ),
          // Presets buttons
          Row(
            children: [
              Expanded(
                child: _buildPresetButton('Conservador', '0,45% a.m.', 'conservador', 0.0045),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton('Moderado', '0,60% a.m.', 'moderado', 0.0060),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton('Agressivo', '0,75% a.m.', 'agressivo', 0.0075),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Bottom reset action
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _resetForm,
              icon: const Icon(Icons.restart_alt, size: 16, color: AppColors.onSurfaceVariant),
              label: const Text('Restaurar Valores Padrão', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove, size: 18),
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add, size: 18),
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

  Widget _buildChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontFamily: 'monospace'),
        ),
      ),
    );
  }

  Widget _buildCurrencyField({
    required String label,
    required TextEditingController controller,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            _formatCurrencyInput(controller);
            _calculate();
          },
          style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, top: 14, right: 8),
              child: Text('R\$', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
            ),
            suffixText: suffix,
            suffixStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(String title, String subtitle, String key, double rate) {
    final isSelected = _selectedPreset == key;
    return InkWell(
      onTap: () => _setPreset(key, rate),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.tertiary : AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.tertiary : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'monospace',
                color: isSelected ? AppColors.onSurface : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
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
                AppColors.surfaceContainer,
                AppColors.surfaceContainerHigh,
                AppColors.tertiaryContainer.withValues(alpha: 0.25),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant),
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
                      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Meta aos $finalAge anos',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                    ),
                  ),
                  Text(
                    '${_result.totalYears} anos de acumulação',
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'APORTE MENSAL RECOMENDADO',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
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
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: AppColors.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                  const Text(
                    '/ mês',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Valores constantes em moeda de hoje (poder de compra preservado).',
                style: TextStyle(color: AppColors.secondary, fontSize: 12),
              ),
              const SizedBox(height: 20),
              // Sub cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 460;
                  final cards = [
                    _buildSubCard(
                      title: 'PATRIMÔNIO ALVO',
                      icon: Icons.savings_outlined,
                      iconColor: AppColors.tertiary,
                      value: _currencyFormat.format(_result.targetWealth),
                      subtitle: 'Gera R\$ ${_desiredIncomeController.text}/mês de renda perpétua',
                    ),
                    _buildSubCard(
                      title: 'PRAZO TOTAL',
                      icon: Icons.schedule,
                      iconColor: AppColors.primary,
                      value: '${_result.totalYears} anos',
                      valueColor: AppColors.primary,
                      subtitle: '${_result.totalMonths} aportes mensais programados',
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
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flash_on, color: AppColors.amberAccent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ponto de Inflexão dos Juros (No ${_result.inflectionYear}º ano)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aos ${curAge + _result.inflectionYear!} anos, os juros mensais gerados pelo seu patrimônio passarão a ser maiores do que o seu próprio aporte do bolso. Nesse momento, a curva de crescimento exponencial acelera significativamente.',
                        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, height: 1.4),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.secondary, fontSize: 10, letterSpacing: 0.8)),
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
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AposentaFácil • Planejador de Independência Financeira',
                  style: TextStyle(color: AppColors.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Ferramenta para fins educacionais baseada em matemática de juros compostos e retirada segura.',
                  style: TextStyle(color: AppColors.secondary, fontSize: 10),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _showMethodologyModal,
                child: const Text('Metodologia', style: TextStyle(color: AppColors.tertiary, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 16),
              const Text('GitHub: rodrigo-gh/pos-ci-cd-aposenta-facil', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontFamily: 'monospace')),
            ],
          ),
        ],
      ),
    );
  }
}
