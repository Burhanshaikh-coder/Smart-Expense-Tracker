import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../utils/formatters.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseProvider provider = context.watch<ExpenseProvider>();
    final Color warningColor =
        provider.isBudgetExceeded
            ? Colors.red
            : Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        child: Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Monthly Budget',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _budgetController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Set/Update budget (₹)',
                        hintText: 'e.g. 25000',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        final double? value = double.tryParse(
                          _budgetController.text.trim(),
                        );
                        if (value == null || value <= 0) return;
                        await context.read<ExpenseProvider>().setMonthlyBudget(
                          value,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Budget updated')),
                          );
                        }
                      },
                      child: const Text('Save Budget'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Spent this month: ${AppFormatters.formatCurrency(provider.monthlyTotal, locale: provider.currencyLocale, symbol: provider.currencySymbol)}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Remaining: ${AppFormatters.formatCurrency(provider.remainingBudget, locale: provider.currencyLocale, symbol: provider.currencySymbol)}',
                      style: TextStyle(
                        color: warningColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: provider.budgetUsage,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green,
                    ),
                    if (provider.isBudgetExceeded) ...<Widget>[
                      const SizedBox(height: 10),
                      const Text(
                        'Warning: Budget exceeded!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
