class ConversationChannelEntity {
  final String channel;
  final String event;

  const ConversationChannelEntity({
    required this.channel,
    required this.event,
  });

  factory ConversationChannelEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const ConversationChannelEntity(channel: '', event: '');
    }
    return ConversationChannelEntity(
      channel: json['channel']?.toString() ?? '',
      event: json['event']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channel': channel,
      'event': event,
    };
  }
}

class ConversationSubscriptionsEntity {
  final ConversationChannelEntity user;
  final ConversationChannelEntity conversation;

  const ConversationSubscriptionsEntity({
    required this.user,
    this.conversation = const ConversationChannelEntity(channel: '', event: ''),
  });

  factory ConversationSubscriptionsEntity.fromJson(
    Map<String, dynamic>? json,
  ) {
    final userJson = json?['user'];
    final conversationJson = json?['conversation'];
    return ConversationSubscriptionsEntity(
      user: ConversationChannelEntity.fromJson(
        userJson is Map ? Map<String, dynamic>.from(userJson) : null,
      ),
      conversation: ConversationChannelEntity.fromJson(
        conversationJson is Map
            ? Map<String, dynamic>.from(conversationJson)
            : null,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'conversation': conversation.toJson(),
    };
  }
}
