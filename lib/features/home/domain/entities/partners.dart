class Partner {
  final int partnerId;
  final String? partnerImage;
  final String? partnerName;

  Partner({
    required this.partnerId,
    this.partnerImage,
    this.partnerName,
  });

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
    partnerId: json["partner_id"],
    partnerImage: json["partner_image"],
    partnerName: json["partner_name"],
  );

  Map<String, dynamic> toJson() => {
    "partner_id": partnerId,
    "partner_image": partnerImage,
    "partner_name": partnerName,
  };
}