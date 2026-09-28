import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../repos/notification_repo.dart';

class GetUnreadCountUseCase extends UseCaseNoParam<int> {
  final NotificationRepo notificationRepo;

  GetUnreadCountUseCase({required this.notificationRepo});

  @override
  Future<Either<Failure, int>> call() async {
    final res = await notificationRepo.getUnreadCount();
    return res;
  }
}

