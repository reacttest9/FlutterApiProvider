import 'dart:convert';
import 'dart:io';

import 'package:api_provider_builder/debug_utils/debug_utils.dart';

import '../../api_util/app_exception.dart';
import '../../api_util/response_parser.dart';
import '../../api_util/simplified_uri.dart';
import '../api_base.dart';
import 'package:http/http.dart' as http;

class GetApi extends ApiWithoutBodyBase {
  @override
  Future<Map<String, dynamic>?> callApi(String url,
      {Map<String, dynamic>? queryParameters,
      Map<String, String>? headers,
      Function(bool loading)? loading}) async {
    Map<String, dynamic>? apiResponse;
    DebugUtils.showLog(url, prefix: 'get -');
    loading?.call(true);
    final Uri uri = SimplifiedUri.uri(url, queryParameters ?? {});
    try {
      final http.Response response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (headers != null) ...headers
        },
      );
      DebugUtils.showLog('Request: $queryParameters');
      try {
        apiResponse = returnResponse(response: response);

        DebugUtils.showLog('apiResponse: $apiResponse');

        loading?.call(false);
        return apiResponse;
      } on UnauthorisedException {
        loading?.call(false);
      } catch (e) {
        apiResponse = json.decode(response.body.toString());
        loading?.call(false);
        return apiResponse;
      }
    } on SocketException {
      loading?.call(false);
      throw SocketException;
    }
    return null;
  }
}
