import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_form.dart';
import '../widgets/expense_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Keeps selected IDs for multi-selection mode.
  final Set<String> _selectedIds = <String>{};

  bool get _selectionMode => _selectedIds.isNotEmpty;

  Future<void> _openEditSheet(BuildContext context, Expense expense) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return ExpenseForm(
          initialExpense: expense,
          onSubmit: ({
            required String name,
            required double amount,
            required DateTime date,
            required ExpenseCategory category,
          }) async {
            await context.read<ExpenseProvider>().updateExpense(
              expense.copyWith(
                name: name,
                amount: amount,
                date: date,
                category: category,
              ),
            );
            if (context.mounted) Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _openCreateSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return ExpenseForm(
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
            if (context.mounted) Navigator.pop(context);
          },
        );
      },
    );
  }

  void _toggleSelection(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  Future<void> _deleteSelected(BuildContext context) async {
    if (_selectedIds.isEmpty) return;
    final ExpenseProvider provider = context.read<ExpenseProvider>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await provider.deleteExpenses(_selectedIds);
    if (!mounted) return;
    _clearSelection();
    messenger.showSnackBar(
      const SnackBar(content: Text('Selected expenses deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseProvider provider = context.watch<ExpenseProvider>();
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final List<Expense> expenses = provider.filteredExpenses;
    return SafeArea(
      child: Column(
        children: <Widget>[
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          //   child: _HomeDashboard(provider: provider),
          // ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child:
                _selectionMode
                    ? Padding(
                      key: const ValueKey<String>('selection-toolbar'),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _SelectionToolbar(
                        totalCount: expenses.length,
                        selectedCount: _selectedIds.length,
                        onSelectAll: () {
                          setState(() {
                            _selectedIds
                              ..clear()
                              ..addAll(expenses.map((Expense e) => e.id));
                          });
                        },
                        onClear: _clearSelection,
                        onDelete: () => _deleteSelected(context),
                      ),
                    )
                    : const SizedBox.shrink(
                      key: ValueKey<String>('no-selection'),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: provider.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CategoryFilterChips(
              selected: provider.activeCategory,
              onChanged: provider.setCategoryFilter,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                expenses.isEmpty
                    ? EmptyState(
                      title: 'No expenses yet',
                      subtitle: 'Start tracking by adding your first expense.',
                      ctaLabel: 'Add Expense',
                      onCtaPressed: () => _openCreateSheet(context),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                      itemCount: expenses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final Expense expense = expenses[index];
                        final bool selected = _selectedIds.contains(expense.id);
                        return ExpenseListItem(
                          expense: expense,
                          selectionMode: _selectionMode,
                          isSelected: selected,
                          onToggleSelection: (bool value) {
                            _toggleSelection(expense.id, value);
                          },
                          onEdit: () => _openEditSheet(context, expense),
                          onDelete: () async {
                            final ExpenseProvider expenseProvider =
                                context.read<ExpenseProvider>();
                            final ScaffoldMessengerState messenger =
                                ScaffoldMessenger.of(context);
                            await expenseProvider.deleteExpense(expense.id);
                            if (!mounted) return;
                            setState(() {
                              _selectedIds.remove(expense.id);
                            });
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Expense deleted')),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({
    required this.totalCount,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onClear,
    required this.onDelete,
  });

  final int totalCount;
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 6,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('Selected: $selectedCount/$totalCount'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton(
                  onPressed: onSelectAll,
                  child: const Text('Select All'),
                ),
                TextButton(onPressed: onClear, child: const Text('Clear')),
                const SizedBox(width: 4),
                FilledButton.tonalIcon(
                  onPressed: selectedCount > 0 ? onDelete : null,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
