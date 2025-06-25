import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as FA;
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then((
    _,
  ) {
    NotificationService().init().then((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        runApp(runWithProvider(const MyApp(isLoggedIn: true)));
      } else {
        runApp(runWithProvider(const MyApp(isLoggedIn: false)));
      }
    });
  });
}

runWithProvider(Widget app) {
  return MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => FA.AuthProvider())],
    child: app,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;

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
