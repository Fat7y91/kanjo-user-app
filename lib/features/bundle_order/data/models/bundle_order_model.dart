import '../../domain/entities/bundle_order_entity.dart';

class BundleOrderModel extends BundleOrderEntity {
  const BundleOrderModel({
    required super.id,
    required super.code,
    required super.status,
    super.notes,
    super.host,
    required super.isHost,
    super.participants,
    super.itemCount,
    super.subtotal,
    super.bundleShippingFactor,
    super.createdAt,
  });

  factory BundleOrderModel.fromJson(Map<String, dynamic> json) {
    final entity = BundleOrderEntity.fromJson(json);
    return BundleOrderModel(
      id: entity.id,
      code: entity.code,
      status: entity.status,
      notes: entity.notes,
      host: entity.host,
      isHost: entity.isHost,
      participants: entity.participants,
      itemCount: entity.itemCount,
      subtotal: entity.subtotal,
      bundleShippingFactor: entity.bundleShippingFactor,
      createdAt: entity.createdAt,
    );
  }
}
