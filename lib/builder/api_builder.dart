library api_builder_provider;

import 'dart:io';

import 'package:api_provider_builder/builder/api_base/api_factory_provider.dart';
import 'package:api_provider_builder/builder/api_base/api_logic/delete_api.dart';
import 'package:api_provider_builder/builder/api_base/api_logic/get_api.dart';
import 'package:api_provider_builder/builder/api_base/api_logic/post_api.dart';
import 'package:api_provider_builder/builder/api_base/api_logic/post_with_multipart_api.dart';
import 'package:api_provider_builder/builder/api_base/api_logic/put_api.dart';

import 'enums/api_methods_type.dart';

abstract class JsonConvert {
  JsonConvert.fromJson(Map<String, dynamic> map);
}

class ApiBuilder {
  static late String _baseUrl;

  ApiBuilder._();

  static ApiBuilder? _apiBuilder;

  ApiBuilder.init(String? baseUrl) {
    /*--------------------Check if base url not null------------------*/
    assert(baseUrl != null && baseUrl.isNotEmpty);

    /*--------------------init values------------------*/
    _baseUrl = baseUrl!;
    _apiBuilder = ApiBuilder._();
  }

  factory ApiBuilder.getInstance() {
    try {
      return _apiBuilder!;
    } catch (e) {
      throw 'Please init ApiBuilder first';
    }
  }

  Future<T> callApi<R, T>(String? endPoint, ApiMethodTypes type,
      Function(bool) onLoading, Function(Map<String, dynamic>) parser,
      {Map<String, String>? headers,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? body,
      List<File>? files,
      String? fileParamName,
      R? request}) async {
    final ApiFactoryProvider apiFactoryProvider =
        ApiFactoryProvider.provideApi(type);
    Map<String, dynamic>? json;

    if (apiFactoryProvider is GetApi) {
      json = await apiFactoryProvider.callApi(_baseUrl + (endPoint ?? ""),
          headers: headers ?? {},
          loading: onLoading,
          queryParameters: queryParameters);
    } else if (apiFactoryProvider is PostApi) {
      json = await apiFactoryProvider.callApi(_baseUrl + (endPoint ?? ""), body,
          headers: headers ?? {},
          loading: onLoading,
          queryParameters: queryParameters);
    } else if (apiFactoryProvider is PutApi) {
      json = await apiFactoryProvider.callApi(_baseUrl + (endPoint ?? ""), body,
          headers: headers ?? {},
          loading: onLoading,
          queryParameters: queryParameters);
    } else if (apiFactoryProvider is DeleteApi) {
      json = await apiFactoryProvider.callApi(_baseUrl + (endPoint ?? ""), body,
          headers: headers ?? {},
          loading: onLoading,
          queryParameters: queryParameters);
    } else if (apiFactoryProvider is PostWithMultipartApi) {
      json = await apiFactoryProvider.callApi(_baseUrl + (endPoint ?? ""),
          body?.cast<String, String>(), files, fileParamName,
          headers: headers ?? {},
          loading: onLoading,
          queryParameters: queryParameters);
    }
    return parser(json ?? {});

    /*

      TODO UNCOMMENT AND USE IF NEEDED
      Function(dynamic)? onSuccess,
      Function(dynamic)? onFailure,

     var json = await apiBaseHelper.getApiCall(
      url: endPoint ?? "",
      loading: onLoading,
    );
    return parser(json);

    */
  }
}
