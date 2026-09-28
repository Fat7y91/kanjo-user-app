class ConversationSyncEntity {
  final String strategy;
  final bool supportsIncrementalMessages;

  const ConversationSyncEntity({
    required this.strategy,
    required this.supportsIncrementalMessages,
  });

  factory ConversationSyncEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const ConversationSyncEntity(
        strategy: '',
        supportsIncrementalMessages: false,
      );
    }
    return ConversationSyncEntity(
      strategy: json['strategy']?.toString() ?? '',
      supportsIncrementalMessages:
          json['supports_incremental_messages'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strategy': strategy,
      'supports_incremental_messages': supportsIncrementalMessages,
    };
  }
}
