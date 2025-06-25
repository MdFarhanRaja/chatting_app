import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/notification_provider.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/utils/app_prefs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart' as FA;
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then((
    value,
  ) {
    NotificationService().init().then((value) {
      final user = FirebaseAuth.instance.currentUser;
      runApp(runWithProvider(MyApp(user != null)));
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
    ],
    child: app,
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp(this.isLoggedIn, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatterBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
      ),
      home: isLoggedIn ? const HomeScreen() : const SplashScreen(),
    );
  }
}
