import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense.dart';

class LocalDatabase {
  static const String _appBoxName = 'smart_expense_box';
  static const String _expensesKey = 'expenses';
  static const String _budgetKey = 'monthly_budget';
  static const String _themeModeKey = 'theme_mode';
  static const String _currencyCodeKey = 'currency_code';
  static const String _datePatternKey = 'date_pattern';

  late Box<dynamic> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_appBoxName);
  }

  List<Expense> getExpenses() {
    final List<dynamic> raw =
        (_box.get(_expensesKey) as List<dynamic>?) ?? <dynamic>[];
    return raw
        .map((dynamic item) => Expense.fromMap(item as Map<dynamic, dynamic>))
        .toList(growable: false);
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final List<Map<String, dynamic>> encoded = expenses
        .map((Expense expense) => expense.toMap())
        .toList(growable: false);
    await _box.put(_expensesKey, encoded);
  }

  double getMonthlyBudget() {
    final num? value = _box.get(_budgetKey) as num?;
    return (value ?? 0).toDouble();
  }

  Future<void> saveMonthlyBudget(double budget) async {
    await _box.put(_budgetKey, budget);
  }

  String getThemeMode() {
    return (_box.get(_themeModeKey) as String?) ?? 'system';
  }

  Future<void> saveThemeMode(String value) async {
    await _box.put(_themeModeKey, value);
  }

  String getCurrencyCode() {
    return (_box.get(_currencyCodeKey) as String?) ?? 'INR';
  }

  Future<void> saveCurrencyCode(String value) async {
    await _box.put(_currencyCodeKey, value);
  }

  String getDatePattern() {
    return (_box.get(_datePatternKey) as String?) ?? 'dd MMM yyyy';
  }

  Future<void> saveDatePattern(String value) async {
    await _box.put(_datePatternKey, value);
  }
}
