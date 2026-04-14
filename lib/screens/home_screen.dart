import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart' as model;
import '../models/category.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, provider, isDark),
              _buildSearchBar(provider, isDark),
              _buildTransactionList(context, provider, isDark),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ).then((_) => context.read<TransactionProvider>().loadAll()),
        backgroundColor: const Color(0xFF00C9A7),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, TransactionProvider provider, bool isDark) {
    final summary = provider.filteredSummary;
    final balance = summary['balance'] ?? 0;
    final income = summary['income'] ?? 0;
    final expense = summary['expense'] ?? 0;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final monthFormatter = DateFormat('MMMM yyyy', 'id_ID');

    return SliverAppBar(
      expandedHeight: 330,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0D7377),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [const Color(0xFF0D7377), const Color(0xFF14BDAC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Month picker
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => provider.previousMonth(),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.chevron_left,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _pickMonth(context, provider),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              monthFormatter.format(provider.selectedMonth),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => provider.nextMonth(),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.chevron_right,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Saldo Bulan Ini',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatter.format(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Pemasukan',
                          amount: formatter.format(income),
                          icon: Icons.south_west_rounded,
                          iconBgColor: const Color(0xFF00E676),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Pengeluaran',
                          amount: formatter.format(expense),
                          icon: Icons.north_east_rounded,
                          iconBgColor: const Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      title: const Row(
        children: [
          Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
          SizedBox(width: 8),
          Text(
            'Finance Tracker',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                provider.setSearchQuery('');
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.file_download_outlined, color: Colors.white),
          tooltip: 'Export CSV',
          onPressed: () async {
            try {
              await provider.exportToCsv();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal export: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(TransactionProvider provider, bool isDark) {
    if (!_showSearch) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            provider.setSearchQuery(value);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Cari transaksi...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                    onPressed: () {
                      _searchController.clear();
                      provider.setSearchQuery('');
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
    );
  }

  void _pickMonth(BuildContext context, TransactionProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      provider.setMonth(picked);
    }
  }

  Widget _buildTransactionList(
      BuildContext context, TransactionProvider provider, bool isDark) {
    final transactions = provider.filteredTransactions;

    if (transactions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long_rounded,
                    size: 48, color: Colors.grey[400]),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada transaksi',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap + untuk menambah transaksi',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Riwayat Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${transactions.length} transaksi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            final transaction = transactions[index - 1];
            final category = provider.categories.firstWhere(
              (c) => c.id == transaction.categoryId,
              orElse: () => Category(
                name: 'Lainnya',
                type: transaction.type,
                icon: 'other',
              ),
            );

            return _TransactionCard(
              transaction: transaction,
              categoryName: category.name,
              isDark: isDark,
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddTransactionScreen(transaction: transaction),
                ),
              ),
              onDelete: () => _confirmDelete(context, provider, transaction),
            );
          },
          childCount: transactions.length + 1,
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TransactionProvider provider,
    model.Transaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteTransaction(transaction.id!);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ── WIDGETS LOKAL ─────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color iconBgColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconBgColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final model.Transaction transaction;
  final String categoryName;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionCard({
    required this.transaction,
    required this.categoryName,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getCategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'gaji':
        return Icons.work_rounded;
      case 'freelance':
        return Icons.laptop_mac_rounded;
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

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');
    final color = isIncome ? const Color(0xFF00C853) : const Color(0xFFFF5252);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon kategori
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getCategoryIcon(categoryName),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        transaction.note?.isNotEmpty == true
                            ? '${transaction.note} · ${dateFormatter.format(transaction.date)}'
                            : dateFormatter.format(transaction.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Amount & actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.edit_outlined,
                                size: 15, color: Colors.grey[400]),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.delete_outline_rounded,
                                size: 15, color: Colors.grey[400]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
