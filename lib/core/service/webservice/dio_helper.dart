import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../config/api_path.dart';
import '../../../config/constants.dart';
import '../../../features/splash/presentation/managers/splash_provider.dart';
import '../../../main.dart';
import '../../errors/failure.dart';
import '../local_data_manager.dart';
import '../localization_service/localization_service.dart';

final downloadPercentageProvider =
    StateProvider.family<int, String>((ref, name) => 0);

Future<String?> downloadFile(
    String url, String fileName, WidgetRef ref, String downloadName) async {
  try {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    Directory dir = await getApplicationDocumentsDirectory();
    String savePath = "${dir.path}/$downloadName/$fileName";

    Dio dio = Dio();
    await dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          ref.read(downloadPercentageProvider(downloadName).notifier).state =
              (received / total * 100).floor();
          print(
              "Download progress: ${(received / total * 100).toStringAsFixed(0)}%");
        }
      },
    );
    print("✅ File downloaded to: $savePath");
    return savePath;
  } catch (e) {
    print("❌ Error downloading file: $e");
    return null;
  }
}

Logger logger = Logger();

const _sensitiveLogKeys = {
  'authorization',
  'idtoken',
  'id_token',
  'accesstoken',
  'access_token',
  'refreshtoken',
  'refresh_token',
  'token',
};

/// Returns a copy of [value] with auth tokens masked, safe to pass to the logger.
dynamic _redactForLog(dynamic value) {
  if (value is Map) {
    return value.map((key, v) => MapEntry(
          key,
          _sensitiveLogKeys.contains(key.toString().toLowerCase())
              ? '<redacted>'
              : _redactForLog(v),
        ));
  }
  if (value is List) return value.map(_redactForLog).toList();
  if (value is MapEntry) {
    return _sensitiveLogKeys.contains(value.key.toString().toLowerCase())
        ? MapEntry(value.key, '<redacted>')
        : value;
  }
  return value;
}

enum _MethodType { post, get, put, patch, delete, download }

class ApiService {
  static const _connectTimeout = Duration(seconds: 30);
  static const _receiveTimeout = Duration(seconds: 30);
  static const _sendTimeout = Duration(seconds: 30);

