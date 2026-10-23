import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

// --- Firebase désactivé temporairement le temps de finir le front ---
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // TODO : réactiver ce bloc une fois `flutterfire configure` exécuté,
  // à la fin du développement du front (voir routes/app_router.dart
  // pour le TODO équivalent sur la protection des routes par rôle).

  runApp(const ProviderScope(child: LivoApp()));
}

class LivoApp extends ConsumerWidget {
  const LivoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Livo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      locale: const Locale('fr', 'BJ'),
      supportedLocales: const [Locale('fr', 'BJ')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
