import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/support_tickets/data/models/support_ticket_model.dart';
import 'package:heraj/features/support_tickets/presentation/managers/support_ticket_details_actions_mixin.dart';
import 'package:heraj/features/support_tickets/presentation/managers/support_tickets_provider.dart';
import 'package:heraj/features/support_tickets/presentation/view/widgets/support_ticket_composer.dart';
import 'package:heraj/features/support_tickets/presentation/view/widgets/support_ticket_message_bubble.dart';
import 'package:heraj/helper/format_date.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class SupportTicketDetailsScreen extends ConsumerStatefulWidget {
  const SupportTicketDetailsScreen({
    super.key,
    required this.ticketId,
  });

  final int ticketId;

  @override
  ConsumerState<SupportTicketDetailsScreen> createState() =>
      _SupportTicketDetailsScreenState();
}

class _SupportTicketDetailsScreenState
    extends ConsumerState<SupportTicketDetailsScreen>
    with SupportTicketDetailsActionsMixin {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  int get ticketId => widget.ticketId;

  @override
  TextEditingController get replyController => _replyController;

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onSend() async {
    final sent = await sendReply();
    if (sent) _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(supportTicketDetailsProvider(ticketId));
    final isSending = ref.watch(isLoadingProvider('replySupportTicket'));

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColor.pageBackgroundGrey,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColor.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Ticket details'.tr,
          style: AppFont.font18W700Black,
        ),
        centerTitle: true,
      ),
      body: ticketAsync.customWhen(
        ref: ref,
        refreshable: supportTicketDetailsProvider(ticketId).future,
        loading: () => const PageLoadingWidget(),
        data: (ticket) {
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(supportTicketDetailsProvider(ticketId));
                    try {
                      await ref.read(
                        supportTicketDetailsProvider(ticketId).future,
                      );
                    } catch (_) {}
                  },
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      _TicketHeaderCard(ticket: ticket),
                      if (ticket.messages.isNotEmpty) ...[
                        const Gap(20),
                        ...ticket.messages.map(
                          (message) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SupportTicketMessageBubble(
                              message: message,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!ticket.isClosed)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.paddingOf(context).bottom + 12,
                  ),
                  child: SupportTicketComposer(
                    controller: _replyController,
                    isSending: isSending,
                    onSend: _onSend,
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.paddingOf(context).bottom + 16,
                  ),
                  child: Text(
                    'This ticket is closed'.tr,
                    textAlign: TextAlign.center,
                    style: AppFont.font12w500Grey2,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TicketHeaderCard extends StatelessWidget {
  const _TicketHeaderCard({required this.ticket});

  final SupportTicketModel ticket;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(ticket.status);
    final dateText = ticket.createdAt == null
        ? ''
        : FormatDate.call(ticket.createdAt, addJm: true);
    final attachment = ticket.attachment?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.title,
                  style: AppFont.font16W700Black,
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(28),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.statusLabel.tr,
                  style: AppFont.font12W600White.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (dateText.isNotEmpty) ...[
            const Gap(8),
            Text(dateText, style: AppFont.font12w500Grey2),
          ],
          if (ticket.description.trim().isNotEmpty) ...[
            const Gap(12),
            Text(
              ticket.description,
              style: AppFont.font14W500Black,
            ),
          ],
          if (attachment != null && attachment.isNotEmpty) ...[
            const Gap(12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 160,
                child: ImageOrSvg(
                  attachment,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'answered':
      case 'open':
      case 'in_progress':
        return AppColor.primary;
      case 'closed':
      case 'resolved':
        return AppColor.grey2;
      default:
        return AppColor.guestOrange;
    }
  }
}
