import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// Core
import 'package:app/core/services/local_storage_service.dart';
import 'package:app/core/services/notification_service.dart';
// Local Repositories
import 'package:app/features/tasks/data/repositories/local_task_repository.dart';
import 'package:app/features/reflection/data/repositories/local_reflection_repository.dart';
import 'package:app/features/dashboard/data/repositories/local_daily_score_repository.dart';
// Firebase Repositories
import 'package:app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:app/features/tasks/data/repositories/firebase_task_repository.dart';
import 'package:app/features/reflection/data/repositories/firebase_reflection_repository.dart';
import 'package:app/features/dashboard/data/repositories/firebase_daily_score_repository.dart';
// Hybrid Repositories
import 'package:app/features/tasks/data/repositories/hybrid_task_repository.dart';
import 'package:app/features/reflection/data/repositories/hybrid_reflection_repository.dart';
import 'package:app/features/dashboard/data/repositories/hybrid_daily_score_repository.dart';
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

  // Initialise Hive-based local storage.
  final localStorage = LocalStorageService();
  await localStorage.init();

  // Initialise notification service.
  await NotificationService().init();

  runApp(PerformanceOSApp(localStorage: localStorage));
}

class PerformanceOSApp extends StatelessWidget {
  final LocalStorageService localStorage;

  const PerformanceOSApp({super.key, required this.localStorage});

  @override
  Widget build(BuildContext context) {
    // ── Auth ──
    final authRepo = FirebaseAuthRepository();

    // ── Local repos ──
    final localTaskRepo = LocalTaskRepository(localStorage);
    final localReflectionRepo = LocalReflectionRepository(localStorage);
    final localDailyScoreRepo = LocalDailyScoreRepository(localStorage);

    // ── Firebase repos ──
    final firebaseTaskRepo = FirebaseTaskRepository();
    final firebaseReflectionRepo = FirebaseReflectionRepository();
    final firebaseDailyScoreRepo = FirebaseDailyScoreRepository();

    // ── Hybrid repos: local-first + Firebase background sync ──
    final taskRepo = HybridTaskRepository(
      local: localTaskRepo,
      remote: firebaseTaskRepo,
    );
    final reflectionRepo = HybridReflectionRepository(
      local: localReflectionRepo,
      remote: firebaseReflectionRepo,
    );
    final dailyScoreRepo = HybridDailyScoreRepository(
      local: localDailyScoreRepo,
      remote: firebaseDailyScoreRepo,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepo, localStorage),
        ),
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
