import 'dart:developer';

import 'package:bili_own/common/api/index.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:path_provider/path_provider.dart';

class HttpUtils {
  static final HttpUtils _instance = HttpUtils._internal();
  factory HttpUtils() => _instance;
  static late final Dio dio;
  static late CookieManager cookieManager;
  CancelToken _cancelToken = CancelToken();

  ///初始化构造
  HttpUtils._internal() {
    BaseOptions options = BaseOptions(
      headers: {
        'keep-alive': true,
        'user-agent': ApiConstants.userAgent,
        'Accept-Encoding': 'gzip'
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      persistentConnection: true,
      extra: {
        "retry": 3,
        "retryInterval": 1000,
      }
    );
    dio = Dio(options);
    dio.transformer = BackgroundTransformer();
    
    dio.interceptors.add(RetryInterceptor());

    // 添加error拦截器
    dio.interceptors.add(ErrorInterceptor());
  }

  ///初始化设置
  Future<void> init() async {
    if (kIsWeb) {
      cookieManager = CookieManager(CookieJar());
    } else {
      //设置cookie存放的位置，保存cookie
      var cookiePath =
          "${(await getApplicationSupportDirectory()).path}/.cookies/";
      cookieManager =
          CookieManager(PersistCookieJar(storage: FileStorage(cookiePath)));
    }
    dio.interceptors.add(cookieManager);
    if ((await cookieManager.cookieJar
            .loadForRequest(Uri.parse(ApiConstants.bilibiliBase)))
        .isEmpty) {
      try {
        await dio.get(ApiConstants.bilibiliBase); //获取默认cookie
      } catch (e) {
        log("utils/my_dio, ${e.toString()}");
      }
    }
  }

  // 关闭dio
  void cancelRequests({required CancelToken token}) {
    _cancelToken.cancel("cancelled");
    _cancelToken = token;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  Future post(
    String path, {
    Map<String, dynamic>? queryParameters,
    data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    // 获取重试次数和间隔
    int retryCount = err.requestOptions.extra['retry'] ?? 0;
    int retryInterval = err.requestOptions.extra['retryInterval'] ?? 1000;
    
    // 如果还有重试次数且是网络相关错误，则重试
    if (retryCount > 0 && 
        (err.type == DioErrorType.connectionTimeout || 
         err.type == DioErrorType.receiveTimeout || 
         err.type == DioErrorType.unknown)) {
      
      // 减少重试次数
      err.requestOptions.extra['retry'] = retryCount - 1;
      
      // 等待一段时间后重试
      await Future.delayed(Duration(milliseconds: retryInterval));
      
      try {
        // 重试请求
        final response = await HttpUtils.dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          cancelToken: err.requestOptions.cancelToken,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            extra: err.requestOptions.extra,
            contentType: err.requestOptions.contentType,
            responseType: err.requestOptions.responseType,
            receiveTimeout: err.requestOptions.receiveTimeout,
            sendTimeout: err.requestOptions.sendTimeout,
          ),
        );
        return handler.resolve(response);
      } catch (e) {
        // 如果重试也失败，继续传递错误
        return handler.next(err);
      }
    }
    
    // 不需要重试的情况，继续传递错误
    return handler.next(err);
  }
}

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  // 是否有网
  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    switch (err.type) {
      case DioErrorType.unknown:
        if (!await isConnected()) {
          Get.rawSnackbar(title: '网络未连接 ', message: '请检查网络状态');
          handler.reject(err);
        }
        break;
      default:
    }

    return super.onError(err, handler);
  }
}
