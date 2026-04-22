import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseProvider provider = context.watch<ExpenseProvider>();
    final Map<ExpenseCategory, double> categoryTotals = provider.categoryTotals;
    final List<double> trend = provider.weeklyTrend;
    final double trendMax =
        trend.isEmpty ? 100 : (trend.reduce((a, b) => a > b ? a : b) + 200);
    final bool hasChartData = categoryTotals.values.any(
      (double value) => value > 0,
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1E3A8A), Color(0xFF6D28D9)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
          child: Column(
            children: <Widget>[
              _GlassTotalCard(provider: provider),
              const SizedBox(height: 12),
              _QuickStatsRow(provider: provider),
              const SizedBox(height: 12),
              _buildDonutCard(context, provider, categoryTotals, hasChartData),
              const SizedBox(height: 12),
              _buildTrendCard(context, trend, trendMax),
              const SizedBox(height: 12),
              _buildInsightCard(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonutCard(
    BuildContext context,
    ExpenseProvider provider,
    Map<ExpenseCategory, double> categoryTotals,
    bool hasChartData,
  ) {
    return _panel(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Category Split'),
          const SizedBox(height: 12),
          if (!hasChartData)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 52,
                  sections: ExpenseCategory.values
                      .map((ExpenseCategory category) {
                        final double value = categoryTotals[category] ?? 0;
                        return PieChartSectionData(
                          color: _categoryColor(category),
                          value: value <= 0 ? 0.01 : value,
                          title: value <= 0 ? '' : category.emoji,
                          titleStyle: const TextStyle(fontSize: 15),
                          radius: 62,
                        );
                      })
                      .toList(growable: false),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExpenseCategory.values
                .map((ExpenseCategory category) {
                  return _legendChip(category);
                })
                .toList(growable: false),
          ),
          const SizedBox(height: 8),
          Text(
            'This Month: ${AppFormatters.formatCurrency(provider.monthlyTotal, locale: provider.currencyLocale, symbol: provider.currencySymbol)}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
    BuildContext context,
    List<double> trend,
    double trendMax,
  ) {
    return _panel(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('This Week Trend'),
          const SizedBox(height: 12),
          if (trend.every((double value) => value == 0))
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: trendMax,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const List<String> labels = <String>[
                            'M',
                            'T',
                            'W',
                            'T',
                            'F',
                            'S',
                            'S',
                          ];
                          final int index = value.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              index >= 0 && index < labels.length
                                  ? labels[index]
                                  : '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: trend
                      .asMap()
                      .entries
                      .map((MapEntry<int, double> entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: <BarChartRodData>[
                            BarChartRodData(
                              toY: entry.value,
                              width: 16,
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                colors: <Color>[
                                  Color(0xFF60A5FA),
                                  Color(0xFFC084FC),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        );
                      })
                      .toList(growable: false),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, ExpenseProvider provider) {
    return _panel(
      context,
      child: Row(
        children: <Widget>[
          const Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.monthlyInsight,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(BuildContext context, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white, fontSize: 14),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _legendChip(ExpenseCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _categoryColor(category).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text('${category.emoji} ${category.label}'),
    );
  }
}

class _GlassTotalCard extends StatelessWidget {
  const _GlassTotalCard({required this.provider});

  final ExpenseProvider provider;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white30),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Total Expenses',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                AppFormatters.formatCurrency(
                  provider.monthlyTotal,
                  locale: provider.currencyLocale,
                  symbol: provider.currencySymbol,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.provider});

  final ExpenseProvider provider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _AnimatedMetricCard(
            label: 'Today',
            icon: Icons.today_rounded,
            value: provider.todayTotal,
            provider: provider,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AnimatedMetricCard(
            label: 'This Week',
            icon: Icons.date_range_rounded,
            value: provider.weeklyTotal,
            provider: provider,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AnimatedMetricCard(
            label: 'This Month',
            icon: Icons.calendar_month_rounded,
            value: provider.monthlyTotal,
            provider: provider,
          ),
        ),
      ],
    );
  }
}

class _AnimatedMetricCard extends StatefulWidget {
  const _AnimatedMetricCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.provider,
  });

  final String label;
  final IconData icon;
  final double value;
  final ExpenseProvider provider;

  @override
  State<_AnimatedMetricCard> createState() => _AnimatedMetricCardState();
}

class _AnimatedMetricCardState extends State<_AnimatedMetricCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Icon(widget.icon, color: Colors.white),
            const SizedBox(height: 6),
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              AppFormatters.formatCurrency(
                widget.value,
                locale: widget.provider.currencyLocale,
                symbol: widget.provider.currencySymbol,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _categoryColor(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.food:
      return Colors.orange;
    case ExpenseCategory.travel:
      return Colors.blue;
    case ExpenseCategory.shopping:
      return Colors.purple;
    case ExpenseCategory.bills:
      return Colors.teal;
    case ExpenseCategory.other:
      return Colors.grey;
  }
}
