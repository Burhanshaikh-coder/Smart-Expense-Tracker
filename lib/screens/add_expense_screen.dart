import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_form.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add a new expense',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Expanded(
            child: ExpenseForm(
              onSubmit: ({
                required String name,
                required double amount,
                required DateTime date,
                required ExpenseCategory category,
              }) async {
                await context.read<ExpenseProvider>().addExpense(
                  name: name,
                  amount: amount,
                  date: date,
                  category: category,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense added')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
