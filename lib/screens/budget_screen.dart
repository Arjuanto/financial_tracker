import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/budget.dart';
import '../models/category.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Anggaran',
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
          final expenseCategories = provider.expenseCategories;
          final formatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          // Calculate total budget vs spent
          double totalBudget = 0;
          double totalSpent = 0;
          for (final cat in expenseCategories) {
            final b = provider.getBudgetForCategory(cat.id!);
            if (b != null) totalBudget += b.amount;
            totalSpent += provider.getSpentByCategory(cat.id!);
          }

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
                      color: Colors.black
                          .withValues(alpha: isDark ? 0.2 : 0.04),
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
              // Total overview
              if (totalBudget > 0)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                          : [const Color(0xFF0D7377), const Color(0xFF14BDAC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Terpakai',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatter.format(totalSpent),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Anggaran',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatter.format(totalBudget),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (totalSpent / totalBudget).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation(
                            totalSpent > totalBudget
                                ? const Color(0xFFFF5252)
                                : const Color(0xFF00E676),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${((totalSpent / totalBudget) * 100).clamp(0, 999).toStringAsFixed(0)}% terpakai',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (totalBudget > 0) const SizedBox(height: 20),
              // Category list
              ...expenseCategories.map((cat) =>
                  _BudgetCard(category: cat, provider: provider, isDark: isDark)),
            ],
          );
        },
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Category category;
  final TransactionProvider provider;
  final bool isDark;

  const _BudgetCard({
    required this.category,
    required this.provider,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final budget = provider.getBudgetForCategory(category.id!);
    final spent = provider.getSpentByCategory(category.id!);
    final budgetAmount = budget?.amount ?? 0;
    final percentage = budgetAmount > 0 ? (spent / budgetAmount) : 0.0;
    final isOver = spent > budgetAmount && budgetAmount > 0;
    final isWarning = percentage >= 0.8 && !isOver && budgetAmount > 0;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final statusColor = isOver
        ? const Color(0xFFFF5252)
        : isWarning
            ? const Color(0xFFFF9800)
            : const Color(0xFF00C853);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSetBudgetDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getCategoryIcon(category.name),
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isOver)
                      _statusBadge('Melebihi!', const Color(0xFFFF5252))
                    else if (isWarning)
                      _statusBadge('Hampir limit', const Color(0xFFFF9800)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        size: 20, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 12),
                if (budgetAmount > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percentage.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatter.format(spent),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isOver ? const Color(0xFFFF5252) : null,
                        ),
                      ),
                      Text(
                        'dari ${formatter.format(budgetAmount)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Text(
                        'Terpakai: ${formatter.format(spent)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· Tap untuk set anggaran',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF0D7377).withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'makan':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'belanja':
        return Icons.shopping_bag_rounded;
      case 'tagihan':
        return Icons.receipt_rounded;
      case 'hiburan':
        return Icons.movie_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context) {
    final budget = provider.getBudgetForCategory(category.id!);
    final controller = TextEditingController(
      text: budget != null ? budget.amount.toInt().toString() : '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Anggaran ${category.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Jumlah anggaran',
            prefixText: 'Rp ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          if (budget != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                provider.deleteBudget(budget.id!);
              },
              child: const Text('Hapus',
                  style: TextStyle(color: Color(0xFFFF5252))),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                final newBudget = Budget(
                  categoryId: category.id!,
                  amount: amount,
                  month: provider.selectedMonth.month,
                  year: provider.selectedMonth.year,
                );
                provider.saveBudget(newBudget);
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D7377),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
