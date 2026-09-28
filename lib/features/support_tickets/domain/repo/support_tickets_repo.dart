import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/support_ticket_model.dart';
import '../entities/create_support_ticket_params.dart';
import '../entities/reply_support_ticket_params.dart';
import '../entities/support_ticket_message_entity.dart';

abstract class SupportTicketsRepo {
  Future<Either<Failure, List<SupportTicketModel>>> getTickets();

  Future<Either<Failure, SupportTicketModel>> getTicket(int ticketId);

  Future<Either<Failure, SupportTicketModel>> createTicket(
    CreateSupportTicketParams params,
  );

  Future<Either<Failure, SupportTicketMessageEntity>> replyTicket(
    ReplySupportTicketParams params,
  );
}
