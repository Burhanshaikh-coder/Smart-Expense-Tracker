import 'package:flutter/material.dart';
import 'package:my_expense/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'database/local_database.dart';
import 'providers/expense_provider.dart';
import 'services/expense_repository.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ExpenseRepository repository = ExpenseRepository(LocalDatabase());
  final ExpenseProvider provider = ExpenseProvider(repository);
  await provider.bootstrap();
  runApp(SmartExpenseTrackerApp(provider: provider));
}

class SmartExpenseTrackerApp extends StatelessWidget {
  const SmartExpenseTrackerApp({super.key, required this.provider});

  final ExpenseProvider provider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExpenseProvider>.value(
      value: provider,
      child: Consumer<ExpenseProvider>(
        builder: (BuildContext context, ExpenseProvider appState, _) {
          return MaterialApp(
            title: 'Smart Expense Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: appState.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
