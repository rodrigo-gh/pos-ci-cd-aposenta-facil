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
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth >= 1024
            ? 32
            : (screenWidth < 400 ? 10 : 16),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo e Marca
              Flexible(
                fit: FlexFit.loose,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
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
                        child: Icon(
                          Icons.trending_up,
                          color: colors.tertiary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                ),
              ),
              const SizedBox(width: 4),
              // Ações: Alternador de Tema + Metodologia + Copiar Resumo
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão de Tema Claro / Escuro
                    InkWell(
                      onTap: onToggleTheme,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth >= 640 ? 10 : 8,
                          vertical: 7,
                        ),
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
                    const SizedBox(width: 6),
                    // Botão de Metodologia
                    if (screenWidth >= 480)
                      OutlinedButton.icon(
                        onPressed: () => MethodologyDialog.show(context),
                        icon: Icon(Icons.help_outline, size: 16, color: colors.onSurfaceVariant),
                        label: Text(
                          'Metodologia',
                          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.outlineVariant),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      )
                    else
                      IconButton(
                        tooltip: 'Metodologia',
                        onPressed: () => MethodologyDialog.show(context),
                        icon: Icon(Icons.help_outline, size: 18, color: colors.onSurfaceVariant),
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: const EdgeInsets.all(6),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: colors.outlineVariant),
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    // Botão de Copiar Resumo
                    ElevatedButton.icon(
                      onPressed: onCopySummary,
                      icon: Icon(Icons.copy, size: 14, color: colors.onTertiary),
                      label: Text(
                        screenWidth >= 520 ? 'Copiar Resumo' : 'Copiar',
                        style: TextStyle(
                          color: colors.onTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.tertiary,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth >= 480 ? 12 : 8,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
