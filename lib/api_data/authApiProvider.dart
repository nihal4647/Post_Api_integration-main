

import 'package:dio/dio.dart';
import 'package:post_api/api_data/Injector.dart';
import 'package:post_api/api_data/UserModel.dart';
import 'package:post_api/api_data/data_response.dart';

class AuthApiProvider {
  late Dio _dio;

  AuthApiProvider() {
    _dio = Injector().getDio();
  }

  Future<DataResponse<UserModel?>> login(UserModel userModel) async {
    try {
      Response response = await _dio.post("http://3.20.42.152:8018/api/login", data: userModel);
      var datResponse = DataResponse<UserModel>.fromJson(response.data,
          (data) => UserModel.fromJson(data as Map<String, dynamic>));
      return datResponse;
    } catch (error) {
      final res = (error as dynamic).response;
      if (res != null) return DataResponse.fromJson(res?.data, (data) => null);
      return DataResponse(code: 0, message: error.toString());
    }
  }
}
