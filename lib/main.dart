import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'background/alertas_background.dart';
import 'config/app_localizacao.dart';
import 'navigation/app_navigator.dart';
import 'providers/alertas_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/login_provider.dart';
import 'providers/navegacao_provider.dart';
import 'providers/veiculos_provider.dart';
import 'screens/login_screen.dart';
import 'services/notificacoes_alerta_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacoesAlertaService.initialize();
  await Workmanager().initialize(alertasBackgroundDispatcher);
  runApp(const VeiculosApp());
}

class VeiculosApp extends StatelessWidget {
  const VeiculosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => NavegacaoProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => VeiculosProvider()),
        ChangeNotifierProvider(create: (_) => AlertasProvider()),
      ],
      child: MaterialApp(
        title: 'Veículos',
        debugShowCheckedModeBanner: false,
        navigatorKey: appNavigatorKey,
        theme: AppTheme.dark,
        locale: AppLocalizacao.locale,
        supportedLocales: AppLocalizacao.supportedLocales,
        localizationsDelegates: AppLocalizacao.delegates,
        home: const LoginScreen(),
      ),
    );
  }
}
