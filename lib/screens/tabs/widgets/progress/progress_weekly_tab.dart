import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:interactive_learn/core/models/weekly_subject_progress.dart';
import 'package:interactive_learn/screens/tabs/widgets/progress/progress_chart_card.dart';

class ProgressWeeklyTab extends StatelessWidget {
  final List<WeeklySubjectProgress> data;

  const ProgressWeeklyTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No weekly progress yet. Start a lesson to see charts here.'));
    }

    final dailyTotals = _buildDailyTotals(data);
    final subjectTotals = _buildSubjectTotals(data);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ProgressChartCard(
          title: 'Weekly XP Trend',
          subtitle: 'All completed lessons in the last 7 days',
          child: SizedBox(height: 220, child: _weeklyLineChart(dailyTotals, context)),
        ),
        const SizedBox(height: 14),
        ProgressChartCard(
          title: 'Subject-wise XP Split',
          subtitle: 'Where your learning energy went this week',
          child: SizedBox(height: 230, child: _subjectPieChart(subjectTotals, context)),
        ),
        const SizedBox(height: 14),
        ProgressChartCard(
          title: 'Daily Subject Volume',
          subtitle: 'Which subject got the most action each day',
          child: SizedBox(height: 260, child: _subjectBarChart(data, context)),
        ),
      ],
    );
  }

  List<_DayPoint> _buildDailyTotals(List<WeeklySubjectProgress> source) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6));
    final days = List.generate(7, (index) => DateTime(start.year, start.month, start.day).add(Duration(days: index)));
    final totals = <DateTime, int>{for (final day in days) day: 0};

    for (final row in source) {
      final day = DateTime(row.dayBucket.year, row.dayBucket.month, row.dayBucket.day);
      totals[day] = (totals[day] ?? 0) + row.xpEarned;
    }

    return days.map((day) => _DayPoint(day: day, xp: totals[day] ?? 0)).toList();
  }

  Map<String, int> _buildSubjectTotals(List<WeeklySubjectProgress> source) {
    final totals = <String, int>{};
    for (final row in source) {
      totals[row.subjectName] = (totals[row.subjectName] ?? 0) + row.xpEarned;
    }
    return totals;
  }

  Widget _weeklyLineChart(List<_DayPoint> points, BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 50,
              getTitlesWidget: (value, _) => Text('${value.toInt()}'),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) return const SizedBox.shrink();
                final label = DateFormat('E').format(points[index].day);
                return Text(label, style: const TextStyle(fontSize: 11));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].xp.toDouble()),
            ],
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subjectPieChart(Map<String, int> subjectTotals, BuildContext context) {
    final entries = subjectTotals.entries.toList();
    if (entries.isEmpty) return const Center(child: Text('No subject data yet.'));

    final colors = [
      Colors.indigo,
      Colors.teal,
      Colors.deepOrange,
      Colors.purple,
      Colors.green,
      Colors.amber,
    ];

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value.toDouble(),
                    color: colors[i % colors.length],
                    title: entries[i].value > 0 ? '${entries[i].value}' : '',
                    radius: 62,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < entries.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entries[i].key, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subjectBarChart(List<WeeklySubjectProgress> data, BuildContext context) {
    final subjectNames = data.map((e) => e.subjectName).toSet().toList();
    final dayMap = <DateTime, Map<String, int>>{};

    for (final row in data) {
      final day = DateTime(row.dayBucket.year, row.dayBucket.month, row.dayBucket.day);
      dayMap.putIfAbsent(day, () => {});
      dayMap[day]![row.subjectName] = (dayMap[day]![row.subjectName] ?? 0) + row.xpEarned;
    }

    final days = dayMap.keys.toList()..sort();
    final palette = [
      Colors.indigo,
      Colors.teal,
      Colors.deepOrange,
      Colors.purple,
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        groupsSpace: 12,
        barTouchData: BarTouchData(enabled: true),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 34, interval: 50),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= days.length) return const SizedBox.shrink();
                return Text(DateFormat('E').format(days[index]), style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                for (var j = 0; j < math.min(subjectNames.length, 3); j++)
                  BarChartRodData(
                    toY: (dayMap[days[i]]?[subjectNames[j]] ?? 0).toDouble(),
                    color: palette[j % palette.length],
                    width: 10,
                    borderRadius: BorderRadius.circular(4),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DayPoint {
  final DateTime day;
  final int xp;

  const _DayPoint({required this.day, required this.xp});
}