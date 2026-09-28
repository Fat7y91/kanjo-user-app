import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../repos/notification_repo.dart';

class MarkAllAsReadUseCase extends UseCaseNoParam<bool> {
  final NotificationRepo notificationRepo;

  MarkAllAsReadUseCase({required this.notificationRepo});

  @override
  Future<Either<Failure, bool>> call() async {
    final res = await notificationRepo.markAllAsRead();
    return res;
  }
}

