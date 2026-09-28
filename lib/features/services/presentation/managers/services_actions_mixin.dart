import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/service_chats/domain/use_case/start_service_conversation_use_case.dart';
import 'package:heraj/features/service_chats/presentation/managers/service_chats_provider.dart';
import 'package:heraj/features/service_chats/presentation/view/service_chat_screen.dart';
import 'package:heraj/features/services/domain/entities/create_service_order_params.dart';
import 'package:heraj/features/services/domain/entities/provider_service_entity.dart';
import 'package:heraj/features/services/domain/use_case/create_service_order_use_case.dart';
import 'package:heraj/features/services/presentation/managers/service_orders_provider.dart';
import 'package:heraj/features/services/presentation/view/book_service_screen.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

mixin ServiceProviderDetailsActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<void> callProvider(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) {
      UIHelper.showAlert('Phone number not available'.tr, type: DialogType.info);
      return;
    }
    await UIHelper.phoneCall(cleaned);
  }

  Future<void> messageProvider({
    required int providerId,
    required String companyName,
  }) async {
    const loadingKey = 'startServiceConversation';
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final result =
          await getIt<StartServiceConversationUseCase>().call(providerId);
      result.fold(
        (failure) {
          UIHelper.showAlert(failure.message, type: DialogType.error);
        },
        (conversation) {
          ref.invalidate(fetchServiceConversationsProvider);
          Get.to(() => ServiceChatScreen(conversation: conversation));
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }

  void openBookService({
    required ServiceProviderEntity provider,
    ProviderServiceEntity? service,
  }) {
    final selected = service ??
        (provider.services.isNotEmpty ? provider.services.first : null);
    if (selected == null) {
      UIHelper.showAlert('No services available'.tr, type: DialogType.info);
      return;
    }
    Get.to(
      () => BookServiceScreen(
        provider: provider,
        service: selected,
      ),
    );
  }
}

mixin BookServiceActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<bool> submitServiceOrder(CreateServiceOrderParams params) async {
    const loadingKey = 'createServiceOrder';
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final result = await getIt<CreateServiceOrderUseCase>().call(params);
      return result.fold(
        (failure) {
          UIHelper.showAlert(failure.message, type: DialogType.error);
          return false;
        },
        (_) {
          ref.invalidate(fetchMyServiceOrdersProvider);
          UIHelper.showGlobalSnackBar(text: 'Service booked successfully'.tr);
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
