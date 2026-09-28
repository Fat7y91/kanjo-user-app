import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/paginated_response.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repos/notification_repo.dart';
import '../data_source/notification_data_source.dart';

class NotificationRepoImp extends NotificationRepo {
  final NotificationDataSource notificationDataSource;

  NotificationRepoImp({required this.notificationDataSource});

  @override
  Future<Either<Failure, PaginatedResponse<NotificationEntity>>>
      getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final res = await notificationDataSource.getNotification(
        page: page,
        perPage: perPage,
      );
      return Right(
        PaginatedResponse(
          data: res.data
              .map(NotificationEntity.fromNotificationModel)
              .toList(),
          meta: res.meta,
        ),
      );
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> seen(String id) async {
    try {
      final res = await notificationDataSource.seen(id);
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final res = await notificationDataSource.getUnreadCount();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      final res = await notificationDataSource.markAllAsRead();
      return Right(res);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(GeneralError(e));
      }
    }
  }
}
