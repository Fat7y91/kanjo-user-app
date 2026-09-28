import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../repo/conversations_repo.dart';

class AcceptConversationQuoteParams {
  const AcceptConversationQuoteParams({
    required this.conversationId,
    required this.quoteMessageId,
  });

  final int conversationId;
  final int quoteMessageId;
}

class AcceptConversationQuoteUseCase
    extends UseCaseParam<Unit, AcceptConversationQuoteParams> {
  AcceptConversationQuoteUseCase({required this.conversationsRepo});

  final ConversationsRepo conversationsRepo;

  @override
  Future<Either<Failure, Unit>> call(AcceptConversationQuoteParams param) {
    return conversationsRepo.acceptQuote(
      conversationId: param.conversationId,
      quoteMessageId: param.quoteMessageId,
    );
  }
}
