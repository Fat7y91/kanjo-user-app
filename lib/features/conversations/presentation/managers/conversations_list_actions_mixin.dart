import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/conversations/domain/entities/conversation_entity.dart';
import 'package:heraj/features/conversations/presentation/view/conversation_chat_screen.dart';

mixin ConversationsListActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  void openConversation(ConversationEntity conversation) {
    Get.to(() => ConversationChatScreen(conversation: conversation));
  }
}
