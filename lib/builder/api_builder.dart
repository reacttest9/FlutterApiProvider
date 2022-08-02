import '../apis/api_base_helper.dart';
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
      {Function(dynamic)? onSuccess,
      Function(dynamic)? onFailure,
      R? request}) async {
    final ApiBaseHelper apiBaseHelper = ApiBaseHelper(_baseUrl);


    var json = await apiBaseHelper.getApiCall(
      url: endPoint ?? "",
      loading: onLoading,
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
    return parser(json);
  }
}
