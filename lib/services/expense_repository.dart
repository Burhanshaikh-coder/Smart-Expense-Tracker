import '../database/local_database.dart';
import '../models/expense.dart';

class ExpenseRepository {
  ExpenseRepository(this._database);

  final LocalDatabase _database;

  Future<void> init() => _database.init();

  List<Expense> getExpenses() => _database.getExpenses();

  Future<void> saveExpenses(List<Expense> expenses) =>
      _database.saveExpenses(expenses);

  double getMonthlyBudget() => _database.getMonthlyBudget();

  Future<void> saveMonthlyBudget(double amount) =>
      _database.saveMonthlyBudget(amount);

  String getThemeMode() => _database.getThemeMode();

  Future<void> saveThemeMode(String value) => _database.saveThemeMode(value);

  String getCurrencyCode() => _database.getCurrencyCode();

  Future<void> saveCurrencyCode(String value) =>
      _database.saveCurrencyCode(value);

  String getDatePattern() => _database.getDatePattern();

  Future<void> saveDatePattern(String value) =>
      _database.saveDatePattern(value);
}
