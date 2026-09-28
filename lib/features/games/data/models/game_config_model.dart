import '../../domain/entities/game_config_limits_entity.dart';

class GameConfigModel {
  const GameConfigModel({
    required this.enabled,
    required this.businessTimezone,
    required this.limits,
  });

  final bool enabled;
  final String businessTimezone;
  final GameConfigLimitsEntity limits;

  factory GameConfigModel.fromJson(Map<String, dynamic> json) {
    return GameConfigModel(
      enabled: json['enabled'] == true,
      businessTimezone: json['business_timezone']?.toString() ?? '',
      limits: GameConfigLimitsEntity.fromJson(
        json['limits'] is Map
            ? Map<String, dynamic>.from(json['limits'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'business_timezone': businessTimezone,
        'limits': limits.toJson(),
      };
}
