import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/root_screen.dart';
import 'controllers/app_state.dart';

void main() {
  runApp(const ControlTowerApp());
}

class ControlTowerApp extends StatelessWidget {
  const ControlTowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'ShipIt',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const RootScreen(),
      ),
    );
  }
}
