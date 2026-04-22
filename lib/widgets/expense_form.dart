import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key, this.initialExpense, required this.onSubmit});

  final Expense? initialExpense;
  final void Function({
    required String name,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
  })
  onSubmit;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialExpense?.name ?? '',
    );
    _amountController = TextEditingController(
      text: widget.initialExpense?.amount.toStringAsFixed(2) ?? '',
    );
    _selectedDate = widget.initialExpense?.date ?? DateTime.now();
    _selectedCategory =
        widget.initialExpense?.category ?? ExpenseCategory.other;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    final String name = _nameController.text.trim();
    final double? amount = double.tryParse(_amountController.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid values.')),
      );
      return;
    }
    widget.onSubmit(
      name: name,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseProvider provider = context.watch<ExpenseProvider>();
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _nameController,
            maxLength: 40,
            decoration: const InputDecoration(labelText: 'Expense Name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount (${provider.currencySymbol})',
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<ExpenseCategory>(
            value: _selectedCategory,
            items: ExpenseCategory.values
                .map(
                  (ExpenseCategory category) =>
                      DropdownMenuItem<ExpenseCategory>(
                        value: category,
                        child: Text('${category.emoji} ${category.label}'),
                      ),
                )
                .toList(growable: false),
            onChanged: (ExpenseCategory? value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_rounded),
            label: Text(
              AppFormatters.formatDate(
                _selectedDate,
                pattern: provider.datePattern,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(
              widget.initialExpense == null ? 'Add Expense' : 'Update Expense',
            ),
          ),
        ],
      ),
    );
  }
}
