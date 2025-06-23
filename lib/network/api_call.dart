import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'api_client.dart';
import 'api_constants.dart';
import 'call_back_listeners.dart';
import 'method.dart';

class ApiCall {
  static Future<void> makeApiCall(
    Enum requestCode,
    Map<String, dynamic>? params,
    Method apiMethod,
    String apiName,
    ApiResponse apiResponse, {
    String? baseUrl,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    String? authorization,
    String contentType = 'application/json',
  }) async {
    var dio = ApiClient.getInstance(baseUrl: baseUrl);
    dio.options.headers['Content-Type'] = contentType;
    dio.options.headers["Authorization"] = authorization;
    switch (apiMethod) {
      case Method.get:
        {
          debugPrint(
            "GET Api:${ApiConstants.baseUrl}$apiName Params: $queryParameters",
          );
          dio
              .get(apiName, queryParameters: queryParameters)
              .then((value) {
                //debugPrint(value.data.toString());
                apiResponse.onResponse(
                  json.encode(value.data),
                  value.statusCode!,
                  requestCode,
                );
              })
              .catchError((err) {
                try {
                  if (err is DioException) {
                    debugPrint('Dio Error....${err.response!.data}');
                    apiResponse.onError(
                      json.encode(err.response!.data),
                      err.response!.statusCode!,
                      requestCode,
                    );
                  } else {
                    debugPrint('Not Dio Error....${err.toString()}');
                    apiResponse.onError(err.toString(), 01, requestCode);
                  }
                } catch (e) {
                  debugPrint('catchError Error.... ${err.toString()}');
                  apiResponse.onError(err.toString(), 02, requestCode);
                }
              });
        }
        break;
      case Method.post:
        {
          dio
              .post(
                apiName,
                queryParameters: queryParameters,
                data: params != null ? jsonEncode(params) : null,
              )
              .then((value) async {
                apiResponse.onResponse(
                  json.encode(value.data),
                  value.statusCode!,
                  requestCode,
                );
              })
              .catchError((err) {
                try {
                  if (err is DioException) {
                    debugPrint('Dio Error....${err.response!.data}');
                    apiResponse.onError(
                      json.encode(err.response!.data),
                      err.response!.statusCode!,
                      requestCode,
                    );
                  } else {
                    debugPrint('Not Dio Error....${err.toString()}');
                    apiResponse.onError(err.toString(), 01, requestCode);
                  }
                } catch (e) {
                  debugPrint('catchError Error.... ${err.toString()}');
                  apiResponse.onError(err.toString(), 02, requestCode);
                }
              });
        }
        break;
    }
  }
}
