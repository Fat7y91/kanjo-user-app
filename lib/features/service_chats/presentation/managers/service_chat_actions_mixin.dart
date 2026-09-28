import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/service/image_picker_cropper.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/service_chats/domain/use_case/send_service_chat_message_use_case.dart';
import 'package:heraj/features/service_chats/presentation/managers/service_chats_provider.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';
import 'package:image_picker/image_picker.dart';

mixin ServiceChatActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<bool> sendServiceChatMessage({
    required int conversationId,
    required String body,
    File? imageFile,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty && imageFile == null) {
      return false;
    }

    const loadingKey = 'sendServiceChatMessage';
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final result = await getIt<SendServiceChatMessageUseCase>().call(
        SendServiceChatMessageParams(
          conversationId: conversationId,
          body: trimmed,
          imageFile: imageFile,
        ),
      );
      return result.fold(
        (failure) {
          UIHelper.showAlert(failure.message, type: DialogType.error);
          return false;
        },
        (sent) {
          ref
              .read(serviceChatMessagesProvider(conversationId).notifier)
              .appendMessage(sent.message);
          final conversationsNotifier =
              ref.read(fetchServiceConversationsProvider.notifier);
          if (sent.conversation != null) {
            conversationsNotifier.upsertConversation(sent.conversation!);
          } else {
            ref.invalidate(fetchServiceConversationsProvider);
          }
          return true;
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }

  Future<bool> attachAndSendImage({
    required int conversationId,
    String body = '',
  }) async {
    final file = await getIt<ImagePickerService>().pickImage(
      crop: false,
      source: ImageSource.gallery,
    );
    if (file == null) return false;
    return sendServiceChatMessage(
      conversationId: conversationId,
      body: body,
      imageFile: file,
    );
  }
}
