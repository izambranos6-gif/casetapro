import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme.dart';
import 'pages/zone_page.dart';
import 'state/app_scope.dart';
import 'state/feed_controller.dart';

class CasetaProApp extends StatelessWidget {
  const CasetaProApp({super.key, required this.controller});
  final FeedController controller;

  @override
  Widget build(BuildContext context) => AppScope(
    controller: controller,
    child: MaterialApp(
      title: 'CasetaPro',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ZonePage(),
    ),
  );
}
