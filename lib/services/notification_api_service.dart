import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../core/constants/api_constants.dart';
import 'api_service_new.dart';

class NotificationApiService {
  final ApiService _apiService;

  NotificationApiService(this._apiService);

  /// Get notifications
  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.notifications,
        service: 'notification',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null) 'type': type,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['notifications'] as List;
        return data
            .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        ApiConstants.notificationsUnreadCount,
        service: 'notification',
      );

      if (response.statusCode == 200) {
        return response.data['data']['count'] as int;
      } else {
        throw Exception('Failed to fetch unread count');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.notificationsMarkRead}/$notificationId',
        service: 'notification',
        data: {},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark as read');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.put(
        ApiConstants.notificationsMarkAllRead,
        service: 'notification',
        data: {},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all as read');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get notification preferences
  Future<NotificationPreferences> getPreferences() async {
    try {
      final response = await _apiService.get(
        ApiConstants.notificationPreferences,
        service: 'notification',
      );

      if (response.statusCode == 200) {
        return NotificationPreferences.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch preferences');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update notification preferences
  Future<NotificationPreferences> updatePreferences({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    Map<String, bool>? categoryPreferences,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.notificationPreferences,
        service: 'notification',
        data: {
          if (emailNotifications != null) 'emailNotifications': emailNotifications,
          if (pushNotifications != null) 'pushNotifications': pushNotifications,
          if (smsNotifications != null) 'smsNotifications': smsNotifications,
          if (categoryPreferences != null) 'categoryPreferences': categoryPreferences,
        },
      );

      if (response.statusCode == 200) {
        return NotificationPreferences.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update preferences');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.notifications}/$notificationId',
        service: 'notification',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete notification');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle errors
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'Server error: ${error.response!.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout';
    } else {
      return 'Network error: ${error.message}';
    }
  }
}
