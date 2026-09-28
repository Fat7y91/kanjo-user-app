class CreateServiceOrderParams {
  const CreateServiceOrderParams({
    required this.providerServiceId,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.latitude,
    required this.longitude,
    required this.paymentMethod,
    this.addressText,
    this.customerNotes,
  });

  final int providerServiceId;
  final String scheduledDate;
  final String scheduledTime;
  final double latitude;
  final double longitude;
  final String paymentMethod;
  final String? addressText;
  final String? customerNotes;
}
