import 'dart:io';

import 'api_factory_provider.dart';

abstract class ApiWithoutBodyBase extends ApiFactoryProvider {
  callApi(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Function(bool loading)? loading,
  });
}

abstract class ApiWithBodyBase extends ApiFactoryProvider {
  callApi(
    String url,
    Map<String, dynamic>? body, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Function(bool loading)? loading,
  });
}

abstract class ApiMultiPartBase extends ApiFactoryProvider {
  callApi(
    String url,
    Map<String, String>? body,
    List<File>? files,
    String? fileParamName, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? requestType,
    Function(bool loading)? loading,
  });
}







/* TODO NOT NEEDED AT THE TIME
     Function(dynamic data)? onSuccess,
    Function(dynamic data)? onFailure,*/
