import 'package:flutter/material.dart';

enum ExpenseCategory { food, travel, shopping, bills, other }

extension ExpenseCategoryX on ExpenseCategory {
  String get keyName => name;

  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.food:
        return '🍔';
      case ExpenseCategory.travel:
        return '✈️';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.bills:
        return '💡';
      case ExpenseCategory.other:
        return '📦';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.fastfood_rounded;
      case ExpenseCategory.travel:
        return Icons.flight_takeoff_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.bills:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (item) => item.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}
