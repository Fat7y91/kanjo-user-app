import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../../data/models/conversations_list_model.dart';
import '../repo/conversations_repo.dart';

class FetchConversationsParams {
  const FetchConversationsParams({
    this.page = 1,
    this.perPage = 50,
  });

  final int page;
  final int perPage;
}

class FetchConversationsUseCase
    extends UseCaseParam<ConversationsListModel, FetchConversationsParams> {
  FetchConversationsUseCase({required this.conversationsRepo});

  final ConversationsRepo conversationsRepo;

  @override
  Future<Either<Failure, ConversationsListModel>> call(
    FetchConversationsParams param,
  ) {
    return conversationsRepo.getConversations(
      page: param.page,
      perPage: param.perPage,
    );
  }
}
