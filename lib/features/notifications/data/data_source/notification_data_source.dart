import '../../../../../config/api_path.dart';
import '../../../../../core/models/paginated_response.dart';
import '../../../../../core/service/webservice/dio_helper.dart';
import '../models/notifications_model.dart';

abstract class NotificationDataSource {
  Future<PaginatedResponse<NotificationModel>> getNotification({
    int page = 1,
    int perPage = 20,
  });
  Future<bool> seen(String id);
  Future<int> getUnreadCount();
  Future<bool> markAllAsRead();
}

class NotificationDataSourceImp extends NotificationDataSource {
  final ApiService apiService;

  NotificationDataSourceImp({required this.apiService});

  @override
  Future<PaginatedResponse<NotificationModel>> getNotification({
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await apiService.get(
      url: ApiPath.getNotificationsList(page: page, perPage: perPage),
      returnDataOnly: false,
    );

    return parsePaginatedResponse(
      res,
      (json) => NotificationModel.fromJson(json),
    );
  }

  @override
  Future<bool> seen(String id) async {
    await apiService.post(
      url: ApiPath.notificationRead(id),
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<int> getUnreadCount() async {
    final res = await apiService.get(
      url: ApiPath.notificationsUnreadCount,
      returnDataOnly: true,
    );
    if (res is Map) {
      final map = Map<String, dynamic>.from(res);
      final count = map['unread_count'] ?? map['count'] ?? map['total'];
      if (count is int) return count;
      return int.tryParse(count?.toString() ?? '') ?? 0;
    }
    if (res is int) return res;
    return int.tryParse(res?.toString() ?? '') ?? 0;
  }

  @override
  Future<bool> markAllAsRead() async {
    await apiService.post(
      url: ApiPath.notificationsReadAll,
      returnDataOnly: true,
    );
    return true;
  }
}
