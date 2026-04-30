import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';
import 'core/services/crash_reporting_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  await sl<NotificationService>().initialize();
  await sl<CrashReportingService>().initialize();
  runApp(const LigeirinhoFoodApp());
}

class LigeirinhoFoodApp extends StatelessWidget {
  const LigeirinhoFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ligeirinho Food',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
