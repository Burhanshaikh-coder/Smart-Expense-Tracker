import 'dart:math';

import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider(this._repository);

  final ExpenseRepository _repository;
  final Random _random = Random();

  final List<Expense> _allExpenses = <Expense>[];
  bool _isLoading = true;
  String _searchQuery = '';
  ExpenseCategory? _activeCategory;
  double _monthlyBudget = 0;
  ThemeMode _themeMode = ThemeMode.system;
  String _currencyCode = 'INR';
  String _datePattern = 'dd MMM yyyy';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  ExpenseCategory? get activeCategory => _activeCategory;
  double get monthlyBudget => _monthlyBudget;
  ThemeMode get themeMode => _themeMode;
  String get currencyCode => _currencyCode;
  String get datePattern => _datePattern;
  String get currencySymbol => _currencyCode == 'USD' ? '\$' : '₹';
  String get currencyLocale => _currencyCode == 'USD' ? 'en_US' : 'en_IN';

  List<Expense> get expenses => List<Expense>.unmodifiable(_allExpenses);

  List<Expense> get filteredExpenses {
    return _allExpenses
        .where((Expense expense) {
          final bool matchesSearch = expense.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final bool matchesCategory =
              _activeCategory == null || expense.category == _activeCategory;
          return matchesSearch && matchesCategory;
        })
        .toList(growable: false)
      ..sort((Expense a, Expense b) => b.date.compareTo(a.date));
  }

  Future<void> bootstrap() async {
    _isLoading = true;
    notifyListeners();
    await _repository.init();
    _allExpenses
      ..clear()
      ..addAll(_repository.getExpenses());
    _monthlyBudget = _repository.getMonthlyBudget();
    _themeMode = _themeModeFromString(_repository.getThemeMode());
    _currencyCode = _repository.getCurrencyCode();
    _datePattern = _repository.getDatePattern();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense({
    required String name,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
  }) async {
    _allExpenses.add(
      Expense(
        id: '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(999)}',
        name: name,
        amount: amount,
        date: date,
        category: category,
      ),
    );
    await _persistAndRefresh();
  }

  Future<void> updateExpense(Expense updated) async {
    final int index = _allExpenses.indexWhere(
      (Expense e) => e.id == updated.id,
    );
    if (index == -1) return;
    _allExpenses[index] = updated;
    await _persistAndRefresh();
  }

  Future<void> deleteExpense(String id) async {
    _allExpenses.removeWhere((Expense e) => e.id == id);
    await _persistAndRefresh();
  }

  Future<void> deleteExpenses(Iterable<String> ids) async {
    final Set<String> deleteSet = ids.toSet();
    _allExpenses.removeWhere((Expense e) => deleteSet.contains(e.id));
    await _persistAndRefresh();
  }

  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    await _repository.saveMonthlyBudget(amount);
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategoryFilter(ExpenseCategory? category) {
    _activeCategory = category;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _repository.saveThemeMode(_themeModeToString(mode));
    notifyListeners();
  }

  Future<void> setCurrencyCode(String code) async {
    _currencyCode = code;
    await _repository.saveCurrencyCode(code);
    notifyListeners();
  }

  Future<void> setDatePattern(String pattern) async {
    _datePattern = pattern;
    await _repository.saveDatePattern(pattern);
    notifyListeners();
  }

  double get todayTotal => _sumForRange(DateTime.now(), DateTime.now());

  double get weeklyTotal {
    final DateTime now = DateTime.now();
    final DateTime start = now.subtract(Duration(days: now.weekday - 1));
    return _sumForRange(start, now);
  }

  double get monthlyTotal {
    final DateTime now = DateTime.now();
    final DateTime start = DateTime(now.year, now.month, 1);
    final DateTime end = DateTime(now.year, now.month + 1, 0);
    return _sumForRange(start, end);
  }

  double get remainingBudget => _monthlyBudget - monthlyTotal;

  double get budgetUsage {
    if (_monthlyBudget <= 0) return 0;
    return (monthlyTotal / _monthlyBudget).clamp(0, 1);
  }

  bool get isBudgetExceeded =>
      _monthlyBudget > 0 && monthlyTotal > _monthlyBudget;

  double _sumForRange(DateTime start, DateTime end) {
    final DateTime from = DateTime(start.year, start.month, start.day);
    final DateTime to = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return _allExpenses
        .where((Expense e) => !e.date.isBefore(from) && !e.date.isAfter(to))
        .fold<double>(0, (double total, Expense e) => total + e.amount);
  }

  Map<ExpenseCategory, double> get categoryTotals {
    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month, 1);
    final DateTime monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final Map<ExpenseCategory, double> totals = <ExpenseCategory, double>{};
    for (final ExpenseCategory category in ExpenseCategory.values) {
      totals[category] = 0;
    }
    for (final Expense expense in _allExpenses) {
      if (expense.date.isBefore(monthStart) || expense.date.isAfter(monthEnd)) {
        continue;
      }
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<double> get weeklyTrend {
    final DateTime now = DateTime.now();
    return List<double>.generate(7, (int index) {
      final DateTime day = now.subtract(Duration(days: 6 - index));
      return _sumForRange(day, day);
    });
  }

  List<double> get monthlyTrend {
    final DateTime now = DateTime.now();
    return List<double>.generate(4, (int index) {
      final DateTime start = now.subtract(Duration(days: (3 - index) * 7));
      final DateTime end = start.add(const Duration(days: 6));
      return _sumForRange(start, end);
    });
  }

  String get monthlyInsight {
    final DateTime now = DateTime.now();
    final DateTime currentStart = DateTime(now.year, now.month, 1);
    final DateTime prevStart = DateTime(now.year, now.month - 1, 1);
    final DateTime prevEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
    final double current = _sumForRange(currentStart, now);
    final double previous = _allExpenses
        .where(
          (Expense e) =>
              !e.date.isBefore(prevStart) && !e.date.isAfter(prevEnd),
        )
        .fold<double>(0, (double total, Expense e) => total + e.amount);
    if (previous == 0) {
      return 'No previous month data for comparison.';
    }
    final double diff = ((current - previous) / previous) * 100;
    if (diff >= 0) {
      return 'You spent ${diff.toStringAsFixed(1)}% more than last month.';
    }
    return 'You spent ${diff.abs().toStringAsFixed(1)}% less than last month.';
  }

  Future<void> _persistAndRefresh() async {
    await _repository.saveExpenses(_allExpenses);
    notifyListeners();
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
