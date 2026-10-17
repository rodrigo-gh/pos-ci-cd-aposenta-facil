import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'methodology_dialog.dart';

class HeaderBar extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final VoidCallback onCopySummary;

  const HeaderBar({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
    required this.onCopySummary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

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
              // Logo e Marca
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                      children: [
                        const TextSpan(text: 'Aposenta'),
                        TextSpan(
                          text: 'Fácil',
                          style: TextStyle(color: colors.tertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Ações: Alternador de Tema + Metodologia + Copiar Resumo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão de Tema Claro / Escuro
                  InkWell(
                    onTap: onToggleTheme,
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
                            isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            size: 16,
                            color: isDarkMode ? colors.amberAccent : colors.primary,
                          ),
                          if (screenWidth >= 640) ...[
                            const SizedBox(width: 6),
                            Text(
                              isDarkMode ? 'Claro' : 'Escuro',
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
                    onPressed: () => MethodologyDialog.show(context),
                    icon: Icon(Icons.help_outline, size: 16, color: colors.onSurfaceVariant),
                    label: Text(
                      'Metodologia',
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.outlineVariant),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onCopySummary,
                    icon: Icon(Icons.copy, size: 14, color: colors.onTertiary),
                    label: Text(
                      'Copiar Resumo',
                      style: TextStyle(
                        color: colors.onTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
}
