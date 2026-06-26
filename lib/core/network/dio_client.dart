import 'package:dio/dio.dart';
import 'package:sonexa/core/constants/api_constants.dart';
import 'package:sonexa/core/error/app_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.jiosaavnBaseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    _LoggingInterceptor(),
    _RetryInterceptor(dio: dio),
    _ErrorInterceptor(),
  ]);

  return dio;
});

// ── Logging Interceptor ───────────────────────────────────────────────────────
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('→ ${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('← ${response.statusCode} ${response.requestOptions.uri}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('✗ ${err.type} ${err.requestOptions.uri}: ${err.message}');
    super.onError(err, handler);
  }
}

// ── Error Interceptor ─────────────────────────────────────────────────────────
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        appException = const NetworkException(message: 'Connection timed out. Please check your network.');
        break;
      case DioExceptionType.connectionError:
        appException = const NetworkException(message: 'No internet connection. Please check your network.');
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 404) {
          appException = const NotFoundException(message: 'The requested resource was not found.');
        } else {
          appException = ServerException(
            message: 'Server error (${statusCode ?? 'unknown'}).',
            statusCode: statusCode,
          );
        }
        break;
      default:
        appException = const UnknownException();
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        message: appException.message,
        type: err.type,
      ),
    );
  }
}

// ── Retry Interceptor ─────────────────────────────────────────────────────────
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  _RetryInterceptor({required this.dio, this.maxRetries = 2});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] as int? ?? 0;

    if (retryCount < maxRetries &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError)) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      // Swap to the backup base URL if the primary server fails
      if (err.requestOptions.baseUrl == 'https://saavn.echomusic.fun/api') {
        err.requestOptions.baseUrl = 'https://saavn.sumit.co/api';
        if (err.requestOptions.path.startsWith('http')) {
          err.requestOptions.path = err.requestOptions.path
              .replaceFirst('https://saavn.echomusic.fun/api', '');
        }
      }

      await Future.delayed(Duration(seconds: retryCount + 1));
      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}
