import '../models/notification_model.dart';
import '../services/notification_api_service.dart';

class NotificationRepository {
  final NotificationApiService _notificationApiService;

  NotificationRepository(this._notificationApiService);

  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    return await _notificationApiService.getNotifications(
      page: page,
      limit: limit,
      type: type,
    );
  }

  Future<int> getUnreadCount() async {
    return await _notificationApiService.getUnreadCount();
  }

  Future<void> markAsRead(String notificationId) async {
    return await _notificationApiService.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    return await _notificationApiService.markAllAsRead();
  }

  Future<NotificationPreferences> getPreferences() async {
    return await _notificationApiService.getPreferences();
  }

  Future<NotificationPreferences> updatePreferences({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    Map<String, bool>? categoryPreferences,
  }) async {
    return await _notificationApiService.updatePreferences(
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
      smsNotifications: smsNotifications,
      categoryPreferences: categoryPreferences,
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    return await _notificationApiService.deleteNotification(notificationId);
  }
}
