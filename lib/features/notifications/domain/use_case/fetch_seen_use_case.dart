import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../repos/notification_repo.dart';

class SeenNotificationUseCase extends UseCaseParam<bool, String> {
  final NotificationRepo notificationRepo;

  SeenNotificationUseCase({required this.notificationRepo});

  @override
  Future<Either<Failure, bool>> call([String? param]) async {
    if (param == null || param.isEmpty) {
      return Left(GeneralError('Notification ID is required'));
    }
    final res = await notificationRepo.seen(param);
    return res;
  }
}
