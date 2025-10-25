import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

/// Enhanced API service with multi-service support and token management
class ApiService {
  late final Dio _authDio;
  late final Dio _merchantDio;
  late final Dio _cashbackDio;
  late final Dio _walletDio;
  late final Dio _notificationDio;
  late final Dio _referralDio;
  
  String? _authToken;

  ApiService() {
    _authDio = _createDio(ApiConstants.authBaseUrl);
    _merchantDio = _createDio(ApiConstants.merchantBaseUrl);
    _cashbackDio = _createDio(ApiConstants.cashbackBaseUrl);
    _walletDio = _createDio(ApiConstants.walletBaseUrl);
    _notificationDio = _createDio(ApiConstants.notificationBaseUrl);
    _referralDio = _createDio(ApiConstants.referralBaseUrl);
    
    _loadToken();
  }

  /// Create a Dio instance with common configuration
  Dio _createDio(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors(dio);
    return dio;
  }

  /// Setup interceptors for logging and auth
  void _setupInterceptors(Dio dio) {
    // Retry interceptor for connection timeouts
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.type == DioExceptionType.connectionTimeout) {
            // Retry once for connection timeouts
            final options = error.requestOptions;
            try {
              final response = await dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Auth interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid, clear it
            clearToken();
          }
          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) {
          print('[API] $object');
        },
      ),
    );
  }

  /// Load authentication token from storage
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  /// Set authentication token
  Future<void> setToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear authentication token
  Future<void> clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Get authentication token
  String? get token => _authToken;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null;

  // Getters for service-specific Dio instances
  Dio get authClient => _authDio;
  Dio get merchantClient => _merchantDio;
  Dio get cashbackClient => _cashbackDio;
  Dio get walletClient => _walletDio;
  Dio get notificationClient => _notificationDio;
  Dio get referralClient => _referralDio;

  /// Generic GET request
  Future<Response> get(
    String path, {
    required String service,
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = _getDioForService(service);
    return await dio.get(path, queryParameters: queryParameters);
  }

  /// Generic POST request
  Future<Response> post(
    String path, {
    required String service,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = _getDioForService(service);
    return await dio.post(path, data: data, queryParameters: queryParameters);
  }

  /// Generic PUT request
  Future<Response> put(
    String path, {
    required String service,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = _getDioForService(service);
    return await dio.put(path, data: data, queryParameters: queryParameters);
  }

  /// Generic DELETE request
  Future<Response> delete(
    String path, {
    required String service,
    Map<String, dynamic>? queryParameters,
  }) async {
    final dio = _getDioForService(service);
    return await dio.delete(path, queryParameters: queryParameters);
  }

  /// Get Dio instance for specific service
  Dio _getDioForService(String service) {
    switch (service) {
      case 'auth':
        return _authDio;
      case 'merchant':
        return _merchantDio;
      case 'cashback':
        return _cashbackDio;
      case 'wallet':
        return _walletDio;
      case 'notification':
        return _notificationDio;
      case 'referral':
        return _referralDio;
      default:
        throw ArgumentError('Unknown service: $service');
    }
  }
}
