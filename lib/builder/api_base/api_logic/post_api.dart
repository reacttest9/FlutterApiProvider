import 'dart:convert';
import 'dart:io';

import 'package:api_provider_builder/debug_utils/debug_utils.dart';
import 'package:http/http.dart' as http;

import '../../api_util/response_parser.dart';
import '../../api_util/simplified_uri.dart';
import '../api_base.dart';

class PostApi extends ApiWithBodyBase {
  @override
  callApi(String url, Map<String, dynamic>? body,
      {Map<String, String>? headers,
      Map<String, dynamic>? queryParameters,
      Function(bool loading)? loading}) async {
    dynamic apiResponse;
    loading?.call(true);
    try {
      final http.Response response = await http.post(
        SimplifiedUri.uri(url, queryParameters),
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (headers != null) ...headers
        },
        body: body != null ? jsonEncode(body) : null,
      );

      try {
        DebugUtils.showLog('Query parameters//////////////: $queryParameters ');
        DebugUtils.showLog('Api Request//////////////: ${jsonEncode(body)} ');

        apiResponse = returnResponse(response: response);
        DebugUtils.showLog('Api response:  ${response.body}');
        loading?.call(false);
        return apiResponse;
      } catch (e) {
        loading?.call(false);
        DebugUtils.showLog('Post api exception: $e');
        apiResponse = json.decode(response.body.toString());
        return apiResponse;
      } finally {
        loading?.call(false);
      }
    } on SocketException {
      rethrow;
    }
  }
}
