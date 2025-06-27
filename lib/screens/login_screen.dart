import 'package:flutter_application_1/screens/forgot_password_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:flutter_application_1/utils/app_constants.dart';
import 'package:flutter_application_1/widgets/text_form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../base_class.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseClass<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initProvider();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ImageIcon(AssetImage('assets/icons/arabic.png')),
            onPressed: () {
              if (appLocaleProvider.locale.languageCode == 'ar') {
                appLocaleProvider.changeLocale(language: 'en');
                log('Locale Changed....');
              } else {
                appLocaleProvider.changeLocale(language: 'ar');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppLocale().welcomeBack,
                  style: GoogleFonts.lato(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  AppLocale().loginToYourAccount,
                  style: GoogleFonts.lato(fontSize: 18.0, color: Colors.blue),
                ),
                const SizedBox(height: 40.0),
                TextFormFieldWidget(
                  controller: _emailController,
                  labelText: AppLocale().email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocale().pleaseEnterYourEmail;
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return AppLocale().pleaseEnterAValidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormFieldWidget(
                  controller: _passwordController,
                  labelText: AppLocale().password,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocale().pleaseEnterYourPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    gotoNext(ForgotPasswordScreen());
                  },
                  child: Text(
                    AppLocale().forgotPassword,
                    style: GoogleFonts.lato(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF2980B9),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool success = await authProvider.login(
                        context,
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (mounted) {
                        if (success) {
                          gotoNextWithNoBack(HomeScreen());
                        } else {
                          showSnackBar(
                            authProvider.errorMessage ??
                                AppLocale().loginFailed,
                            msgType: AppConstants.ERROR,
                          );
                        }
                      }
                    }
                  },
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return authProvider.isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          )
                          : Text(
                            AppLocale().login,
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      AppLocale().dontHaveAnAccount,
                      style: GoogleFonts.lato(color: Colors.blue),
                    ),
                    TextButton(
                      onPressed: () {
                        gotoNext(RegisterScreen());
                      },
                      child: Text(
                        AppLocale().register,
                        style: GoogleFonts.lato(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
