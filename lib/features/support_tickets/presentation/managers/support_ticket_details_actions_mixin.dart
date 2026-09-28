import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/support_tickets/domain/entities/reply_support_ticket_params.dart';
import 'package:heraj/features/support_tickets/domain/use_case/support_tickets_use_cases.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

import 'support_tickets_provider.dart';

mixin SupportTicketDetailsActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  int get ticketId;
  TextEditingController get replyController;

  Future<bool> sendReply() async {
    final message = replyController.text.trim();
    if (message.isEmpty) return false;

    const loadingKey = 'replySupportTicket';
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final result = await getIt<ReplySupportTicketUseCase>().call(
        ReplySupportTicketParams(ticketId: ticketId, message: message),
      );
      return result.fold(
        (failure) {
          UIHelper.showAlert(failure.message, type: DialogType.error);
          return false;
        },
        (_) {
          replyController.clear();
          ref.invalidate(supportTicketDetailsProvider(ticketId));
          ref.invalidate(fetchSupportTicketsProvider);
          return true;
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }
}