  Map<String, String> get _defaultHeaders {
    final token = dataManager.getToken();
    return {
      'Accept-Language': getIt<LocaleService>().handleLocaleInMain.languageCode,
      "Content-Type": Headers.jsonContentType,
      "Accept": Headers.jsonContentType,
      if (token != null) 'Authorization': "Bearer $token",
    };
  }

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
      baseUrl: ApiPath.baseurl,
    ),
  );

  // POST method
  Future<T> post<T>({
    dynamic requestBody,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    bool returnDataOnly = false,
    CancelToken? cancelToken,
    bool ignoreError = false,
    bool logging = true,
    Duration? sendTimeOut = _sendTimeout,
    Duration? receiveTimeout = _receiveTimeout,
    // bool automaticManageIndicator = true,
    required String url,
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    return _hitApi(
      cancelToken: cancelToken,
      url: url,
      header: header,
      queryParameters: queryParameters,
      returnDataOnly: returnDataOnly,
      methodType: _MethodType.post,
      requestBody: requestBody,
      logging: logging,
      additionalHeaders: additionalHeaders,
      receiveTimeout: receiveTimeout,
      ignoreError: ignoreError,
      sendTimeOut: sendTimeOut,
    );
  }

  Future<T> patch<T>({
    dynamic requestBody,
    dynamic queryParameters,
    Map<String, dynamic>? header,
    bool ignoreError = false,
    bool returnDataOnly = false,
    bool logging = true,
    bool waitError = false,
    CancelToken? cancelToken,
    Duration? sendTimeOut = _sendTimeout,
    Duration? receiveTimeout = _receiveTimeout,
    // bool automaticManageIndicator = true,
    required String url,
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    return _hitApi(
      cancelToken: cancelToken,
      url: url,
      header: header,
      queryParameters: queryParameters,
      returnDataOnly: returnDataOnly,
      methodType: _MethodType.patch,
      requestBody: requestBody,
      additionalHeaders: additionalHeaders,
      logging: logging,
      receiveTimeout: receiveTimeout,
      sendTimeOut: sendTimeOut,
    );
  }

  // PUT method
  Future<T> put<T>({
    dynamic requestBody,
    dynamic queryParameters,
    Map<String, dynamic>? header,
    bool returnDataOnly = false,
    bool logging = true,
    bool waitError = false,
    CancelToken? cancelToken,
    Duration? sendTimeOut = _sendTimeout,
    Duration? receiveTimeout = _receiveTimeout,
    bool automaticManageIndicator = true,
    required String url,
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    return _hitApi(
      cancelToken: cancelToken,
      url: url,
      header: header,
      returnDataOnly: returnDataOnly,
      methodType: _MethodType.put,
      requestBody: requestBody,
      queryParameters: queryParameters,
      additionalHeaders: additionalHeaders,
      logging: logging,
      receiveTimeout: receiveTimeout,
      sendTimeOut: sendTimeOut,
    );
  }

  Future<T> get<T>({
    required String url,
    bool returnDataOnly = false,
    bool automaticManageIndicator = true,
    dynamic queryParameters,
    dynamic requestBody,
    Duration? sendTimeOut = _sendTimeout,
    CancelToken? cancelToken,
    bool logging = true,
    bool waitError = false,
    Duration? receiveTimeout = _receiveTimeout,
    bool ignoreError = false,
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    return _hitApi(
      cancelToken: cancelToken,
      url: url,
      returnDataOnly: returnDataOnly,
      methodType: _MethodType.get,
      requestBody: requestBody,
      queryParameters: queryParameters,
      additionalHeaders: additionalHeaders,
      logging: logging,
      receiveTimeout: receiveTimeout,
      sendTimeOut: sendTimeOut,
    );
  }

  Future<T> download<T>({
    required String url,
    CancelToken? cancelToken,
    bool waitError = false,
    dynamic queryParameters,
  }) async {
    return _hitApi(
      cancelToken: cancelToken,
      url: url,
      methodType: _MethodType.download,
      returnDataOnly: false,
      requestBody: queryParameters,
      receiveTimeout: Duration.zero,
      sendTimeOut: Duration.zero,
    );
  }

  Future<T> delete<T>({
    required String url,
    bool returnDataOnly = false,
    bool automaticManageIndicator = true,
    bool logging = true,
    CancelToken? cancelToken,
    dynamic queryParameters,
    dynamic requestBody,
    Duration? sendTimeOut = _sendTimeout,
    bool ignoreError = false,
    Duration? receiveTimeout = _receiveTimeout,
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    return _hitApi(
      cancelToken: cancelToken,
      url: url,
      returnDataOnly: returnDataOnly,
      methodType: _MethodType.delete,
      requestBody: requestBody ?? queryParameters,
      queryParameters: queryParameters,
      additionalHeaders: additionalHeaders,
      logging: logging,
      receiveTimeout: receiveTimeout,
      sendTimeOut: sendTimeOut,
    );
  }

  Future<T> _hitApi<T>({
    required _MethodType methodType,
    required String url,
    bool returnDataOnly = false,
    CancelToken? cancelToken,
    dynamic requestBody,
    dynamic queryParameters,
    bool logging = true,
    bool ignoreError = false,
    Map<String, dynamic>? header,
    Duration? sendTimeOut = _sendTimeout,
    Duration? receiveTimeout = _receiveTimeout,
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    providerContainer.refresh(hasInternetProvider2);
    final Map<String, dynamic> headers = {
      ..._defaultHeaders,
      ...additionalHeaders,
      if (header != null) ...header,
    };
    if (ApiPath.isPublic(url) && (dataManager.getToken() ?? '').isEmpty) {
      headers.remove('Authorization');
    }

    if (logging) {
      logger.f(
        "$methodType:${_dio.options.baseUrl + url}\n${_redactForLog(headers)}\n${_redactForLog(requestBody) ?? ''}",
      );
      if (requestBody is FormData) {
        logger.f(_redactForLog((requestBody).fields));
        logger.f((requestBody).files);
      }
    }

    late String path;
    Response<dynamic> response;
    try {
      switch (methodType) {
        case _MethodType.post:
          response = await _dio.post(
            url,
            options: Options(
              headers: headers,
              receiveTimeout: receiveTimeout,
              sendTimeout: sendTimeOut,
            ),
            queryParameters: queryParameters,
            data: requestBody,
            cancelToken: cancelToken,
          );
          break;
        case _MethodType.get:
          response = await _dio.get(
            url,
            options: Options(
              headers: headers,
            ),
            queryParameters: queryParameters ?? requestBody,
            cancelToken: cancelToken,
          );
          break;
        case _MethodType.put:
          response = await _dio.put(
            url,
            options: Options(
              headers: headers,
              receiveTimeout: receiveTimeout,
              sendTimeout: sendTimeOut,
            ),
            queryParameters: queryParameters,
            data: requestBody,
            cancelToken: cancelToken,
          );
          break;
        case _MethodType.patch:
          response = await _dio.patch(
            url,
            options: Options(
              headers: headers,
              receiveTimeout: receiveTimeout,
              sendTimeout: sendTimeOut,
            ),
            queryParameters: queryParameters,
            data: requestBody,
            cancelToken: cancelToken,
          );
          break;
        case _MethodType.delete:
          response = await _dio.delete(
            url,
            options: Options(
              headers: headers,
              receiveTimeout: receiveTimeout,
              sendTimeout: sendTimeOut,
            ),
            queryParameters: queryParameters,
            data: requestBody,
            cancelToken: cancelToken,
          );
          break;
        case _MethodType.download:
          path = join(
              await (getTemporaryDirectory().then((value) => value.path)),
              "${DateTime.now().millisecondsSinceEpoch}.pdf");
          response = await _dio.download(url, path,
              cancelToken: cancelToken, queryParameters: requestBody);
          break;
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (Constants.loggerResponse && logging) logger.w(_redactForLog(response.data));
        if (_MethodType.download == methodType) {
          return (path as T);
        } else {
          if (returnDataOnly) {
            return (response.data['data'] as T);
          } else {
            return (response.data as T);
          }
        }
      } else {
        throw DioException(requestOptions: response.requestOptions);
      }
    } on DioException catch (e) {
      rethrow;
      // if (e.response?.statusCode == 401) {
      //   // Token expired, refresh the token
      //   // await getIt<AuthDataSource>().refreshToken();
      //   // Retry the request
      //   return _hitApi(
      //     methodType: methodType,
      //     url: url,
      //     returnDataOnly: returnDataOnly,
      //     cancelToken: cancelToken,
      //     requestBody: requestBody,
      //     logging: logging,
      //     ignoreError: ignoreError,
      //     header: header,
      //     sendTimeOut: sendTimeOut,
      //     receiveTimeout: receiveTimeout,
      //     additionalHeaders: additionalHeaders,
      //   );
      // } else {
      //   rethrow;
      // }
    }
  }
}

class APIError extends Failure {
  dynamic status = '';
  bool msgFromServer;

  APIError(
      {this.status,
      dynamic message,
      this.msgFromServer = false,
      required bool ignoreError})
      : super(message ?? '') {
    logger.e("code is $status , and the message is $message");
  }
}
