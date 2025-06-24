import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import '../base_class.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseClass<HomeScreen> {
  @override
  void initState() {
    super.initState();
    initProvider();
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      changeSystemUiColor(
        statusBarColor: Colors.white,
        navBarColor: Colors.white,
        brightness: Brightness.dark,
        navBrightness: Brightness.dark,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Home'),
        actions: [
          IconButton(
            icon: const CircleAvatar(child: Icon(Icons.person)),
            onPressed: () {
              gotoNext(const ProfileScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.black),
            onPressed: () {
              showLogoutDialog();
            },
          ),
        ],
      ),
      body: Center(child: Text('Welcome!')),
    );
  }
}
