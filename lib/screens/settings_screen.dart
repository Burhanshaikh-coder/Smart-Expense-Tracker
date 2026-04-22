import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseProvider provider = context.watch<ExpenseProvider>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 15),
                  Center(
                    child: SizedBox(
                      width: 300, // 🔥 increase width
                      height: 50, // 🔥 increase height
                      child: SegmentedButton<ThemeMode>(
                        segments: const <ButtonSegment<ThemeMode>>[
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode_rounded),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode_rounded),
                          ),
                        ],
                        selected: <ThemeMode>{provider.themeMode},

                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              // 🔥 Selected color
                              return provider.themeMode == ThemeMode.light
                                  ? Colors.yellow.shade900 // Light selected → Yellow
                                  : Colors.blueGrey; // Dark selected → Black
                            }
                            return Colors.grey.shade200; // unselected
                          }),
                          foregroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.white;
                            }
                            return Colors.black;
                          }),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        onSelectionChanged: (Set<ThemeMode> values) {
                          provider.setThemeMode(values.first);
                        },
                      ),
                    ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Currency',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: provider.currencyCode,
                    decoration: const InputDecoration(
                      labelText: 'Select currency',
                    ),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'INR',
                        child: Text('INR (₹)'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'USD',
                        child: Text('USD (\$)'),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        provider.setCurrencyCode(value);
                      }
                    },
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Date Format',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: provider.datePattern,
                    decoration: const InputDecoration(
                      labelText: 'Select date format',
                    ),
                    items:  <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'dd MMM yyyy',
                        child: Text('dd MMM yyyy'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'dd/MM/yyyy',
                        child: Text('dd/MM/yyyy'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'MM-dd-yyyy',
                        child: Text('MM-dd-yyyy'),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        provider.setDatePattern(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
