import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'auth_repository.dart';

/// Implementation of [AuthRepository] that handles API calls and local storage.
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthRepositoryImpl({
    required Dio dio,
    required SharedPreferences prefs,
  })  : _dio = dio,
        _prefs = prefs;

  @override
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        // Store token and user data locally
        await _prefs.setString(_tokenKey, token);
        await _prefs.setString(_userKey, userData.toString());

        // Set token in Dio headers for future requests
        _dio.options.headers['Authorization'] = 'Bearer $token';

        return User.fromJson(userData);
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
    return null;
  }

  @override
  Future<User?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        // Store token and user data locally
        await _prefs.setString(_tokenKey, token);
        await _prefs.setString(_userKey, userData.toString());

        // Set token in Dio headers for future requests
        _dio.options.headers['Authorization'] = 'Bearer $token';

        return User.fromJson(userData);
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    try {
      // Call logout endpoint if needed
      await _dio.post('/auth/logout');
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      // Clear local storage
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userKey);

      // Remove token from Dio headers
      _dio.options.headers.remove('Authorization');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = _prefs.getString(_tokenKey);
      if (token == null) return null;

      // Set token in headers
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>;
        return User.fromJson(userData);
      }
    } catch (e) {
      // If API call fails, try to get user from local storage
      final userDataString = _prefs.getString(_userKey);
      if (userDataString != null) {
        // Note: In a real implementation, you'd parse this properly
        // This is just a placeholder
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = _prefs.getString(_tokenKey);
    return token != null;
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final token = _prefs.getString(_tokenKey);
      if (token == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'] as String;
        await _prefs.setString(_tokenKey, newToken);
        _dio.options.headers['Authorization'] = 'Bearer $newToken';
        return true;
      }
    } catch (e) {
      // Token refresh failed
    }
    return false;
  }
}