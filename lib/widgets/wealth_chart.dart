import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';

class WealthEvolutionChart extends StatelessWidget {
  final List<YearlyDataPoint> projection;
  final double targetWealth;
  final int? inflectionYear;
  final int currentAge;
  final int targetAge;

  const WealthEvolutionChart({
    super.key,
    required this.projection,
    required this.targetWealth,
    required this.inflectionYear,
    required this.currentAge,
    required this.targetAge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Curva de Evolução Patrimonial',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Projeção exponencial: Aportes vs. Patrimônio Total',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Total Aportado',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Patrimônio Líquido',
                    style: TextStyle(
                      color: AppColors.tertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart Canvas
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
            child: CustomPaint(
              size: Size.infinite,
              painter: _WealthChartPainter(
                projection: projection,
                targetWealth: targetWealth,
                inflectionYear: inflectionYear,
                currentAge: currentAge,
                targetAge: targetAge,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                'Ponto de Partida: R\$ ${(projection.isNotEmpty ? projection.first.totalWealth : 0).toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontFamily: 'monospace'),
              ),
              const Text(
                'Juros compostos acelerando o topo da curva',
                style: TextStyle(color: AppColors.tertiary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WealthChartPainter extends CustomPainter {
  final List<YearlyDataPoint> projection;
  final double targetWealth;
  final int? inflectionYear;
  final int currentAge;
  final int targetAge;

  _WealthChartPainter({
    required this.projection,
    required this.targetWealth,
    required this.inflectionYear,
    required this.currentAge,
    required this.targetAge,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (projection.isEmpty) return;

    const double leftMargin = 55.0;
    const double bottomMargin = 25.0;
    const double topMargin = 20.0;
    final double plotWidth = size.width - leftMargin;
    final double plotHeight = size.height - bottomMargin - topMargin;

    double maxVal = targetWealth > 0 ? targetWealth : 100000;
    for (final p in projection) {
      if (p.totalWealth > maxVal) maxVal = p.totalWealth;
      if (p.totalDeposited > maxVal) maxVal = p.totalDeposited;
    }
    maxVal *= 1.08; // small headroom

    // Draw horizontal dashed grid lines & Y labels
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant
      ..strokeWidth = 1.0;

    const int steps = 4;
    for (int i = 0; i <= steps; i++) {
      final double y = topMargin + (plotHeight * (steps - i) / steps);
      final double val = maxVal * i / steps;

      _drawDashedLine(canvas, Offset(leftMargin, y), Offset(size.width, y), gridPaint);

      final label = _formatShortCurrency(val);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: AppColors.secondary, fontSize: 10, fontFamily: 'monospace'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 8, y - tp.height / 2));
    }

    // Build Paths for Deposits and Wealth
    final depositsPath = Path();
    final depositsFillPath = Path();
    final wealthPath = Path();
    final wealthFillPath = Path();

    final int totalPoints = projection.length;
    double getX(int index) => leftMargin + (plotWidth * index / (totalPoints - 1));
    double getY(double val) => topMargin + plotHeight * (1.0 - (val / maxVal).clamp(0.0, 1.0));

    // Deposits path
    for (int i = 0; i < totalPoints; i++) {
      final double x = getX(i);
      final double y = getY(projection[i].totalDeposited);
      if (i == 0) {
        depositsPath.moveTo(x, y);
        depositsFillPath.moveTo(x, topMargin + plotHeight);
        depositsFillPath.lineTo(x, y);
      } else {
        depositsPath.lineTo(x, y);
        depositsFillPath.lineTo(x, y);
      }
    }
    depositsFillPath.lineTo(getX(totalPoints - 1), topMargin + plotHeight);
    depositsFillPath.close();

    // Wealth path (smooth quadratic / cubic)
    for (int i = 0; i < totalPoints; i++) {
      final double x = getX(i);
      final double y = getY(projection[i].totalWealth);
      if (i == 0) {
        wealthPath.moveTo(x, y);
        wealthFillPath.moveTo(x, topMargin + plotHeight);
        wealthFillPath.lineTo(x, y);
      } else {
        final double prevX = getX(i - 1);
        final double prevY = getY(projection[i - 1].totalWealth);
        final double midX = (prevX + x) / 2;
        wealthPath.cubicTo(midX, prevY, midX, y, x, y);
        wealthFillPath.cubicTo(midX, prevY, midX, y, x, y);
      }
    }
    wealthFillPath.lineTo(getX(totalPoints - 1), topMargin + plotHeight);
    wealthFillPath.close();

    // Fill Deposits
    final depositsFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.18),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(leftMargin, topMargin, plotWidth, plotHeight));
    canvas.drawPath(depositsFillPath, depositsFillPaint);

    // Stroke Deposits
    final depositsStrokePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(depositsPath, depositsStrokePaint);

    // Fill Wealth
    final wealthFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.tertiary.withValues(alpha: 0.35),
          AppColors.tertiary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(leftMargin, topMargin, plotWidth, plotHeight));
    canvas.drawPath(wealthFillPath, wealthFillPaint);

    // Stroke Wealth
    final wealthStrokePaint = Paint()
      ..color = AppColors.tertiary
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(wealthPath, wealthStrokePaint);

    // Milestone: Start Dot
    final startX = getX(0);
    final startY = getY(projection.first.totalWealth);
    canvas.drawCircle(Offset(startX, startY), 4.5, Paint()..color = AppColors.tertiary);
    _drawXLabel(canvas, '$currentAge anos', startX, size.height - bottomMargin + 6);

    // Milestone: End / Target Dot
    final endX = getX(totalPoints - 1);
    final endY = getY(projection.last.totalWealth);
    // Outer halo
    canvas.drawCircle(Offset(endX, endY), 8.0, Paint()..color = AppColors.tertiary.withValues(alpha: 0.3));
    canvas.drawCircle(Offset(endX, endY), 5.0, Paint()..color = AppColors.tertiary);
    _drawXLabel(canvas, '$targetAge anos', endX, size.height - bottomMargin + 6, isHighlight: true);

    // Tag above target dot
    final targetTagTp = TextPainter(
      text: const TextSpan(
        text: 'Meta 🎯',
        style: TextStyle(
          color: AppColors.tertiary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    targetTagTp.paint(canvas, Offset(endX - targetTagTp.width, math.max(0, endY - 18)));

    // Milestone: Inflection Dot (if any)
    if (inflectionYear != null && inflectionYear! > 0 && inflectionYear! < totalPoints) {
      final inflX = getX(inflectionYear!);
      final inflY = getY(projection[inflectionYear!].totalWealth);

      canvas.drawCircle(Offset(inflX, inflY), 4.0, Paint()..color = AppColors.tertiary);

      final inflTp = TextPainter(
        text: const TextSpan(
          text: 'Inflexão ⚡',
          style: TextStyle(
            color: AppColors.tertiary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      inflTp.paint(canvas, Offset(inflX - inflTp.width / 2, inflY - 16));

      final inflAge = currentAge + inflectionYear!;
      _drawXLabel(canvas, '$inflAge anos', inflX, size.height - bottomMargin + 6);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 4;
    const double dashSpace = 4;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(Offset(startX, p1.dy), Offset(math.min(startX + dashWidth, p2.dx), p1.dy), paint);
      startX += dashWidth + dashSpace;
    }
  }

  void _drawXLabel(Canvas canvas, String text, double x, double y, {bool isHighlight = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isHighlight ? AppColors.tertiary : AppColors.secondary,
          fontSize: 10,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y));
  }

  String _formatShortCurrency(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(0)}k';
    } else {
      return 'R\$ ${value.toStringAsFixed(0)}';
    }
  }

  @override
  bool shouldRepaint(covariant _WealthChartPainter oldDelegate) {
    return oldDelegate.projection != projection || oldDelegate.targetWealth != targetWealth;
  }
}
