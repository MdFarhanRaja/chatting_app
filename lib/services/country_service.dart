import 'package:flutter_application_1/network/api_call.dart';
import 'package:flutter_application_1/network/call_back_listeners.dart';
import 'package:flutter_application_1/network/method.dart';

enum CountryApiRequestCode { getCountries }

class CountryService {
  final ApiResponse _apiResponse;

  CountryService(this._apiResponse);

  Future<void> getCountries() async {
    await ApiCall.makeApiCall(
      CountryApiRequestCode.getCountries,
      null,
      Method.get,
      'all?fields=name',
      _apiResponse,
      baseUrl: 'https://restcountries.com/v3.1/',
    );
  }
}
