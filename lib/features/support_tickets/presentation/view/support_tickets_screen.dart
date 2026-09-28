import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/support_tickets/presentation/managers/support_tickets_actions_mixin.dart';
import 'package:heraj/features/support_tickets/presentation/managers/support_tickets_provider.dart';
import 'package:heraj/features/support_tickets/presentation/view/widgets/support_ticket_card.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';
import 'package:heraj/ui/shared_widgets/not_found_widget.dart';

class SupportTicketsScreen extends ConsumerStatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  ConsumerState<SupportTicketsScreen> createState() =>
      _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends ConsumerState<SupportTicketsScreen>
    with SupportTicketsActionsMixin {
  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(fetchSupportTicketsProvider);

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
          'Support tickets'.tr,
          style: AppFont.font18W700Black,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ticketsAsync.customWhen(
              ref: ref,
              refreshable: fetchSupportTicketsProvider.future,
              skipLoadingOnRefresh: true,
              loading: () => const PageLoadingWidget(),
              data: (tickets) {
                if (tickets.isEmpty) {
                  return Center(
                    child: NotFoundWidget(
                      title: 'No support tickets yet'.tr,
                      haveIcon: true,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(fetchSupportTicketsProvider);
                    try {
                      await ref.read(fetchSupportTicketsProvider.future);
                    } catch (_) {}
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: tickets.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return SupportTicketCard(
                        ticket: ticket,
                        onTap: () => openTicketDetails(ticket.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.paddingOf(context).bottom + 16,
            ),
            color: AppColor.pageBackgroundGrey,
            child: CustomFilledButton(
              text: 'New ticket'.tr,
              onPressed: openCreateTicket,
            ),
          ),
        ],
      ),
    );
  }
}
