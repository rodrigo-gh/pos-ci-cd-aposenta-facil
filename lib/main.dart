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

class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
  // Input Controllers
  final TextEditingController _currentAgeController = TextEditingController(text: '28');
  final TextEditingController _targetAgeController = TextEditingController(text: '55');
  final TextEditingController _desiredIncomeController = TextEditingController(text: '12.000,00');
  final TextEditingController _initialWealthController = TextEditingController(text: '85.000,00');

  bool _hasInitialWealth = true;
  double _monthlyRate = 0.006; // 0.60% a.m.
  String _selectedPreset = 'moderado';

  late FinancialResult _result;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _calculate();
  }

  @override
  void dispose() {
    _currentAgeController.dispose();
    _targetAgeController.dispose();
    _desiredIncomeController.dispose();
    _initialWealthController.dispose();
    _animController.dispose();
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

  void _calculate({bool animate = false}) {
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

    if (animate) {
      _animController.forward().then((_) => _animController.reverse());
    }
  }

  void _setPreset(String preset, double rate) {
    setState(() {
      _selectedPreset = preset;
      _monthlyRate = rate;
    });
    _calculate();
  }

  void _resetForm() {
    setState(() {
      _currentAgeController.text = '28';
      _targetAgeController.text = '55';
      _desiredIncomeController.text = '12.000,00';
      _hasInitialWealth = true;
      _initialWealthController.text = '85.000,00';
      _monthlyRate = 0.006;
      _selectedPreset = 'moderado';
    });
    _calculate(animate: true);
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
    final showNavPills = screenWidth >= 1200;

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
              // Brand Logo
              Flexible(
                child: Row(
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: AppColors.onTertiaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Navigation Pills
              if (showNavPills)
                Row(
                  children: [
                    _buildNavPill('Calculadora', isSelected: true),
                    const SizedBox(width: 4),
                    _buildNavPill('Simulador FIRE'),
                    const SizedBox(width: 4),
                    _buildNavPill('Estratégias de Renda'),
                    const SizedBox(width: 4),
                    _buildNavPill('Relatórios'),
                  ],
                ),
              // Right utilities
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_money, size: 14, color: AppColors.onSurfaceVariant),
                        SizedBox(width: 2),
                        Text('BRL (R\$)', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: const Icon(Icons.dark_mode, size: 16, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 18, color: AppColors.onPrimary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavPill(String title, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceContainerHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildHeroTitle(bool isDesktop) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 24,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Simulação Inteligente v2.4',
                        style: TextStyle(
                          color: AppColors.onTertiaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'FIRE • Rendimento Real Líquido',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: isDesktop ? 36 : 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.onSurface,
                ),
                children: const [
                  TextSpan(text: 'Planeje sua '),
                  TextSpan(
                    text: 'Liberdade Financeira',
                    style: TextStyle(color: AppColors.tertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Algoritmo atuarial com ajuste de poder de compra contínuo. Descubra com precisão matemática o dia da sua independência.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
        // Badge CVM
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: AppColors.tertiary, size: 20),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IPCA + Cupom Real',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  Text(
                    'Base Histórica CVM 2024',
                    style: TextStyle(fontSize: 10, color: AppColors.secondary, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ],
          ),
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
                    'Seus Dados & Metas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                  ),
                ],
              ),
              const Text(
                'PARÂMETROS',
                style: TextStyle(color: AppColors.secondary, fontSize: 10, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Ages row
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Idade Atual',
                  badge: '${_currentAgeController.text} anos',
                  controller: _currentAgeController,
                  icon: Icons.hourglass_top,
                  onChanged: (v) => _calculate(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: 'Idade Aposentadoria',
                  badge: '${_targetAgeController.text} anos',
                  controller: _targetAgeController,
                  icon: Icons.flag,
                  onChanged: (v) => _calculate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Desired Monthly Income
          _buildCurrencyField(
            label: 'Renda mensal desejada (hoje)',
            tag: 'Poder de compra preservado',
            controller: _desiredIncomeController,
            suffix: '/ mês',
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
                      Icon(Icons.account_balance_wallet, color: AppColors.secondary, size: 20),
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
                              'Aporte inicial impulsiona a curva',
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
          ],
          const SizedBox(height: 24),
          // Monthly Rate Slider & Presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Taxa de Rendimento Real Mensal',
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                '≈ ${((math.pow(1 + _monthlyRate, 12) - 1) * 100).toStringAsFixed(2)}% a.a. real',
                style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontFamily: 'monospace'),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insights, color: AppColors.tertiary, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Média Histórica SWR',
                    style: TextStyle(color: AppColors.tertiary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
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
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _calculate(animate: true),
                  icon: const Icon(Icons.bolt, color: AppColors.onTertiary),
                  label: const Text(
                    'Calcular Meu Futuro',
                    style: TextStyle(color: AppColors.onTertiary, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.outlineVariant),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Limpar Dados', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Methodology Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.functions, color: AppColors.primary, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'METODOLOGIA SAFE WITHDRAWAL',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Patrimônio = Renda / Taxa Real Mensal. Amortização calculada via anuidade perpétua descontada com inflação zero assumida nos fluxos futuros.',
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String badge,
    required TextEditingController controller,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 4,
          runSpacing: 2,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
            Text(badge, style: const TextStyle(fontSize: 11, color: AppColors.tertiary, fontFamily: 'monospace')),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.secondary, size: 18),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Widget _buildCurrencyField({
    required String label,
    String? tag,
    required TextEditingController controller,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 4,
          runSpacing: 2,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
            if (tag != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(color: AppColors.tertiary, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HERO CARD
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
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Meta Alcançável aos ${_targetAgeController.text} anos',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Confiança Estatística: 98%',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'VOCÊ PRECISA INVESTIR POR MÊS',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Wrap(
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
              ),
              const SizedBox(height: 6),
              const Text(
                'Valor constante em termos reais. Não precisa aumentar acima da inflação.',
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
                      icon: Icons.savings,
                      iconColor: AppColors.tertiary,
                      value: _currencyFormat.format(_result.targetWealth),
                      subtitle: 'Para renda perpétua de R\$ ${_desiredIncomeController.text}/mês',
                    ),
                    _buildSubCard(
                      title: 'TEMPO ATÉ A LIBERDADE',
                      icon: Icons.schedule,
                      iconColor: AppColors.primary,
                      value: '${_result.totalYears} anos',
                      valueColor: AppColors.primary,
                      subtitle: 'Equivalente a ${_result.totalMonths} meses de acumulação',
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
        // WEALTH CHART
        WealthEvolutionChart(
          projection: _result.projection,
          targetWealth: _result.targetWealth,
          inflectionYear: _result.inflectionYear,
          currentAge: int.tryParse(_currentAgeController.text) ?? 28,
          targetAge: int.tryParse(_targetAgeController.text) ?? 55,
        ),
        const SizedBox(height: 24),
        // SNOWBALL EFFECT ADVISORY BOX
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
                child: const Icon(Icons.lightbulb, color: AppColors.amberAccent, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        const Text(
                          'O Efeito Bola de Neve (Snowball Effect)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Análise Comportamental',
                            style: TextStyle(color: AppColors.tertiary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, height: 1.5),
                        children: [
                          const TextSpan(text: 'A partir do '),
                          TextSpan(
                            text: '${_result.inflectionYear ?? 10}º ano',
                            style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ', os rendimentos mensais passam a superar seus aportes próprios diretos. Ao reinvestir 100% dos dividendos recebidos nesse ciclo, você pode antecipar a sua independência financeira ou elevar sua renda mensal vitalícia!',
                          ),
                        ],
                      ),
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
                  'AposentaFácil • Tecnologia para Liberdade Financeira',
                  style: TextStyle(color: AppColors.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Aviso: As simulações disponibilizadas possuem fins exclusivamente educacionais e não constituem recomendação oficial de investimento.',
                  style: TextStyle(color: AppColors.secondary, fontSize: 10),
                ),
              ],
            ),
          ),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Segurança & Privacidade', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              SizedBox(width: 16),
              Text('Termos de Uso', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
