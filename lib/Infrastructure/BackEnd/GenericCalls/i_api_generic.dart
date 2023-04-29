import 'package:fs_front/Core/DTO/Generic/check_value_request.dart';

import '../../../Core/DTO/Generic/check_value_response.dart';
import '../api_call.dart';

abstract class IApiGeneric extends ApiCall {
  Future<CheckValueResponse> checkValue({required CheckValueRequest checkValueRequest});
}