import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistik',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0D7377),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final monthFormatter = DateFormat('MMMM yyyy', 'id_ID');
          final summary = provider.filteredSummary;
          final formatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Month picker
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => provider.previousMonth(),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Text(
                      monthFormatter.format(provider.selectedMonth),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => provider.nextMonth(),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Summary row
              Row(
                children: [
                  Expanded(
                    child: _MiniSummary(
                      label: 'Pemasukan',
                      amount: formatter.format(summary['income']),
                      color: const Color(0xFF00C853),
                      icon: Icons.south_west_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniSummary(
                      label: 'Pengeluaran',
                      amount: formatter.format(summary['expense']),
                      color: const Color(0xFFFF5252),
                      icon: Icons.north_east_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildBarChart(provider, isDark),
              const SizedBox(height: 20),
              _buildPieChart(provider, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBarChart(TransactionProvider provider, bool isDark) {
    final filtered = provider.filteredTransactions;
    final formatter = NumberFormat.compact(locale: 'id_ID');

    final Map<int, double> incomeByDay = {};
    final Map<int, double> expenseByDay = {};

    for (final t in filtered) {
      final day = t.date.day;
      if (t.type == 'income') {
        incomeByDay[day] = (incomeByDay[day] ?? 0) + t.amount;
      } else {
        expenseByDay[day] = (expenseByDay[day] ?? 0) + t.amount;
      }
    }

    final allDays = {...incomeByDay.keys, ...expenseByDay.keys}.toList()
      ..sort();

    if (allDays.isEmpty) {
      return _emptyCard('Belum ada data untuk ditampilkan', isDark);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pemasukan vs Pengeluaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legendDot(const Color(0xFF00C853), 'Pemasukan'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFFF5252), 'Pengeluaran'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = allDays[group.x.toInt()];
                      final label =
                          rodIndex == 0 ? 'Pemasukan' : 'Pengeluaran';
                      return BarTooltipItem(
                        'Tgl $day\n$label: Rp ${formatter.format(rod.toY)}',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= allDays.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${allDays[idx]}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(allDays.length, (i) {
                  final day = allDays[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: incomeByDay[day] ?? 0,
                        color: const Color(0xFF00C853),
                        width: 7,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: expenseByDay[day] ?? 0,
                        color: const Color(0xFFFF5252),
                        width: 7,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(TransactionProvider provider, bool isDark) {
    final filtered = provider.filteredTransactions;
    final categories = provider.categories;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final Map<int, double> expenseByCategory = {};
    for (final t in filtered.where((t) => t.type == 'expense')) {
      expenseByCategory[t.categoryId] =
          (expenseByCategory[t.categoryId] ?? 0) + t.amount;
    }

    if (expenseByCategory.isEmpty) {
      return _emptyCard('Belum ada pengeluaran bulan ini', isDark);
    }

    final totalExpense =
        expenseByCategory.values.fold(0.0, (sum, v) => sum + v);

    final colors = [
      const Color(0xFFFF5252),
      const Color(0xFFFF9800),
      const Color(0xFFFFCA28),
      const Color(0xFF7C4DFF),
      const Color(0xFF448AFF),
      const Color(0xFF00BFA5),
      const Color(0xFFFF4081),
      const Color(0xFF536DFE),
      const Color(0xFF00E5FF),
    ];

    final entries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengeluaran per Kategori',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 45,
                sections: List.generate(entries.length, (i) {
                  final entry = entries[i];
                  final percentage = (entry.value / totalExpense * 100);
                  return PieChartSectionData(
                    value: entry.value,
                    color: colors[i % colors.length],
                    radius: 55,
                    title: '${percentage.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    titlePositionPercentageOffset: 0.55,
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(entries.length, (i) {
            final entry = entries[i];
            final cat = categories.where((c) => c.id == entry.key);
            final catName = cat.isNotEmpty ? cat.first.name : 'Lainnya';
            final percentage = (entry.value / totalExpense * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      catName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    formatter.format(entry.value),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors[i % colors.length].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors[i % colors.length],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _emptyCard(String message, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _MiniSummary extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _MiniSummary({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
