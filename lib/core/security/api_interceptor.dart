import 'package:dio/dio.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import '../encryption/secure_storage.dart';
import '../config/app_config.dart';
import 'package:logger/logger.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorageService secureStorage;
  final Logger logger = Logger();

  ApiInterceptor(this.secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final authToken = await secureStorage.getAuthToken();
      if (authToken != null && authToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $authToken';
      }
      options.headers['Content-Type'] = 'application/json';
      options.headers['X-API-Version'] = '1.0';
      options.headers['User-Agent'] = 'ShareNetEarn/1.0';
      // Security headers
      options.headers['X-Requested-With'] = 'XMLHttpRequest';
      options.headers['X-Content-Type-Options'] = 'nosniff';

      logger.i('API Request', options.method, options.path);
      return handler.next(options);
    } catch (e) {
      logger.e('Request interceptor error', e);
      return handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    logger.i('API Response', response.statusCode, response.requestOptions.path);
    if (response.statusCode != null && response.statusCode! >= 500) {
      logger.w('Server error', response.statusCode);
    }
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    logger.e('API Error', err.message);
    if (err.response?.statusCode == 401) {
      await handleTokenExpired();
      // Could trigger UI actions or state updates for re-login
    }
    return handler.next(err);
  }

  Future<void> handleTokenExpired() async {
    logger.w('Auth token expired');
    await secureStorage.deleteKey('authToken');
    // Trigger re-login
  }

  // SSL pinning
  Future<bool> verifySSLCertificatePinning(String url) async {
    try {
      return await HttpCertificatePinning.check(
        serverURL: url,
        headerHttp: {},
        isLocalHost: false,
        pinnedSslCertificate: '''
-----BEGIN CERTIFICATE-----
MIIDdzCCAl+gAwIBAgIEb5w7NjANBgkqhkiG9w0BAQsFADBvMQswCQYDVQQGEwJJ
...
-----END CERTIFICATE-----
        ''',
        timeout: 30,
      );
    } catch (e) {
      logger.e('SSL Certificate pinning failed', e);
      return false;
    }
  }
}

// Configure Dio client with security
Dio configureDioClient({
  required SecureStorageService secureStorage,
  Duration connectionTimeout = const Duration(seconds: 30),
}) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: connectionTimeout,
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
    ),
  );
  dio.interceptors.add(ApiInterceptor(secureStorage));
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
}
