import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MethodologyDialog extends StatelessWidget {
  const MethodologyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const MethodologyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AlertDialog(
      backgroundColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: colors.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Premissas e Metodologia Financeira',
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection(
              title: '1. Viver de Renda Perpétua (Safe Withdrawal)',
              description:
                  'O modelo calcula o montante necessário para que os juros reais mensais cubram integralmente o seu padrão de vida, preservando 100% do capital principal intacto.',
              colors: colors,
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: '2. Taxa Real (Acima da Inflação)',
              description:
                  'Todas as taxas são reais (descontadas da inflação). Isso significa que os valores apresentados têm o mesmo poder de compra de hoje, garantindo previsibilidade.',
              colors: colors,
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: '3. Fórmula do Aporte Mensal (PMT)',
              description:
                  'Utiliza o cálculo padrão de anuidade postcipada: PMT = [ (P_alvo - FV_inicial) * i ] / [ (1 + i)^n - 1 ].',
              colors: colors,
              isMonospace: true,
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: '4. Patrimônio Inicial e Efeito Tempo',
              description:
                  'Em prazos longos (30 a 40 anos), os juros compostos multiplicam o capital inicial em várias vezes seu poder de compra real. Caso o saldo inicial sozinho atinja a meta no prazo, o aporte necessário é R\$ 0,00, e o simulador indica a idade exata de autossustentabilidade e oportunidades de antecipação.',
              colors: colors,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Entendido',
            style: TextStyle(color: colors.tertiary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required FinancialPalette colors,
    bool isMonospace = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurfaceVariant,
            fontFamily: isMonospace ? 'monospace' : null,
          ),
        ),
      ],
    );
  }
}
