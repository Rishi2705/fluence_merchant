import 'package:dio/dio.dart';

/// Service class for making HTTP API calls.
/// Provides a configured Dio instance with interceptors and error handling.
class ApiService {
  late final Dio _dio;

  // Base URL for the Fluence Pay API
  static const String _baseUrl = 'https://api.fluencepay.com/v1';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  /// Sets up interceptors for logging and error handling.
  void _setupInterceptors() {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) {
          // In production, you might want to use a proper logging service
          print(object);
        },
      ),
    );

    // Error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          // Handle different types of errors
          if (error.response?.statusCode == 401) {
            // Unauthorized - redirect to login
            // You can emit an event here to handle logout
          } else if (error.response?.statusCode == 500) {
            // Server error
            error = DioException(
              requestOptions: error.requestOptions,
              message: 'Server error. Please try again later.',
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Gets the configured Dio instance.
  Dio get dio => _dio;

  /// Sets the authorization token for all requests.
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Removes the authorization token.
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Makes a GET request to the specified endpoint.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Makes a POST request to the specified endpoint.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Makes a PUT request to the specified endpoint.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Makes a DELETE request to the specified endpoint.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}