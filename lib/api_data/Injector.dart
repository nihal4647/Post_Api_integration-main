import 'dart:convert';
import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:post_api/api_data/data_response.dart';


class Injector {
  static final Injector _singleton = Injector._internal();
  static final _dio = Dio();

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  Dio getDio(){
    BaseOptions options =
    BaseOptions(receiveTimeout: 180000, connectTimeout: 180000);
    _dio.options = options;
    _dio.options.followRedirects = false;
    _dio.options.headers["Content-Type"] = "application/json";
    _dio.options.headers["security_key"] =  "vismed";
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    _dio.interceptors.clear();
    _dio.interceptors.add(LoggingInterceptors());
    return _dio;
  }

  /*static Options? getHeaderToken(){
    String? token = SharedPreferenceHelper().getUserToken();
    if (token != null) {
      print("token=" + token);
      String? userId = SharedPreferenceHelper().getUserId().toString();
      if (userId != null) {
        print("userId=" + userId.toString());
      }
      var headerOptions =
      Options(headers: {
        'Authorization': 'Bearer $token',
      });
      return headerOptions;
    }
    else{
      var headerOptions =
      Options(headers: {
        'security_key' : ApiConstants.securityKey
      });
      return headerOptions;
    }
  }*/
}

class LoggingInterceptors extends Interceptor {

  String printObject(Object object) {
    // Encode your object and then decode your object to Map variable
    Map jsonMapped = json.decode(json.encode(object));

    // Using JsonEncoder for spacing
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');

    // encode it to string
    String prettyPrint = encoder.convert(jsonMapped);
    return prettyPrint;
  }
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print(
        "--> ${options.method.toUpperCase()} ${"" + (options.baseUrl) + (options.path)}");
    print("Headers:");
    options.headers.forEach((k, v) => print('$k: $v'));
    print("queryParameters:");
    options.queryParameters.forEach((k, v) => print('$k: $v'));
    if (options.data != null) {
      try{
        // print("Body: ${printObject(options.data)}");
        FormData formData = options.data as FormData;
        print("Body:");
        var buffer = [];
        for(MapEntry<String, String> pair in formData.fields){
          buffer.add(pair.key+ ':' + pair.value);
        }
        print("Body:{${buffer.join(', ')}}");
      }catch(e){
        print("Body: ${printObject(options.data)}");
      }
    }
    print("--> END ${options.method != null ? options.method.toUpperCase() : 'METHOD'}");
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioError dioError, ErrorInterceptorHandler handler) {
    print(
        "<-- ${dioError.message} ${(dioError.response?.requestOptions != null ?
        (dioError.response!.requestOptions.baseUrl + dioError.response!.requestOptions.path) : 'URL')}");
    print(
        "${dioError.response != null ? dioError.response!.data : 'Unknown Error'}");
    print("<-- End error");
    if(dioError.response!.statusCode==401) {
      var errorModel =  DataResponse.fromJson(dioError.response!.data, (data) => null);

      return;
    }
    return super.onError(dioError, handler);


  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        "<-- ${response.statusCode} ${(response.requestOptions != null ?
        (response.requestOptions.baseUrl + response.requestOptions.path) : 'URL')}");
    print("Headers:");
    response.headers.forEach((k, v) => print('$k: $v'));
    print("Response: ${response.data}");
    print("<-- END HTTP");
    return super.onResponse(response, handler);
  }
}