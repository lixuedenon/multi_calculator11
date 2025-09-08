import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
        Locale('ja', 'JP'),
        Locale('ko', 'KR'),
        Locale('fr', 'FR'),
        Locale('de', 'DE'),
        Locale('es', 'ES'),
        Locale('ar', 'SA'),
      ],
      path: 'lib/assets/assets_lang',
      fallbackLocale: const Locale('zh', 'CN'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multi Calculator',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const MainScreen(),
    );
  }
}