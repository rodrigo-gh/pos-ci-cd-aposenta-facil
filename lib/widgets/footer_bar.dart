import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import 'methodology_dialog.dart';

class FooterBar extends StatelessWidget {
  const FooterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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
                  '${AppConstants.appName} • ${AppConstants.appTagline}',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ferramenta para fins educacionais baseada em matemática de anuidade e retirada perpétua.',
                  style: TextStyle(color: colors.secondary, fontSize: 10),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => MethodologyDialog.show(context),
                child: Text(
                  'Metodologia',
                  style: TextStyle(
                    color: colors.tertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'GitHub: ${AppConstants.githubRepo}',
                style: TextStyle(
                  color: colors.secondary,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
