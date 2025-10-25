import 'dart:developer' as developer;

/// Enhanced logging utility for debugging authentication and API calls
class AppLogger {
  static const String _authTag = '🔐 AUTH';
  static const String _apiTag = '🌐 API';
  static const String _errorTag = '❌ ERROR';
  static const String _successTag = '✅ SUCCESS';
  static const String _warningTag = '⚠️ WARNING';
  static const String _infoTag = 'ℹ️ INFO';

  /// Log authentication related events
  static void auth(String message, {Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $_authTag: $message';
    
    developer.log(logMessage, name: 'AUTH');
    print(logMessage);
    
    if (data != null) {
      final dataMessage = '[$timestamp] $_authTag DATA: $data';
      developer.log(dataMessage, name: 'AUTH');
      print(dataMessage);
    }
  }

  /// Log API calls and responses
  static void api(String message, {Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $_apiTag: $message';
    
    developer.log(logMessage, name: 'API');
    print(logMessage);
    
    if (data != null) {
      final dataMessage = '[$timestamp] $_apiTag DATA: $data';
      developer.log(dataMessage, name: 'API');
      print(dataMessage);
    }
  }

  /// Log errors with stack trace
  static void error(String message, {Object? error, StackTrace? stackTrace, Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $_errorTag: $message';
    
    developer.log(logMessage, name: 'ERROR', error: error, stackTrace: stackTrace);
    print(logMessage);
    
    if (error != null) {
      final errorMessage = '[$timestamp] $_errorTag DETAILS: $error';
      developer.log(errorMessage, name: 'ERROR');
      print(errorMessage);
    }
    
    if (data != null) {
      final dataMessage = '[$timestamp] $_errorTag DATA: $data';
      developer.log(dataMessage, name: 'ERROR');
      print(dataMessage);
    }
    
    if (stackTrace != null) {
      final stackMessage = '[$timestamp] $_errorTag STACK: $stackTrace';
      developer.log(stackMessage, name: 'ERROR');
      print(stackMessage);
    }
  }

  /// Log success events
  static void success(String message, {Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $_successTag: $message';
    
    developer.log(logMessage, name: 'SUCCESS');
    print(logMessage);
    
    if (data != null) {
      final dataMessage = '[$timestamp] $_successTag DATA: $data';
      developer.log(dataMessage, name: 'SUCCESS');
      print(dataMessage);
    }
  }

  /// Log warnings
  static void warning(String message, {Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $_warningTag: $message';
    
    developer.log(logMessage, name: 'WARNING');
    print(logMessage);
    
    if (data != null) {
      final dataMessage = '[$timestamp] $_warningTag DATA: $data';
      developer.log(dataMessage, name: 'WARNING');
      print(dataMessage);
    }
  }

  /// Log general info
  static void info(String message, {Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $_infoTag: $message';
    
    developer.log(logMessage, name: 'INFO');
    print(logMessage);
    
    if (data != null) {
      final dataMessage = '[$timestamp] $_infoTag DATA: $data';
      developer.log(dataMessage, name: 'INFO');
      print(dataMessage);
    }
  }

  /// Log Firebase specific events
  static void firebase(String message, {Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] 🔥 FIREBASE: $message';
    
    developer.log(logMessage, name: 'FIREBASE');
    print(logMessage);
    
    if (data != null) {
      final dataMessage = '[$timestamp] 🔥 FIREBASE DATA: $data';
      developer.log(dataMessage, name: 'FIREBASE');
      print(dataMessage);
    }
  }

  /// Log network requests with detailed info
  static void networkRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    Object? body,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    api('$method Request to: $url');
    
    if (headers != null && headers.isNotEmpty) {
      api('Request Headers:', data: headers);
    }
    
    if (body != null) {
      api('Request Body:', data: body);
    }
  }

  /// Log network responses with detailed info
  static void networkResponse({
    required int statusCode,
    required String url,
    Map<String, dynamic>? headers,
    Object? body,
    Duration? duration,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final durationText = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    
    if (statusCode >= 200 && statusCode < 300) {
      success('Response $statusCode from: $url$durationText');
    } else if (statusCode >= 400) {
      error('Response $statusCode from: $url$durationText');
    } else {
      info('Response $statusCode from: $url$durationText');
    }
    
    if (headers != null && headers.isNotEmpty) {
      api('Response Headers:', data: headers);
    }
    
    if (body != null) {
      api('Response Body:', data: body);
    }
  }

  /// Log step-by-step process
  static void step(int stepNumber, String description, {Object? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] 📋 STEP $stepNumber: $description';
    
    developer.log(logMessage, name: 'STEP');
    print(logMessage);
    
    if (data != null) {
      final dataMessage = '[$timestamp] 📋 STEP $stepNumber DATA: $data';
      developer.log(dataMessage, name: 'STEP');
      print(dataMessage);
    }
  }
}