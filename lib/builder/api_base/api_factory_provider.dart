import 'package:api_provider_builder/builder/api_base/api_logic/delete_api.dart';
import 'package:api_provider_builder/builder/api_base/api_logic/get_api.dart';
import 'package:api_provider_builder/builder/api_base/api_logic/post_api.dart';
import 'package:api_provider_builder/builder/enums/api_methods_type.dart';

import 'api_logic/post_with_multipart_api.dart';
import 'api_logic/put_api.dart';

class ApiFactoryProvider {

  ApiFactoryProvider();  //Default constructor


  factory ApiFactoryProvider.provideApi(ApiMethodTypes types) {
    switch (types) {
      case ApiMethodTypes.get:
        return GetApi();
      case ApiMethodTypes.post:
        return PostApi();
      case ApiMethodTypes.postWithMultipart:
        return PostWithMultipartApi();
      case ApiMethodTypes.put:
        return PutApi();
      case ApiMethodTypes.delete:
        return DeleteApi();
      default:
        return GetApi();
    }
  }
}
