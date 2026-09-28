import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../data/models/support_ticket_model.dart';
import '../../domain/use_case/support_tickets_use_cases.dart';

final fetchSupportTicketsProvider =
    FutureProvider.autoDispose<List<SupportTicketModel>>((ref) async {
  final res = await getIt<FetchSupportTicketsUseCase>().call();
  return res.fold((l) => throw l, (r) => r);
});

final supportTicketDetailsProvider = FutureProvider.autoDispose
    .family<SupportTicketModel, int>((ref, ticketId) async {
  final res = await getIt<FetchSupportTicketDetailsUseCase>().call(ticketId);
  return res.fold((l) => throw l, (r) => r);
});
