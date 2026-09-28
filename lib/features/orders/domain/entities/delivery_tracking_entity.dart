import 'package:flutter/foundation.dart';

@immutable
class DeliveryTrackingEntity {
  const DeliveryTrackingEntity({
    required this.channel,
    required this.event,
  });

  /// Reverb channel from API, e.g. `private-customer.orders.149.tracking`.
  final String channel;

  /// Echo event from API, e.g. `delivery.partner.location.updated`.
  final String event;

  bool get isValid => channel.isNotEmpty && event.isNotEmpty;

  factory DeliveryTrackingEntity.fromJson(Map<String, dynamic> json) {
    return DeliveryTrackingEntity(
      channel: (json['channel'] ?? json['channel_name'] ?? '')
          .toString()
          .trim(),
      event: (json['event'] ?? json['event_name'] ?? '')
          .toString()
          .trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'channel': channel,
        'event': event,
      };

  static DeliveryTrackingEntity? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final parsed = DeliveryTrackingEntity.fromJson(
      Map<String, dynamic>.from(raw),
    );
    return parsed.isValid ? parsed : null;
  }
}
