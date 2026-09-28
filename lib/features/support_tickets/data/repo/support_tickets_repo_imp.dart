import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/create_support_ticket_params.dart';
import '../../domain/entities/reply_support_ticket_params.dart';
import '../../domain/entities/support_ticket_message_entity.dart';
import '../../domain/repo/support_tickets_repo.dart';
import '../data_source/support_tickets_data_source.dart';
import '../models/support_ticket_model.dart';

class SupportTicketsRepoImp extends SupportTicketsRepo {
  SupportTicketsRepoImp({required this.dataSource});

  final SupportTicketsDataSource dataSource;

  @override
  Future<Either<Failure, List<SupportTicketModel>>> getTickets() async {
    try {
      final tickets = await fetchAllPaginatedPages(
        fetchPage: (page) => dataSource.getTickets(page: page),
      );
      return Right(tickets);
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioError(e));
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, SupportTicketModel>> getTicket(int ticketId) async {
    try {
      return Right(await dataSource.getTicket(ticketId));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioError(e));
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, SupportTicketModel>> createTicket(
    CreateSupportTicketParams params,
  ) async {
    try {
      return Right(await dataSource.createTicket(params));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioError(e));
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, SupportTicketMessageEntity>> replyTicket(
    ReplySupportTicketParams params,
  ) async {
    try {
      return Right(await dataSource.replyTicket(params));
    } catch (e) {
      if (e is DioException) return Left(ServerFailure.fromDioError(e));
      return Left(GeneralError(e));
    }
  }
}
