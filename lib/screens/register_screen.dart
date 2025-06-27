import 'package:flutter/material.dart';

import 'package:flutter_application_1/base_class.dart';
import 'package:flutter_application_1/models/country.dart';
import 'package:flutter_application_1/providers/country_provider.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/utils/app_constants.dart';
import 'package:flutter_application_1/widgets/text_form_field_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends BaseClass<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _countryController = TextEditingController();
  List<Country> _filteredCountries = [];
  @override
  void initState() {
    super.initState();
    // Fetch countries when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      countryProvider.getCountries();
    });
    initProvider();
  }

  @override
  void dispose() {
    _usernameController.dispose();
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
                  AppLocale().createAccount,
                  style: GoogleFonts.lato(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  AppLocale().signUpToGetStarted,
                  style: GoogleFonts.lato(fontSize: 18.0, color: Colors.blue),
                ),
                const SizedBox(height: 40.0),
                TextFormFieldWidget(
                  controller: _usernameController,
                  labelText: AppLocale().username,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocale().pleaseEnterYourUsername;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                Consumer<CountryProvider>(
                  builder: (context, countryProvider, child) {
                    return Stack(
                      alignment:
                          isArabic
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      children: [
                        TextFormFieldWidget(
                          enabled: !countryProvider.isLoading,
                          enableInteractiveSelection: false,
                          controller: _countryController,
                          labelText: AppLocale().country,
                          onTap: () {
                            if (countryProvider.countries.isNotEmpty) {
                              _showCountryPickerDialog(
                                countryProvider.countries,
                              );
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocale().pleaseSelectYourCountry;
                            }
                            return null;
                          },
                        ),
                        if (countryProvider.isLoading)
                          Container(
                            margin: EdgeInsets.only(
                              left: isArabic ? 10 : 0,
                              right: isArabic ? 0 : 10,
                            ),
                            height: 24,
                            width: 24,
                            child: SpinKitFadingCircle(
                              color: Color(0xFFddb12e),
                              size: 24,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20.0),
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
                      bool success = await authProvider.register(
                        context,
                        _usernameController.text,
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (mounted) {
                        if (success) {
                          gotoNextWithNoBack(HomeScreen());
                        } else {
                          showSnackBar(
                            authProvider.errorMessage ??
                                AppLocale().registrationFailed,
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
                            AppLocale().register,
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
                      AppLocale().alreadyHaveAnAccount,
                      style: GoogleFonts.lato(color: Colors.blue),
                    ),
                    TextButton(
                      onPressed: () {
                        onBackPress();
                      },
                      child: Text(
                        AppLocale().login,
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

  void _showCountryPickerDialog(List<Country> countries) {
    // Initialize filtered countries with the full list
    _filteredCountries = countries;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocale().country),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(hintText: 'Search...'),
                      onChanged: (value) {
                        setState(() {
                          _filteredCountries =
                              countries
                                  .where(
                                    (country) => country.name
                                        .toLowerCase()
                                        .contains(value.toLowerCase()),
                                  )
                                  .toList();
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredCountries.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_filteredCountries[index].name),
                            onTap: () {
                              _countryController.text =
                                  _filteredCountries[index].name;
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showCountryPicker() async {
    /* final country = await showCountryPicker(
      context: context,
      countryListTheme: const CountryListThemeData(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      onCountryChanged: (country) {
        _countryController.text = country.name;
      },
    );

    if (country != null) {
      _countryController.text = country.name;
    } */
  }
}
