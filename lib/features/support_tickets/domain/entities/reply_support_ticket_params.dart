class ReplySupportTicketParams {
  const ReplySupportTicketParams({
    required this.ticketId,
    required this.message,
  });

  final int ticketId;
  final String message;

  factory ReplySupportTicketParams.fromJson(Map<String, dynamic> json) {
    return ReplySupportTicketParams(
      ticketId: _intFrom(json['ticket_id']),
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'ticket_id': ticketId,
        'message': message,
      };
}

int _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
