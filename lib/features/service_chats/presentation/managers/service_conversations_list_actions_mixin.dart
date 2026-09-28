import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/features/service_chats/domain/entities/service_conversation_entity.dart';
import 'package:heraj/features/service_chats/presentation/view/service_chat_screen.dart';

mixin ServiceConversationsListActionsMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  void openServiceConversation(ServiceConversationEntity conversation) {
    Get.to(() => ServiceChatScreen(conversation: conversation));
  }
}
