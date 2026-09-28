import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../view/create_support_ticket_screen.dart';
import '../view/support_ticket_details_screen.dart';
import 'support_tickets_provider.dart';

mixin SupportTicketsActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  void openTicketDetails(int ticketId) {
    Get.to(() => SupportTicketDetailsScreen(ticketId: ticketId));
  }

  Future<void> openCreateTicket() async {
    final created = await Get.to<bool>(() => const CreateSupportTicketScreen());
    if (created == true && mounted) {
      ref.invalidate(fetchSupportTicketsProvider);
    }
  }
}
