import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import 'age_stepper_card.dart';
import 'currency_input_field.dart';
import 'rate_slider_card.dart';

class SimulationForm extends StatelessWidget {
  final TextEditingController currentAgeController;
  final TextEditingController targetAgeController;
  final TextEditingController desiredIncomeController;
  final TextEditingController initialWealthController;
  final bool hasInitialWealth;
  final double monthlyRate;
  final String selectedPreset;
  final VoidCallback onCalculate;
  final void Function(int delta, TextEditingController controller) onAdjustAge;
  final ValueChanged<bool> onToggleInitialWealth;
  final ValueChanged<double> onSelectIncome;
  final ValueChanged<double> onSelectInitialWealth;
  final ValueChanged<double> onRateChanged;
  final void Function(String preset, double rate) onSelectPreset;
  final VoidCallback onReset;

  const SimulationForm({
    super.key,
    required this.currentAgeController,
    required this.targetAgeController,
    required this.desiredIncomeController,
    required this.initialWealthController,
    required this.hasInitialWealth,
    required this.monthlyRate,
    required this.selectedPreset,
    required this.onCalculate,
    required this.onAdjustAge,
    required this.onToggleInitialWealth,
    required this.onSelectIncome,
    required this.onSelectInitialWealth,
    required this.onRateChanged,
    required this.onSelectPreset,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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
                style: TextStyle(
                  color: colors.secondary.withValues(alpha: 0.8),
                  fontSize: 10,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Ages with stepper buttons
          Row(
            children: [
              Expanded(
                child: AgeStepperCard(
                  label: 'Idade Atual',
                  controller: currentAgeController,
                  onDecrease: () => onAdjustAge(-1, currentAgeController),
                  onIncrease: () => onAdjustAge(1, currentAgeController),
                  onChanged: onCalculate,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AgeStepperCard(
                  label: 'Idade Aposentadoria',
                  controller: targetAgeController,
                  onDecrease: () => onAdjustAge(-1, targetAgeController),
                  onIncrease: () => onAdjustAge(1, targetAgeController),
                  onChanged: onCalculate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Desired Monthly Income + Quick Chips
          CurrencyInputField(
            label: 'Renda Mensal Desejada na Aposentadoria',
            controller: desiredIncomeController,
            suffix: '/ mês',
            onChanged: (_) => onCalculate(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: AppConstants.incomeChips.map((amount) {
              return _buildChip(
                CurrencyFormatter.format(amount).replaceAll(',00', ''),
                () => onSelectIncome(amount),
                colors,
              );
            }).toList(),
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
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
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
                  value: hasInitialWealth,
                  activeThumbColor: colors.tertiary,
                  activeTrackColor: colors.tertiaryContainer,
                  onChanged: onToggleInitialWealth,
                ),
              ],
            ),
          ),
          if (hasInitialWealth) ...[
            const SizedBox(height: 12),
            CurrencyInputField(
              label: 'Patrimônio Inicial Atual',
              controller: initialWealthController,
              onChanged: (_) => onCalculate(),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: AppConstants.wealthChips.map((amount) {
                return _buildChip(
                  CurrencyFormatter.format(amount).replaceAll(',00', ''),
                  () => onSelectInitialWealth(amount),
                  colors,
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          // Rate Slider & Presets
          RateSliderCard(
            monthlyRate: monthlyRate,
            selectedPreset: selectedPreset,
            onRateChanged: onRateChanged,
            onPresetSelected: onSelectPreset,
          ),
          const SizedBox(height: 24),
          // Reset action
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onReset,
              icon: Icon(Icons.restart_alt, size: 16, color: colors.onSurfaceVariant),
              label: Text(
                'Restaurar Valores Padrão',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
            ),
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
          style: TextStyle(
            fontSize: 11,
            color: colors.onSurfaceVariant,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
