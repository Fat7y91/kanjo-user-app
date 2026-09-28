import 'package:dio/dio.dart';
import '../../../../config/api_path.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/create_support_ticket_params.dart';
import '../../domain/entities/reply_support_ticket_params.dart';
import '../../domain/entities/support_ticket_message_entity.dart';
import '../models/support_ticket_model.dart';

abstract class SupportTicketsDataSource {
  Future<PaginatedResponse<SupportTicketModel>> getTickets({
    int page = 1,
    int perPage = PaginationConfig.perPage,
  });

  Future<SupportTicketModel> getTicket(int ticketId);

  Future<SupportTicketModel> createTicket(CreateSupportTicketParams params);

  Future<SupportTicketMessageEntity> replyTicket(
    ReplySupportTicketParams params,
  );
}

class SupportTicketsDataSourceImpl extends SupportTicketsDataSource {
  SupportTicketsDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<PaginatedResponse<SupportTicketModel>> getTickets({
    int page = 1,
    int perPage = PaginationConfig.perPage,
  }) async {
    final res = await apiService.get(
      url: ApiPath.supportTickets,
      returnDataOnly: true,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    return parsePaginatedResponse(res, SupportTicketModel.fromJson);
  }

  @override
  Future<SupportTicketModel> getTicket(int ticketId) async {
    final res = await apiService.get(
      url: ApiPath.supportTicket(ticketId),
      returnDataOnly: true,
    );
    if (res is Map) {
      return SupportTicketModel.fromJson(Map<String, dynamic>.from(res));
    }
    return SupportTicketModel.fromJson(const <String, dynamic>{});
  }

  @override
  Future<SupportTicketModel> createTicket(
    CreateSupportTicketParams params,
  ) async {
    final map = <String, dynamic>{
      'title': params.title,
      'description': params.description,
    };
    final attachmentPath = params.attachmentPath?.trim();
    if (attachmentPath != null && attachmentPath.isNotEmpty) {
      map['attachment'] = await MultipartFile.fromFile(
        attachmentPath,
        filename: attachmentPath.split(RegExp(r'[\\/]')).last,
      );
    }

    final res = await apiService.post(
      url: ApiPath.supportTickets,
      requestBody: FormData.fromMap(map),
      returnDataOnly: true,
    );
    if (res is Map) {
      return SupportTicketModel.fromJson(Map<String, dynamic>.from(res));
    }
    return SupportTicketModel.fromJson(const <String, dynamic>{});
  }

  @override
  Future<SupportTicketMessageEntity> replyTicket(
    ReplySupportTicketParams params,
  ) async {
    final res = await apiService.post(
      url: ApiPath.supportTicketMessages(params.ticketId),
      requestBody: FormData.fromMap({
        'message': params.message,
      }),
      returnDataOnly: true,
    );
    if (res is Map) {
      return SupportTicketMessageEntity.fromJson(
        Map<String, dynamic>.from(res),
      );
    }
    return SupportTicketMessageEntity.fromJson(const <String, dynamic>{});
  }
}
