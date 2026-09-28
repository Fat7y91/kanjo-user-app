import 'bundle_order_host_entity.dart';
import 'bundle_order_item_entity.dart';
import 'bundle_order_participant_entity.dart';

class BundleOrderEntity {
  final int id;
  final String code;
  final String status;
  final String? notes;
  final BundleOrderHostEntity? host;
  final bool isHost;
  final List<BundleOrderParticipantEntity> participants;
  final int itemCount;
  final double subtotal;
  final double? bundleShippingFactor;
  final DateTime? createdAt;

  const BundleOrderEntity({
    required this.id,
    required this.code,
    required this.status,
    this.notes,
    this.host,
    required this.isHost,
    this.participants = const [],
    this.itemCount = 0,
    this.subtotal = 0,
    this.bundleShippingFactor,
    this.createdAt,
  });

  List<BundleOrderItemEntity> get allItems =>
      participants.expand((participant) => participant.items).toList();

  factory BundleOrderEntity.fromJson(Map<String, dynamic> json) {
    final participantsRaw = json['participants'];
    final participants = participantsRaw is List
        ? participantsRaw
            .whereType<Map>()
            .map(
              (e) => BundleOrderParticipantEntity.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList()
        : <BundleOrderParticipantEntity>[];

    final legacyItemsRaw = json['items'] ?? json['bundle_items'];
    final legacyParticipants = legacyItemsRaw is List && participants.isEmpty
        ? [
            BundleOrderParticipantEntity(
              userId: 0,
              name: '',
              items: legacyItemsRaw
                  .whereType<Map>()
                  .map(
                    (e) => BundleOrderItemEntity.fromJson(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList(),
              subtotal: _doubleFrom(json['subtotal']),
            ),
          ]
        : participants;

    return BundleOrderEntity(
      id: _intFrom(json['id']),
      code: json['code']?.toString() ??
          json['bundle_code']?.toString() ??
          '',
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      host: json['host'] is Map
          ? BundleOrderHostEntity.fromJson(
              Map<String, dynamic>.from(json['host'] as Map),
            )
          : null,
      isHost: json['is_host'] == true ||
          json['is_host'] == 1 ||
          json['isHost'] == true,
      participants: legacyParticipants,
      itemCount: _intFrom(json['item_count']),
      subtotal: _doubleFrom(json['subtotal']),
      bundleShippingFactor: json['bundle_shipping_factor'] == null
          ? null
          : _doubleFrom(json['bundle_shipping_factor']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'status': status,
        'notes': notes,
        if (host != null) 'host': host!.toJson(),
        'is_host': isHost,
        'participants': participants.map((e) => e.toJson()).toList(),
        'item_count': itemCount,
        'subtotal': subtotal,
        if (bundleShippingFactor != null)
          'bundle_shipping_factor': bundleShippingFactor,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  static int _intFrom(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _doubleFrom(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
