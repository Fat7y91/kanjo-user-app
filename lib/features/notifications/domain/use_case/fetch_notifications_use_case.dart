import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/models/paginated_response.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../entities/notification_entity.dart';
import '../repos/notification_repo.dart';

class FetchNotificationUseCase
    extends UseCaseParam<PaginatedResponse<NotificationEntity>,
        Map<String, dynamic>> {
  final NotificationRepo notificationRepo;

  FetchNotificationUseCase({required this.notificationRepo});

  @override
  Future<Either<Failure, PaginatedResponse<NotificationEntity>>> call(
      Map<String, dynamic>? param) async {
    final page = param?['page'] is int
        ? param!['page'] as int
        : (int.tryParse(param?['page']?.toString() ?? '1') ?? 1);
    final perPage = param?['per_page'] is int
        ? param!['per_page'] as int
        : (int.tryParse(
                param?['per_page']?.toString() ??
                    param?['limit']?.toString() ??
                    '20') ??
            20);

    return notificationRepo.getNotifications(
      page: page,
      perPage: perPage,
    );
  }
}
