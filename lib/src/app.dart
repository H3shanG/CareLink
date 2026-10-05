import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class CareLinkApp extends StatelessWidget {
  const CareLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareLink',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const Scaffold(body: Center(child: Text('CareLink'))),
    );
  }
}
