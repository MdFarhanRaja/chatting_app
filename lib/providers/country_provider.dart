import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/country.dart';
import 'package:flutter_application_1/providers/base_provider.dart';
import 'package:flutter_application_1/services/country_service.dart';

import 'package:flutter_application_1/network/call_back_listeners.dart';

class CountryProvider extends BaseProvider implements ApiResponse {
  late CountryService _countryService;
  List<Country> _countries = [];
  bool _isLoading = false;

  List<Country> get countries => _countries;
  bool get isLoading => _isLoading;

  CountryProvider() {
    _countryService = CountryService(this);
  }

  Future<void> getCountries() async {
    _isLoading = true;
    notifyListeners();
    await _countryService.getCountries();
  }

  @override
  void onError(String error, int statusCode, Enum requestCode) {
    _isLoading = false;
    notifyListeners();
    // You can add more robust error handling here
    debugPrint('Error fetching countries: $error');
  }

  @override
  void onResponse(String response, int statusCode, Enum requestCode) {
    if (requestCode == CountryApiRequestCode.getCountries) {
      final List<dynamic> countryList = json.decode(response);
      _countries = countryList.map((data) => Country.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    }
  }
}
