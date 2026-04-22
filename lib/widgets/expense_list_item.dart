import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';

class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
    required this.selectionMode,
    required this.isSelected,
    required this.onToggleSelection,
  });

  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool selectionMode;
  final bool isSelected;
  final ValueChanged<bool> onToggleSelection;

  @override
  Widget build(BuildContext context) {
    final ExpenseProvider provider = context.watch<ExpenseProvider>();
    final Color categoryColor = _categoryColor(expense.category);

    return Card(
      color: categoryColor.withValues(alpha: 0.09),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading:
        selectionMode
            ? Checkbox(
          value: isSelected,
          onChanged:
              (bool? value) => onToggleSelection(value ?? false),
        )
            : CircleAvatar(
          backgroundColor: categoryColor.withValues(alpha: 0.2),
          child: Text(
            expense.category.emoji,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        onLongPress: () => onToggleSelection(!isSelected),
        onTap: selectionMode ? () => onToggleSelection(!isSelected) : null,
        title: Text(
          expense.name,
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
        subtitle: Text(
          '${expense.category.label} • ${AppFormatters.formatDate(expense.date, pattern: provider.datePattern)}',
        ),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160,),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Text(
                  AppFormatters.formatCurrency(
                    expense.amount,
                    locale: provider.currencyLocale,
                    symbol: provider.currencySymbol,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style:GoogleFonts.aBeeZee(fontWeight: FontWeight.w700),
                ),
              ),

              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
              ),

              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _categoryColor(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.food:
      return Colors.orange;
    case ExpenseCategory.travel:
      return Colors.blue;
    case ExpenseCategory.shopping:
      return Colors.purple;
    case ExpenseCategory.bills:
      return Colors.teal;
    case ExpenseCategory.other:
      return Colors.grey;
  }
}
