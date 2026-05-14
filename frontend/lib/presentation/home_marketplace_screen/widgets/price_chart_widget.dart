import 'package:agrilink_app/models/price_point.dart';
import 'package:agrilink_app/services/price_chart_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class PriceChartWidget extends StatefulWidget {
  const PriceChartWidget({super.key});

  @override
  State<PriceChartWidget> createState() => _PriceChartWidgetState();
}

class _PriceChartWidgetState extends State<PriceChartWidget> {
  String _selectedProduct = 'tomate';
  int? _touchedIndex;

  final PriceChartService _service = PriceChartService();

List<PricePoint> _points = [];
bool _loading = true;
DateTime _lastUpdated = DateTime.now();

  final Map<String, Color> _productColors = {
    'Tomate': AppTheme.warning,
    'Mandioca': AppTheme.earthBrown,
    'Milho': AppTheme.amber,
  };

  // O eixo X agora será dinâmico usando _points

  Future<void> _loadData() async {
  setState(() => _loading = true);

  final result = await _service.getForecast(_selectedProduct);

  setState(() {
    _points = result;
    _lastUpdated = DateTime.now();
    _loading = false;
  });
}

  @override
void initState() {
  super.initState();
  _loadData();
}



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final selectedColor =
      _productColors[_selectedProduct] ?? AppTheme.primary;

    if (_loading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final spots = _points.isEmpty
    ? <FlSpot>[]
    : _points.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value.price,
        );
      }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Índice de Preços',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      Text(
                        'Próximos 6 meses · AOA/kg · Luanda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: ['Tomate', 'Mandioca', 'Milho'].map((product) {
                      final isSelected = _selectedProduct == product;
                      return GestureDetector(
                        onTap: () async {
                          setState(() {
                            _selectedProduct = product;
                            _loading = true;
                          });

                          await _loadData();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(13),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            product,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? _productColors[product]
                                  : AppTheme.outline,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppTheme.outlineVariant.withAlpha(128),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 100,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppTheme.outline,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= _points.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _points[idx].label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                color: AppTheme.outline,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: selectedColor,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          if (index == spots.length - 1) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: selectedColor,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          }
                          return FlDotCirclePainter(
                            radius: 0,
                            color: Colors.transparent,
                            strokeWidth: 0,
                            strokeColor: Colors.transparent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            selectedColor.withAlpha(64),
                            selectedColor.withAlpha(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: theme.colorScheme.inverseSurface,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          final label = index < _points.length
                              ? _points[index].label
                              : 'N/A';

                          return LineTooltipItem(
                            'AOA ${spot.y.toInt()}/kg\n$label',
                            GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onInverseSurface,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.update_rounded,
                  size: 12,
                  color: AppTheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  'Actualizado às ${_lastUpdated.hour.toString().padLeft(2, '0')}:${_lastUpdated.minute.toString().padLeft(2, '0')} · ${_lastUpdated.day.toString().padLeft(2, '0')}/${_lastUpdated.month.toString().padLeft(2, '0')}/${_lastUpdated.year}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppTheme.outline,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 10,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'IA Activa',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}