import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/db_helper.dart';
import '../models/transaction.dart' as model;
import '../models/category.dart';
import '../models/budget.dart';

class TransactionProvider with ChangeNotifier {
  List<model.Transaction> _transactions = [];
  List<Category> _categories = [];
  Map<String, double> _summary = {
    'income': 0,
    'expense': 0,
    'balance': 0,
  };
  List<Budget> _budgets = [];
  bool _isLoading = false;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _searchQuery = '';

  // ── GETTERS ──────────────────────────────────────────

  List<model.Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;
  Map<String, double> get summary => _summary;
  bool get isLoading => _isLoading;
  List<Budget> get budgets => _budgets;
  DateTime get selectedMonth => _selectedMonth;
  String get searchQuery => _searchQuery;

  List<model.Transaction> get filteredTransactions {
    var result = _transactions.where((t) =>
        t.date.year == _selectedMonth.year &&
        t.date.month == _selectedMonth.month);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((t) {
        final note = (t.note ?? '').toLowerCase();
        final cat = _categories.where((c) => c.id == t.categoryId);
        final catName = cat.isNotEmpty ? cat.first.name.toLowerCase() : '';
        return note.contains(query) || catName.contains(query);
      });
    }

    return result.toList();
  }

  Map<String, double> get filteredSummary {
    final filtered = filteredTransactions;
    final income = filtered
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = filtered
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  // ── FILTER ───────────────────────────────────────────

  void setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Category> get incomeCategories =>
      _categories.where((c) => c.type == 'income').toList();

  List<Category> get expenseCategories =>
      _categories.where((c) => c.type == 'expense').toList();

  // ── LOAD DATA ─────────────────────────────────────────

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await DBHelper.instance.getTransactions();
      _categories = await DBHelper.instance.getCategories();
      _summary = await DBHelper.instance.getSummary();
      _budgets = await DBHelper.instance.getBudgets(
        _selectedMonth.month,
        _selectedMonth.year,
      );
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── TRANSACTIONS ─────────────────────────────────────

  Future<void> addTransaction(model.Transaction transaction) async {
    await DBHelper.instance.insertTransaction(transaction);
    await loadAll();
  }

  Future<void> updateTransaction(model.Transaction transaction) async {
    await DBHelper.instance.updateTransaction(transaction);
    await loadAll();
  }

  Future<void> deleteTransaction(int id) async {
    await DBHelper.instance.deleteTransaction(id);
    await loadAll();
  }

  // ── EXPORT CSV ────────────────────────────────────────

  Future<void> exportToCsv() async {
    final transactions = filteredTransactions;
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final monthFormatter = DateFormat('MMMM_yyyy', 'id_ID');

    final buffer = StringBuffer();
    buffer.writeln('Tanggal,Tipe,Kategori,Jumlah,Catatan');

    for (final t in transactions) {
      final cat = _categories.where((c) => c.id == t.categoryId);
      final catName = cat.isNotEmpty ? cat.first.name : 'Lainnya';
      final date = dateFormatter.format(t.date);
      final type = t.type == 'income' ? 'Pemasukan' : 'Pengeluaran';
      final note = (t.note ?? '').replaceAll(',', ';');
      buffer.writeln('$date,$type,$catName,${t.amount},$note');
    }

    final dir = await getTemporaryDirectory();
    final fileName = 'rekap_${monthFormatter.format(_selectedMonth)}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Rekap Keuangan ${monthFormatter.format(_selectedMonth)}',
    );
  }

  // ── BUDGETS ──────────────────────────────────────────

  double getSpentByCategory(int categoryId) {
    return filteredTransactions
        .where((t) => t.categoryId == categoryId && t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Budget? getBudgetForCategory(int categoryId) {
    final match = _budgets.where((b) => b.categoryId == categoryId);
    return match.isNotEmpty ? match.first : null;
  }

  Future<void> saveBudget(Budget budget) async {
    await DBHelper.instance.upsertBudget(budget);
    await loadAll();
  }

  Future<void> deleteBudget(int id) async {
    await DBHelper.instance.deleteBudget(id);
    await loadAll();
  }

  // ── BACKUP & RESTORE ─────────────────────────────────

  Future<void> backupData() async {
    final jsonString = await DBHelper.instance.exportToJson();
    final dir = await getTemporaryDirectory();
    final date = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/backup_finance_$date.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Backup Finance Tracker',
    );
  }

  Future<void> restoreData(String jsonString) async {
    await DBHelper.instance.importFromJson(jsonString);
    await loadAll();
  }

  // ── CATEGORIES ───────────────────────────────────────

  Future<void> addCategory(Category category) async {
    await DBHelper.instance.insertCategory(category);
    await loadAll();
  }
}