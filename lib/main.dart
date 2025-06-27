import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/base_class.dart';
import 'package:flutter_application_1/providers/notification_provider.dart';
import 'package:flutter_application_1/providers/country_provider.dart';
import 'package:flutter_application_1/providers/chat_provider.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'providers/app_locale_provider.dart';
import 'providers/auth_provider.dart' as FA;
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then((
    value,
  ) {
    NotificationService().init().then((value) {
      final user = FirebaseAuth.instance.currentUser;
      AppPref.getAppLocale().then((language) async {
        runApp(runWithProvider(Splash(language, user != null)));
      });
    });
  });
}

Widget runWithProvider(Widget app) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => FA.AuthProvider()),
      ChangeNotifierProxyProvider<FA.AuthProvider, NotificationProvider>(
        create:
            (context) => NotificationProvider(
              Provider.of<FA.AuthProvider>(
                context,
                listen: false,
              ).notificationService,
            ),
        update:
            (context, auth, previous) =>
                NotificationProvider(auth.notificationService),
      ),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
      ChangeNotifierProvider(create: (_) => AppLocaleProvider()),
      ChangeNotifierProvider(create: (_) => CountryProvider()),
    ],
    child: app,
  );
}

class Splash extends StatefulWidget {
  String language;
  final bool isLoggedIn;
  Splash(this.language, this.isLoggedIn, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ViewSplash(language, isLoggedIn);
  }
}

class _ViewSplash extends BaseClass<Splash> {
  final bool isLoggedIn;
  final String language;
  _ViewSplash(this.language, this.isLoggedIn);

  @override
  void initState() {
    context.read<AppLocaleProvider>().setLocale(Locale(language));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLocaleProvider>(
      builder:
          (context, p, child) => MaterialApp(
            title: 'ChatterBox',
            debugShowCheckedModeBanner: false,
            locale: p.locale,
            supportedLocales: L10N.appLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              primarySwatch: Colors.teal,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
            ),
            home: isLoggedIn ? const HomeScreen() : const SplashScreen(),
          ),
    );
  }
}
