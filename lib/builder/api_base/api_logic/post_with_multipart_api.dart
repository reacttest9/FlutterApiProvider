import 'dart:convert';
import 'dart:io';

import 'package:api_provider_builder/debug_utils/debug_utils.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../../api_util/response_parser.dart';
import '../api_base.dart';

class PostWithMultipartApi extends ApiMultiPartBase {
  @override
  callApi(String url, Map<String, String>? body, List<File>? files,
      String? fileParamName,
      {Map<String, String>? headers,
      Map<String, dynamic>? queryParameters,
      String? requestType,
      Function(bool loading)? loading}) async {
    loading?.call(true);
    DebugUtils.showLog('Api images:  ${files?.toList()}');
    var request = http.MultipartRequest(requestType ?? 'POST', Uri.parse(url));
    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      "Accept": "application/json",
      if (headers != null) ...headers
    });

    if (fileParamName != null && files != null) {
      for (int i = 0; i < files.length; i++) {
        request.files.add(http.MultipartFile(
            'Photo', files[i].readAsBytes().asStream(), files[i].lengthSync(),
            filename: basename(files[i].path)));
      }
    }
    DebugUtils.showLog('Api Request fields:  ${request.fields}');

    request.fields.addAll(body ?? {});
    dynamic apiResponse;

    http.Response response =
        await http.Response.fromStream(await request.send());
    try {
      DebugUtils.showLog('Api Request:  $body');
      apiResponse = returnResponse(response: response);
      DebugUtils.showLog('Response:  ${response.body}');
      loading?.call(false);
    } catch (e) {
      DebugUtils.showLog('Error from network util ${e.toString()}');
      loading?.call(false);
      apiResponse = json.decode(response.body.toString());
      return apiResponse;
    } finally {
      loading?.call(false);
    }

    return apiResponse;
  }
}
