import 'package:dio/dio.dart';

import 'api_constants.dart';

class ApiClient {
  static const TIMEOUT_TIME = Duration(minutes: 5);

  //static const int TIMEOUT_TIME = 90 * 1000;

  static Dio getInstance({String? baseUrl}) {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl ?? ApiConstants.baseUrl,
      connectTimeout: TIMEOUT_TIME,
      receiveTimeout: TIMEOUT_TIME,
    );

    Dio dio = Dio(options);
    /* dio.interceptors.add(PrettyDioLogger());

    dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: false,
        compact: true,
        maxWidth: 90)); */
    return dio;
  }

  static getHttpInstance() {}
}
