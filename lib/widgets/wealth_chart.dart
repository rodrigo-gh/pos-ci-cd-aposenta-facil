import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class WealthEvolutionChart extends StatefulWidget {
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
  State<WealthEvolutionChart> createState() => _WealthEvolutionChartState();
}

class _WealthEvolutionChartState extends State<WealthEvolutionChart> {
  bool _showTable = false;
  int? _hoveredIndex;

  void _updateHoverFromPosition(Offset local) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null && widget.projection.isNotEmpty) {
      const leftMargin = 55.0;
      final plotW = box.size.width - leftMargin - 40;
      if (local.dx >= leftMargin && plotW > 0) {
        final ratio = ((local.dx - leftMargin) / plotW).clamp(0.0, 1.0);
        final index = (ratio * (widget.projection.length - 1)).round();
        if (_hoveredIndex != index) {
          setState(() => _hoveredIndex = index);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: colors.cardShadow,
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
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
                    'Evolução Patrimonial ao Longo do Tempo',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Projeção de acumulação: valor aportado vs. rentabilidade de juros compostos',
                    style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
              // View toggle buttons (Gráfico vs Tabela)
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outlineVariant),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewButton(
                      colors: colors,
                      icon: Icons.show_chart,
                      label: 'Gráfico',
                      isSelected: !_showTable,
                      onTap: () => setState(() => _showTable = false),
                    ),
                    _buildViewButton(
                      colors: colors,
                      icon: Icons.table_chart_outlined,
                      label: 'Tabela',
                      isSelected: _showTable,
                      onTap: () => setState(() => _showTable = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!_showTable) ...[
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem(colors.primary, 'Total Investido (Do seu bolso)'),
                _buildLegendItem(colors.tertiary, 'Patrimônio Líquido Acumulado'),
              ],
            ),
            const SizedBox(height: 16),
            // Custom Painted Vector Chart (suporta hover no desktop e toque/arraste no mobile)
            SizedBox(
              height: 280,
              width: double.infinity,
              child: GestureDetector(
                onTapDown: (details) => _updateHoverFromPosition(details.localPosition),
                onPanUpdate: (details) => _updateHoverFromPosition(details.localPosition),
                child: MouseRegion(
                  onHover: (event) => _updateHoverFromPosition(event.localPosition),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: CustomPaint(
                    painter: _WealthChartPainter(
                      projection: widget.projection,
                      targetWealth: widget.targetWealth,
                      inflectionYear: widget.inflectionYear,
                      currentAge: widget.currentAge,
                      targetAge: widget.targetAge,
                      hoveredIndex: _hoveredIndex,
                      palette: colors,
                    ),
                    child: Container(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_hoveredIndex != null && _hoveredIndex! < widget.projection.length)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.tertiary.withValues(alpha: 0.4)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Aos ${widget.projection[_hoveredIndex!].age} anos (${widget.projection[_hoveredIndex!].yearOffset} anos de aportes):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: colors.onSurface),
                    ),
                    Text(
                      'Patrimônio: ${CurrencyFormatter.format(widget.projection[_hoveredIndex!].totalWealth)}  •  Renda: ${CurrencyFormatter.format(widget.projection[_hoveredIndex!].monthlyPassiveIncome)}/mês',
                      style: TextStyle(color: colors.tertiary, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    'Ponto de Partida: ${CurrencyFormatter.format(widget.projection.isNotEmpty ? widget.projection.first.totalWealth : 0)}',
                    style: TextStyle(color: colors.secondary, fontSize: 11, fontFamily: 'monospace'),
                  ),
                  Text(
                    'Toque ou passe o mouse na curva para inspecionar cada ano',
                    style: TextStyle(color: colors.secondary, fontSize: 11),
                  ),
                ],
              ),
          ] else ...[
            // TABLE VIEW (com scroll horizontal suave para dispositivos móveis)
            SizedBox(
              height: 280,
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: math.max(MediaQuery.of(context).size.width - 64, 560.0),
                    child: Table(
                      border: TableBorder(
                        horizontalInside: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5), width: 1),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(1.3),
                        1: FlexColumnWidth(2.0),
                        2: FlexColumnWidth(2.2),
                        3: FlexColumnWidth(2.0),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: colors.surfaceContainerHigh),
                          children: [
                            _buildTableHeaderCell('Idade', colors),
                            _buildTableHeaderCell('Total Investido', colors),
                            _buildTableHeaderCell('Patrimônio Total', colors),
                            _buildTableHeaderCell('Renda Passiva/Mês', colors),
                          ],
                        ),
                        for (final point in widget.projection)
                          TableRow(
                            children: [
                              _buildTableCell('${point.age} anos (${point.yearOffset}º ano)', colors, isBold: point.yearOffset == widget.inflectionYear),
                              _buildTableCell(CurrencyFormatter.format(point.totalDeposited), colors),
                              _buildTableCell(CurrencyFormatter.format(point.totalWealth), colors, textColor: colors.tertiary, isBold: true),
                              _buildTableCell(CurrencyFormatter.format(point.monthlyPassiveIncome), colors),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required FinancialPalette colors,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? colors.surfaceContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: colors.outlineVariant) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? colors.onSurface : colors.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colors.onSurface : colors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text, FinancialPalette colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: colors.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, FinancialPalette colors, {Color? textColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? colors.onSurface,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
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
  final int? hoveredIndex;
  final FinancialPalette palette;

  _WealthChartPainter({
    required this.projection,
    required this.targetWealth,
    required this.inflectionYear,
    required this.currentAge,
    required this.targetAge,
    required this.palette,
    this.hoveredIndex,
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
    maxVal *= 1.08;

    final gridPaint = Paint()
      ..color = palette.chartGrid
      ..strokeWidth = 1.0;

    const int steps = 4;
    for (int i = 0; i <= steps; i++) {
      final double y = topMargin + (plotHeight * (steps - i) / steps);
      final double val = maxVal * i / steps;

      _drawDashedLine(canvas, Offset(leftMargin, y), Offset(size.width, y), gridPaint);

      final label = CurrencyFormatter.formatShort(val);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: palette.secondary, fontSize: 10, fontFamily: 'monospace'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 8, y - tp.height / 2));
    }

    final depositsPath = Path();
    final depositsFillPath = Path();
    final wealthPath = Path();
    final wealthFillPath = Path();

    final int totalPoints = projection.length;
    double getX(int index) => leftMargin + (plotWidth * index / (totalPoints - 1));
    double getY(double val) => topMargin + plotHeight * (1.0 - (val / maxVal).clamp(0.0, 1.0));

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

    final depositsFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.primary.withValues(alpha: palette.isDark ? 0.18 : 0.12),
          palette.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(leftMargin, topMargin, plotWidth, plotHeight));
    canvas.drawPath(depositsFillPath, depositsFillPaint);

    final depositsStrokePaint = Paint()
      ..color = palette.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(depositsPath, depositsStrokePaint);

    final wealthFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.tertiary.withValues(alpha: palette.isDark ? 0.35 : 0.18),
          palette.tertiary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(leftMargin, topMargin, plotWidth, plotHeight));
    canvas.drawPath(wealthFillPath, wealthFillPaint);

    final wealthStrokePaint = Paint()
      ..color = palette.tertiary
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(wealthPath, wealthStrokePaint);

    // Milestones
    final startX = getX(0);
    final startY = getY(projection.first.totalWealth);
    canvas.drawCircle(Offset(startX, startY), 4.5, Paint()..color = palette.tertiary);
    _drawXLabel(canvas, '$currentAge anos', startX, size.height - bottomMargin + 6);

    final endX = getX(totalPoints - 1);
    final endY = getY(projection.last.totalWealth);
    canvas.drawCircle(Offset(endX, endY), 8.0, Paint()..color = palette.tertiary.withValues(alpha: 0.3));
    canvas.drawCircle(Offset(endX, endY), 5.0, Paint()..color = palette.tertiary);
    _drawXLabel(canvas, '$targetAge anos', endX, size.height - bottomMargin + 6, isHighlight: true);

    final targetTagTp = TextPainter(
      text: TextSpan(
        text: 'Meta 🎯',
        style: TextStyle(
          color: palette.tertiary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    targetTagTp.paint(canvas, Offset(endX - targetTagTp.width, math.max(0, endY - 18)));

    if (inflectionYear != null && inflectionYear! > 0 && inflectionYear! < totalPoints) {
      final inflX = getX(inflectionYear!);
      final inflY = getY(projection[inflectionYear!].totalWealth);

      canvas.drawCircle(Offset(inflX, inflY), 4.0, Paint()..color = palette.tertiary);

      final inflTp = TextPainter(
        text: TextSpan(
          text: 'Inflexão ⚡',
          style: TextStyle(
            color: palette.tertiary,
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

    // Hover indicator line & dot
    if (hoveredIndex != null && hoveredIndex! >= 0 && hoveredIndex! < totalPoints) {
      final hX = getX(hoveredIndex!);
      final hY = getY(projection[hoveredIndex!].totalWealth);

      canvas.drawLine(
        Offset(hX, topMargin),
        Offset(hX, topMargin + plotHeight),
        Paint()
          ..color = palette.chartHoverLine
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
      );

      canvas.drawCircle(Offset(hX, hY), 6.0, Paint()..color = palette.onSurface);
      canvas.drawCircle(Offset(hX, hY), 4.0, Paint()..color = palette.tertiary);
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
          color: isHighlight ? palette.tertiary : palette.secondary,
          fontSize: 10,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y));
  }

  @override
  bool shouldRepaint(covariant _WealthChartPainter oldDelegate) {
    return oldDelegate.projection != projection ||
        oldDelegate.targetWealth != targetWealth ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.palette.isDark != palette.isDark;
  }
}
