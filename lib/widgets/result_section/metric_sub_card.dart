import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MetricSubCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final Color? valueColor;
  final String subtitle;

  const MetricSubCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    this.valueColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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
              Text(
                title,
                style: TextStyle(
                  color: colors.secondary,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
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
}
