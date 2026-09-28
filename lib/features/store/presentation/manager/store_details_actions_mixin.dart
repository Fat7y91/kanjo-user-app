import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/conversations/domain/use_case/start_conversation_use_case.dart';
import 'package:heraj/features/conversations/presentation/managers/conversations_provider.dart';
import 'package:heraj/features/conversations/presentation/view/conversation_chat_screen.dart';
import 'package:heraj/features/services/domain/entities/provider_service_entity.dart';
import 'package:heraj/features/services/domain/use_case/fetch_service_provider_use_case.dart';
import 'package:heraj/features/services/presentation/view/book_service_screen.dart';
import 'package:heraj/features/vendor/data/models/vendor_model.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

mixin StoreDetailsActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<void> startPharmacyConversation(VendorModel vendor) async {
    const loadingKey = 'startVendorConversation';
    if (ref.read(isLoadingProvider(loadingKey))) return;

    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final result =
          await getIt<StartConversationUseCase>().call(vendor.id);
      result.fold(
        (failure) {
          UIHelper.showAlert(failure.message, type: DialogType.error);
        },
        (conversation) {
          ref.invalidate(fetchConversationsProvider);
          Get.to(
            () => ConversationChatScreen(
              conversation: conversation,
              vendor: vendor,
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }

  Future<void> openBookService({
    required ProviderServiceEntity service,
    required VendorModel vendor,
  }) async {
    const loadingKey = 'openBookService';
    if (ref.read(isLoadingProvider(loadingKey))) return;

    final providerId = service.serviceProviderId > 0
        ? service.serviceProviderId
        : vendor.id;
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      ServiceProviderEntity? provider;
      final result =
          await getIt<FetchServiceProviderUseCase>().call(providerId);
      result.fold((_) {}, (value) => provider = value);
      provider ??= ServiceProviderEntity(
        id: providerId,
        companyName: service.provider?.companyName ?? vendor.name,
        description: service.description,
        address: '',
        phone: '',
        daysSinceJoin: 0,
        ordersCount: 0,
        coverImageUrl:
            service.provider?.coverImageUrl ?? vendor.coverImageUrl,
        profileImageUrl: vendor.logoUrl,
        serviceType: service.serviceType,
        ratingSummary: vendor.ratingSummary,
        services: [service],
      );
      if (!mounted) return;
      Get.to(
        () => BookServiceScreen(
          provider: provider!,
          service: service,
        ),
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }
}
