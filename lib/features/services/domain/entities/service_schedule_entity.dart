import 'services_json.dart';

class ServiceScheduleEntity {
  final int dayOfWeek;
  final bool isClosed;
  final String opensAt;
  final String closesAt;

  const ServiceScheduleEntity({
    required this.dayOfWeek,
    required this.isClosed,
    required this.opensAt,
    required this.closesAt,
  });

  factory ServiceScheduleEntity.fromJson(Map<String, dynamic> json) {
    return ServiceScheduleEntity(
      dayOfWeek: asInt(json['day_of_week']),
      isClosed: json['is_closed'] == true,
      opensAt: json['opens_at']?.toString() ?? '09:00',
      closesAt: json['closes_at']?.toString() ?? '17:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'is_closed': isClosed,
      'opens_at': opensAt,
      'closes_at': closesAt,
    };
  }
}
