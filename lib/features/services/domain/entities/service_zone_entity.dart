import 'services_json.dart';

class ServiceZoneEntity {
  final int id;
  final String name;

  const ServiceZoneEntity({
    required this.id,
    required this.name,
  });

  factory ServiceZoneEntity.fromJson(Map<String, dynamic> json) {
    return ServiceZoneEntity(
      id: asInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
