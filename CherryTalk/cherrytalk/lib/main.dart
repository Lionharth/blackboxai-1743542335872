import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:cherrytalk/services/matrix_service.dart';
import 'package:cherrytalk/ui/splash_screen.dart';
import 'package:cherrytalk/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure error handling
  FlutterError.onError = (details) {
    if (kReleaseMode) {
      log('FLUTTER ERROR: ${details.exceptionAsString()}',
          stackTrace: details.stack,
          level: 1000,
          name: 'CRITICAL');
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  runZonedGuarded(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MatrixService()),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stackTrace) {
    if (kReleaseMode) {
      log('UNCAUGHT ERROR: $error',
          stackTrace: stackTrace,
          level: 1000,
          name: 'CRITICAL');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CherryTalk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
