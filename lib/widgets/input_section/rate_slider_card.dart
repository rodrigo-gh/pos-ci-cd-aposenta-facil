import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';

class RateSliderCard extends StatelessWidget {
  final double monthlyRate;
  final String selectedPreset;
  final ValueChanged<double> onRateChanged;
  final void Function(String preset, double rate) onPresetSelected;

  const RateSliderCard({
    super.key,
    required this.monthlyRate,
    required this.selectedPreset,
    required this.onRateChanged,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final annualRate = CurrencyFormatter.toAnnualRate(monthlyRate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Taxa Real de Retorno Estimada',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.tertiaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(monthlyRate * 100).toStringAsFixed(2).replaceAll('.', ',')}% a.m.',
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
          'Equivalente a ≈ ${annualRate.toStringAsFixed(2)}% ao ano (acima da inflação)',
          style: TextStyle(color: colors.secondary, fontSize: 11),
        ),
        Slider(
          value: monthlyRate.clamp(AppConstants.minSliderRate, AppConstants.maxSliderRate),
          min: AppConstants.minSliderRate,
          max: AppConstants.maxSliderRate,
          divisions: AppConstants.sliderDivisions,
          activeColor: colors.tertiary,
          inactiveColor: colors.surfaceContainerHighest,
          onChanged: onRateChanged,
        ),
        Row(
          children: [
            Expanded(
              child: _buildPresetButton(
                title: 'Conservador',
                subtitle: '0,35% a.m.',
                presetKey: 'conservador',
                rate: AppConstants.conservativeRate,
                colors: colors,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPresetButton(
                title: 'Moderado',
                subtitle: '0,45% a.m.',
                presetKey: 'moderado',
                rate: AppConstants.moderateRate,
                colors: colors,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPresetButton(
                title: 'Agressivo',
                subtitle: '0,55% a.m.',
                presetKey: 'agressivo',
                rate: AppConstants.aggressiveRate,
                colors: colors,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton({
    required String title,
    required String subtitle,
    required String presetKey,
    required double rate,
    required FinancialPalette colors,
  }) {
    final isSelected = selectedPreset == presetKey;
    return InkWell(
      onTap: () => onPresetSelected(presetKey, rate),
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
}
