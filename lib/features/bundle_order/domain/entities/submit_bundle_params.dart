class SubmitBundleParams {
  const SubmitBundleParams({
    required this.code,
    required this.addressId,
    this.notes,
    this.tip,
    this.rewardId,
    this.walletAmount,
  });

  final String code;
  final int addressId;
  final String? notes;
  final double? tip;
  final int? rewardId;
  final double? walletAmount;

  Map<String, dynamic> toJson() {
    final body = <String, dynamic>{
      'address_id': addressId,
      'tip': tip ?? 0,
    };
    final trimmedNotes = notes?.trim();
    if (trimmedNotes != null && trimmedNotes.isNotEmpty) {
      body['notes'] = trimmedNotes;
    }
    if (rewardId != null) {
      body['reward_id'] = rewardId;
    }
    if (walletAmount != null) {
      body['wallet_amount'] = walletAmount;
    }
    return body;
  }
}
