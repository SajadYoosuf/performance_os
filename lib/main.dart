import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// Repositories
import 'package:app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:app/features/tasks/data/repositories/firebase_task_repository.dart';
import 'package:app/features/reflection/data/repositories/firebase_reflection_repository.dart';
import 'package:app/features/dashboard/data/repositories/firebase_daily_score_repository.dart';
// Providers
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/tasks/presentation/providers/task_provider.dart';
import 'package:app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:app/features/reflection/presentation/providers/reflection_provider.dart';
import 'package:app/features/insights/presentation/providers/insight_provider.dart';
// Theme
import 'package:app/core/theme/app_theme.dart';
// Screens
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/dashboard/presentation/screens/home_shell.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PerformanceOSApp());
}

class PerformanceOSApp extends StatelessWidget {
  const PerformanceOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Repository instances
    final authRepo = FirebaseAuthRepository();
    final taskRepo = FirebaseTaskRepository();
    final reflectionRepo = FirebaseReflectionRepository();
    final dailyScoreRepo = FirebaseDailyScoreRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepo)),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(scoreRepository: dailyScoreRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ReflectionProvider(reflectionRepo),
        ),
        ChangeNotifierProvider(create: (_) => InsightProvider()),
      ],
      child: MaterialApp(
        title: 'Performance OS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(isWeb: kIsWeb),
        darkTheme: AppTheme.dark(isWeb: kIsWeb),
        themeMode: ThemeMode.light,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const HomeShell();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
