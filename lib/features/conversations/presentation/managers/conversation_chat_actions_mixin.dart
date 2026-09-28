import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/image_picker_cropper.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_message_entity.dart';
import 'package:heraj/features/conversations/domain/use_case/accept_conversation_quote_use_case.dart';
import 'package:heraj/features/conversations/domain/use_case/send_conversation_message_use_case.dart';
import 'package:heraj/features/conversations/presentation/managers/conversations_provider.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';
import 'package:image_picker/image_picker.dart';

mixin ConversationChatActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Future<bool> sendConversationMessage({
    required int conversationId,
    required String body,
    File? imageFile,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty && imageFile == null) {
      return false;
    }

    const loadingKey = 'sendConversationMessage';
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final result = await getIt<SendConversationMessageUseCase>().call(
        SendConversationMessageParams(
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
              .read(conversationMessagesProvider(conversationId).notifier)
              .appendMessage(sent.message);
          final conversationsNotifier =
              ref.read(fetchConversationsProvider.notifier);
          if (sent.conversation != null) {
            conversationsNotifier.upsertConversation(sent.conversation!);
          } else {
            ref.invalidate(fetchConversationsProvider);
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
    return sendConversationMessage(
      conversationId: conversationId,
      body: body,
      imageFile: file,
    );
  }

  Future<void> acceptQuoteMessage({
    required int conversationId,
    required ConversationMessageEntity message,
  }) async {
    const loadingKey = 'acceptConversationQuote';
    ref.read(isLoadingProvider(loadingKey).notifier).state = true;
    try {
      final result = await getIt<AcceptConversationQuoteUseCase>().call(
        AcceptConversationQuoteParams(
          conversationId: conversationId,
          quoteMessageId: message.id,
        ),
      );
      result.fold(
        (failure) {
          UIHelper.showAlert(failure.message, type: DialogType.error);
        },
        (_) {
          final meta = {
            ...?message.meta,
            'status': 'accepted',
            'accepted': true,
          };
          ref
              .read(conversationMessagesProvider(conversationId).notifier)
              .replaceMessage(message.copyWith(meta: meta));
          UIHelper.showGlobalSnackBar(text: 'Quote accepted'.tr);
        },
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider(loadingKey).notifier).state = false;
      }
    }
  }
}
