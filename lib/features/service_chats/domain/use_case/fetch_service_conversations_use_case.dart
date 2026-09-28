import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../../data/models/service_conversations_list_model.dart';
import '../repo/service_chats_repo.dart';

class FetchServiceConversationsParams {
  const FetchServiceConversationsParams({
    this.page = 1,
    this.perPage = 20,
  });

  final int page;
  final int perPage;
}

class FetchServiceConversationsUseCase extends UseCaseParam<
    ServiceConversationsListModel, FetchServiceConversationsParams> {
  FetchServiceConversationsUseCase({required this.serviceChatsRepo});

  final ServiceChatsRepo serviceChatsRepo;

  @override
  Future<Either<Failure, ServiceConversationsListModel>> call(
    FetchServiceConversationsParams param,
  ) {
    return serviceChatsRepo.getConversations(
      page: param.page,
      perPage: param.perPage,
    );
  }
}
