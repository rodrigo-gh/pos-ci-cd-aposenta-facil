import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CurrencyInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final ValueChanged<String> onChanged;

  const CurrencyInputField({
    super.key,
    required this.label,
    required this.controller,
    this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colors.onSurface,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, top: 14, right: 8),
              child: Text(
                'R\$',
                style: TextStyle(color: colors.secondary, fontWeight: FontWeight.bold),
              ),
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
}
