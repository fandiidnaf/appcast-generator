import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/appcast_provider.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const AppcastGeneratorApp());
}

class AppcastGeneratorApp extends StatelessWidget {
  const AppcastGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AppcastProvider()..addItem(), // start with one example item
      child: MaterialApp(
        title: 'Appcast Generator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
