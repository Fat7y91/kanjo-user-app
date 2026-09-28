import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/support_ticket_model.dart';
import '../entities/create_support_ticket_params.dart';
import '../entities/reply_support_ticket_params.dart';
import '../entities/support_ticket_message_entity.dart';
import '../repo/support_tickets_repo.dart';

class FetchSupportTicketsUseCase
    extends UseCaseNoParam<List<SupportTicketModel>> {
  FetchSupportTicketsUseCase({required this.repo});

  final SupportTicketsRepo repo;

  @override
  Future<Either<Failure, List<SupportTicketModel>>> call() {
    return repo.getTickets();
  }
}

class FetchSupportTicketDetailsUseCase
    extends UseCaseParam<SupportTicketModel, int> {
  FetchSupportTicketDetailsUseCase({required this.repo});

  final SupportTicketsRepo repo;

  @override
  Future<Either<Failure, SupportTicketModel>> call(int param) {
    return repo.getTicket(param);
  }
}

class CreateSupportTicketUseCase
    extends UseCaseParam<SupportTicketModel, CreateSupportTicketParams> {
  CreateSupportTicketUseCase({required this.repo});

  final SupportTicketsRepo repo;

  @override
  Future<Either<Failure, SupportTicketModel>> call(
    CreateSupportTicketParams param,
  ) {
    return repo.createTicket(param);
  }
}

class ReplySupportTicketUseCase
    extends UseCaseParam<SupportTicketMessageEntity, ReplySupportTicketParams> {
  ReplySupportTicketUseCase({required this.repo});

  final SupportTicketsRepo repo;

  @override
  Future<Either<Failure, SupportTicketMessageEntity>> call(
    ReplySupportTicketParams param,
  ) {
    return repo.replyTicket(param);
  }
}
