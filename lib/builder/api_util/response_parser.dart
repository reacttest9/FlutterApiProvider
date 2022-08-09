import 'dart:convert';
import 'package:http/http.dart' as http;

import 'app_exception.dart';

dynamic returnResponse({required http.Response response}) {
  switch (response.statusCode) {
    case 200:
    case 505:
      var responseJson = json.decode(response.body.toString());
      return responseJson;
    case 201:
      var responseJson = json.decode(response.body.toString());
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
