import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/paginated_response.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepo {
  Future<Either<Failure, PaginatedResponse<NotificationEntity>>> getNotifications({
    int page = 1,
    int perPage = 20,
  });
  Future<Either<Failure, bool>> seen(String id);
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, bool>> markAllAsRead();
}
