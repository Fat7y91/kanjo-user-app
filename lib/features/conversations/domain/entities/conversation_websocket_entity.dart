class ConversationWebsocketEntity {
  final String channel;
  final String event;

  const ConversationWebsocketEntity({
    required this.channel,
    required this.event,
  });

  factory ConversationWebsocketEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const ConversationWebsocketEntity(channel: '', event: '');
    }
    return ConversationWebsocketEntity(
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
