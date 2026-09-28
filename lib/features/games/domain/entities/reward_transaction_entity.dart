class RewardTransactionEntity {
  const RewardTransactionEntity({
    required this.id,
    required this.points,
    required this.balanceAfter,
    required this.type,
    required this.source,
    required this.metadata,
    this.rewardId,
    this.referenceId,
    this.note,
    this.createdAt,
  });

  final int id;
  final int? rewardId;
  final int points;
  final int balanceAfter;
  final String type;
  final String source;
  final String? referenceId;
  final String? note;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  int? get gameId {
    final raw = metadata['game_id'];
    if (raw == null) return null;
    return int.tryParse(raw.toString());
  }

  bool get isCredit {
    final t = type.toLowerCase();
    if (t.contains('redeem') ||
        t.contains('spend') ||
        t.contains('debit')) {
      return false;
    }
    return true;
  }

  String get titleKey {
    final n = note?.trim() ?? '';
    if (n.isNotEmpty) return n;
    switch (gameId) {
      case 1:
        return 'Flying Bird';
      case 2:
        return 'Gun Shooter';
      case 3:
        return 'Arena Survival';
    }
    if (source.toLowerCase() == 'mobile_game') return 'Game points';
    if (type.toLowerCase() == 'admin_adjustment') return 'Admin adjustment';
    if (type.toLowerCase() == 'redeem') return 'Redeemed';
    if (type.toLowerCase() == 'earn') return 'Earn';
    return type;
  }

  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'earn':
        return 'Earn';
      case 'admin_adjustment':
        return 'Admin adjustment';
      case 'redeem':
        return 'Redeemed';
      default:
        return type;
    }
  }

  factory RewardTransactionEntity.fromJson(Map<String, dynamic> json) {
    return RewardTransactionEntity(
      id: _intFrom(json['id']),
      rewardId: json['reward_id'] == null ? null : _intFrom(json['reward_id']),
      points: _intFrom(json['points']),
      balanceAfter: _intFrom(json['balance_after']),
      type: json['type']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      referenceId: json['reference_id']?.toString(),
      note: json['note']?.toString(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const <String, dynamic>{},
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reward_id': rewardId,
        'points': points,
        'balance_after': balanceAfter,
        'type': type,
        'source': source,
        'reference_id': referenceId,
        'note': note,
        'metadata': metadata,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
