import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';


import 'app_exception.dart';
import 'simplified_uri.dart';

class ApiBaseHelper {
  static late String _baseUrl;

  ApiBaseHelper._internal();

  static final ApiBaseHelper _singleton = ApiBaseHelper._internal();

  factory ApiBaseHelper(baseUrl) {
    _baseUrl = baseUrl;
    return _singleton;
  }


  getApiCall({
    required String url,
    Map<String, dynamic>? queryParameters,
    Function(dynamic data)? onSuccess,
    Function(dynamic data)? onFailure,
    Function(bool loading)? loading,
  }) async {
    // ignore: prefer_typing_uninitialized_variables
    var apiResponse;
    log('get -${_baseUrl + url}');
    loading?.call(true);

    final Uri uri = SimplifiedUri.uri(_baseUrl + url, queryParameters);
    /*  String? xAuthToken = await Prefs.getAuthToken();
    log('XAuth token: $xAuthToken');
    if (xAuthToken != null) {
      xAuthToken = xAuthToken;
    }
*/
    try {
      final http.Response response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorizationToken': /*xAuthToken ??*/ '',
        },
      );
      log('Request: $queryParameters');
      try {
        apiResponse = _returnResponse(response: response);
        log('apiResponse: $apiResponse');
        loading?.call(false);
        onSuccess?.call(apiResponse);
        return apiResponse;
      } on UnauthorisedException {
        loading?.call(false);
      } catch (e) {
        apiResponse = json.decode(response.body.toString());
        loading?.call(false);
        onFailure?.call(apiResponse);
        return apiResponse;
      } finally {}
    } on SocketException {
      loading?.call(false);
      Map<String, String> jsonData = {'message': 'No Internet connection'};
      await Future.delayed(const Duration(seconds: 2));
      onFailure?.call(jsonData);
    }
  }

  postApiCall(
      {required String url,
      Map<String, dynamic>? queryParameters,
      Object? requestBody,
      Function(dynamic data)? onSuccess,
      Function(dynamic data)? onFailure,
      Function(bool loading)? loading}) async {
    /*  String? xAuthToken = await Prefs.getAuthToken();
    log('XAuth token: $xAuthToken');
    if (xAuthToken != null) {
      xAuthToken = xAuthToken;
    }*/

    // ignore: prefer_typing_uninitialized_variables
    var apiResponse;
    log('post -${_baseUrl + url}');
    loading?.call(true);
    try {
      final http.Response response = await http.post(
        SimplifiedUri.uri(_baseUrl + url, queryParameters),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorizationToken': /*xAuthToken ?? */ '',
        },
        body: requestBody != null ? jsonEncode(requestBody) : null,
      );

      try {
        debugPrint('Query parameters//////////////: $queryParameters ');

        log('Api Request//////////////: ${jsonEncode(requestBody)} ');

        apiResponse = _returnResponse(response: response);
        log('Api response:  ${response.body}');

        onSuccess?.call(apiResponse);
        loading?.call(false);
        return apiResponse;
      } catch (e) {
        loading?.call(false);
        log('Post api exception: $e');
        apiResponse = json.decode(response.body.toString());
        onFailure?.call(apiResponse);
        return apiResponse;
      } finally {
        loading?.call(false);
      }
    } on SocketException {
      log('Post api socket  exception: ');


      Map<String, String> jsonData = {'message': 'No Internet connection'};
      await Future.delayed(const Duration(seconds: 2));
      onFailure?.call(jsonData);
      // throw FetchDataException('No Internet connection');
    }
  }

  callMultipartApi(
      {required String apiName,
      required dynamic requestBody,
      Map<String, String>? headers,
      List<File>? images,
      String? fileParamName,
      String? requestType,
      Function(dynamic onSucessJson)? onSuccess,
      Function(dynamic onFailureJson)? onFailure,
      Function(bool isLoading)? loading}) async {
    //  String? xAuthToken = await Prefs.getAuthToken();

    loading?.call(true);
    log('Api images:  ${images?.toList()}');
    var request = http.MultipartRequest(
        requestType ?? 'POST', Uri.parse(_baseUrl + apiName));
    request.headers.addAll(headers ??
        <String, String>{
          "Content-Type": "multipart/form-data",
          "Accept": "application/json",
          "authorizationToken": /*xAuthToken ?? */ ''
        });

    if (fileParamName != null && images != null) {
      for (int i = 0; i < images.length; i++) {
        request.files.add(http.MultipartFile(
            'Photo', images[i].readAsBytes().asStream(), images[i].lengthSync(),
            filename: basename(images[i].path)));
      }
    }
    log('Api Request fields:  ${request.fields}');
    Map<String, String> map = {
      "RequestModel": requestBody,
    };
    request.fields.addAll(map);
    // ignore: prefer_typing_uninitialized_variables
    var apiResponse;

    http.Response response =
        await http.Response.fromStream(await request.send());
    try {
      log('Api Request:  $map');

      apiResponse = _returnResponse(response: response);
      log('Response:  ${response.body}');
      loading?.call(false);

      onSuccess?.call(apiResponse);
    } catch (e) {
      log('Error from network util ${e.toString()}');

      apiResponse = json.decode(response.body.toString());
      loading?.call(false);
      onFailure?.call(apiResponse);
    } finally {
      loading?.call(false);
    }

    return apiResponse;
  }

  dynamic _returnResponse({required http.Response response}) {
    switch (response.statusCode) {
      case 200:
      case 505:
        var responseJson = json.decode(response.body.toString());
        // log(responseJson.toString());
        return responseJson;
      case 201:
        var responseJson = json.decode(response.body.toString());
        // log(responseJson.toString());
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());

      case 401:
        throw UnauthorisedException(response.body.toString());
      case 403:
        throw ForbiddenException(response.body.toString());

      case 404:
        throw NotFoundException(response.body.toString());
      case 500:
        throw InternalServerErrorException(response.body.toString());

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
