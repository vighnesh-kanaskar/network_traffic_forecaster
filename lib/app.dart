import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'theme/app_theme.dart';

class SIH26153App extends StatelessWidget {
  const SIH26153App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIH26153 Network Intelligence',
      debugShowCheckedModeBanner: false,

      // Template 6 — Light humanized theme
      theme: AppTheme.lightTheme,

      home: const AppShell(),
    );
  }
}
