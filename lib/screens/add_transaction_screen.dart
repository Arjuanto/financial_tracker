import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart' as model;
import '../models/category.dart';

class AddTransactionScreen extends StatefulWidget {
  final model.Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final t = widget.transaction!;
      _type = t.type;
      _amountController.text = t.amount.toInt().toString();
      _noteController.text = t.note ?? '';
      _selectedDate = t.date;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<TransactionProvider>();
        final match = provider.categories.where((c) => c.id == t.categoryId);
        if (match.isNotEmpty) {
          setState(() => _selectedCategory = match.first);
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _type == 'income'
        ? provider.incomeCategories
        : provider.expenseCategories;

    if (_selectedCategory != null && _selectedCategory!.type != _type) {
      _selectedCategory = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Transaksi' : 'Tambah Transaksi',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0D7377),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Amount display
            _buildAmountDisplay(isDark),
            const SizedBox(height: 24),
            _buildTypeToggle(isDark),
            const SizedBox(height: 16),
            _buildCategoryDropdown(categories, isDark),
            const SizedBox(height: 16),
            _buildDatePicker(isDark),
            const SizedBox(height: 16),
            _buildNoteField(isDark),
            const SizedBox(height: 32),
            _buildSubmitButton(provider),
          ],
        ),
      ),
    );
  }

  // ── AMOUNT DISPLAY ────────────────────────────────────

  Widget _buildAmountDisplay(bool isDark) {
    final isExpense = _type == 'expense';
    final color =
        isExpense ? const Color(0xFFFF5252) : const Color(0xFF00C853);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
          Text(
            isExpense ? 'Pengeluaran' : 'Pemasukan',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Rp ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Flexible(
                child: IntrinsicWidth(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (double.tryParse(value) == null) return 'Tidak valid';
                      if (double.parse(value) <= 0) return 'Harus > 0';
                      return null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TYPE TOGGLE ───────────────────────────────────────

  Widget _buildTypeToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTypeOption(
            label: 'Pengeluaran',
            icon: Icons.north_east_rounded,
            isSelected: _type == 'expense',
            color: const Color(0xFFFF5252),
            isDark: isDark,
            onTap: () => setState(() => _type = 'expense'),
          ),
          _buildTypeOption(
            label: 'Pemasukan',
            icon: Icons.south_west_rounded,
            isSelected: _type == 'income',
            color: const Color(0xFF00C853),
            isDark: isDark,
            onTap: () => setState(() => _type = 'income'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? color.withValues(alpha: 0.15) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CATEGORY DROPDOWN ─────────────────────────────────

  Widget _buildCategoryDropdown(List<Category> categories, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      child: DropdownButtonFormField<Category>(
        value: _selectedCategory,
        decoration: const InputDecoration(
          labelText: 'Kategori',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.category_rounded),
        ),
        items: categories
            .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat.name),
                ))
            .toList(),
        onChanged: (value) => setState(() => _selectedCategory = value),
        validator: (value) => value == null ? 'Kategori wajib dipilih' : null,
      ),
    );
  }

  // ── DATE PICKER ───────────────────────────────────────

  Widget _buildDatePicker(bool isDark) {
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');

    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D7377).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.calendar_month_rounded,
              color: Color(0xFF0D7377), size: 22),
        ),
        title: const Text('Tanggal',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(
          formatter.format(_selectedDate),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() => _selectedDate = picked);
          }
        },
      ),
    );
  }

  // ── NOTE FIELD ────────────────────────────────────────

  Widget _buildNoteField(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      child: TextFormField(
        controller: _noteController,
        decoration: const InputDecoration(
          labelText: 'Catatan (opsional)',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.notes_rounded),
        ),
        maxLines: 2,
      ),
    );
  }

  // ── SUBMIT ────────────────────────────────────────────

  Widget _buildSubmitButton(TransactionProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: () => _submit(provider),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0D7377),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Text(
          isEditing ? 'Update Transaksi' : 'Simpan Transaksi',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _submit(TransactionProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = model.Transaction(
      id: widget.transaction?.id,
      categoryId: _selectedCategory!.id!,
      amount: double.parse(_amountController.text),
      note: _noteController.text.trim(),
      date: _selectedDate,
      type: _type,
    );

    if (isEditing) {
      await provider.updateTransaction(transaction);
    } else {
      await provider.addTransaction(transaction);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Transaksi berhasil diupdate'
              : 'Transaksi berhasil disimpan'),
          backgroundColor: const Color(0xFF0D7377),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
