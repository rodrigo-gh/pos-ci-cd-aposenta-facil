import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../models/financial_plan.dart';
import '../theme/app_theme.dart';

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
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

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
                    'Evolução Patrimonial ao Longo do Tempo',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Projeção de acumulação: valor aportado vs. rentabilidade de juros compostos',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
              // View toggle buttons (Gráfico vs Tabela)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewButton(
                      icon: Icons.show_chart,
                      label: 'Gráfico',
                      isSelected: !_showTable,
                      onTap: () => setState(() => _showTable = false),
                    ),
                    _buildViewButton(
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
              children: [
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
                    const Text('Total Investido', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      'Patrimônio Líquido Acumulado',
                      style: TextStyle(color: AppColors.tertiary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Canvas with MouseRegion for interactive hover
            MouseRegion(
              onHover: (event) {
                final RenderBox? box = context.findRenderObject() as RenderBox?;
                if (box != null && widget.projection.isNotEmpty) {
                  const leftMargin = 55.0;
                  final plotWidth = box.size.width - 40 - leftMargin;
                  final localX = event.localPosition.dx - leftMargin;
                  if (localX >= 0 && localX <= plotWidth && plotWidth > 0) {
                    final index = ((localX / plotWidth) * (widget.projection.length - 1)).round();
                    setState(() {
                      _hoveredIndex = index.clamp(0, widget.projection.length - 1);
                    });
                  }
                }
              },
              onExit: (_) => setState(() => _hoveredIndex = null),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _WealthChartPainter(
                    projection: widget.projection,
                    targetWealth: widget.targetWealth,
                    inflectionYear: widget.inflectionYear,
                    currentAge: widget.currentAge,
                    targetAge: widget.targetAge,
                    hoveredIndex: _hoveredIndex,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_hoveredIndex != null && _hoveredIndex! < widget.projection.length)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aos ${widget.projection[_hoveredIndex!].age} anos ($_hoveredIndex anos de aportes):',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      'Patrimônio: ${_currencyFormat.format(widget.projection[_hoveredIndex!].totalWealth)}  |  Renda mensal: ${_currencyFormat.format(widget.projection[_hoveredIndex!].monthlyPassiveIncome)}/mês',
                      style: const TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
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
                    'Ponto de Partida: ${_currencyFormat.format(widget.projection.isNotEmpty ? widget.projection.first.totalWealth : 0)}',
                    style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontFamily: 'monospace'),
                  ),
                  const Text(
                    'Passe o mouse na curva para inspecionar cada ano',
                    style: TextStyle(color: AppColors.secondary, fontSize: 11),
                  ),
                ],
              ),
          ] else ...[
            // TABLE VIEW
            SizedBox(
              height: 280,
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5), width: 1),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(2.0),
                    2: FlexColumnWidth(2.2),
                    3: FlexColumnWidth(2.0),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh),
                      children: [
                        _buildTableHeaderCell('Idade'),
                        _buildTableHeaderCell('Total Investido'),
                        _buildTableHeaderCell('Patrimônio Total'),
                        _buildTableHeaderCell('Renda Passiva/Mês'),
                      ],
                    ),
                    for (final point in widget.projection)
                      TableRow(
                        children: [
                          _buildTableCell('${point.age} anos (${point.yearOffset}º ano)', isBold: point.yearOffset == widget.inflectionYear),
                          _buildTableCell(_currencyFormat.format(point.totalDeposited)),
                          _buildTableCell(_currencyFormat.format(point.totalWealth), textColor: AppColors.tertiary, isBold: true),
                          _buildTableCell(_currencyFormat.format(point.monthlyPassiveIncome)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildTableCell(String text, {Color? textColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? AppColors.onSurface,
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

  _WealthChartPainter({
    required this.projection,
    required this.targetWealth,
    required this.inflectionYear,
    required this.currentAge,
    required this.targetAge,
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
          AppColors.primary.withValues(alpha: 0.18),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(leftMargin, topMargin, plotWidth, plotHeight));
    canvas.drawPath(depositsFillPath, depositsFillPaint);

    final depositsStrokePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(depositsPath, depositsStrokePaint);

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

    final wealthStrokePaint = Paint()
      ..color = AppColors.tertiary
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(wealthPath, wealthStrokePaint);

    // Milestones
    final startX = getX(0);
    final startY = getY(projection.first.totalWealth);
    canvas.drawCircle(Offset(startX, startY), 4.5, Paint()..color = AppColors.tertiary);
    _drawXLabel(canvas, '$currentAge anos', startX, size.height - bottomMargin + 6);

    final endX = getX(totalPoints - 1);
    final endY = getY(projection.last.totalWealth);
    canvas.drawCircle(Offset(endX, endY), 8.0, Paint()..color = AppColors.tertiary.withValues(alpha: 0.3));
    canvas.drawCircle(Offset(endX, endY), 5.0, Paint()..color = AppColors.tertiary);
    _drawXLabel(canvas, '$targetAge anos', endX, size.height - bottomMargin + 6, isHighlight: true);

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

    // Hover indicator line & dot
    if (hoveredIndex != null && hoveredIndex! >= 0 && hoveredIndex! < totalPoints) {
      final hX = getX(hoveredIndex!);
      final hY = getY(projection[hoveredIndex!].totalWealth);

      canvas.drawLine(
        Offset(hX, topMargin),
        Offset(hX, topMargin + plotHeight),
        Paint()
          ..color = AppColors.onSurface.withValues(alpha: 0.4)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
      );

      canvas.drawCircle(Offset(hX, hY), 6.0, Paint()..color = AppColors.onSurface);
      canvas.drawCircle(Offset(hX, hY), 4.0, Paint()..color = AppColors.tertiary);
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
    return oldDelegate.projection != projection ||
        oldDelegate.targetWealth != targetWealth ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}
