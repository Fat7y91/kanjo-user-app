class CreateSupportTicketParams {
  const CreateSupportTicketParams({
    required this.title,
    required this.description,
    this.attachmentPath,
  });

  final String title;
  final String description;
  final String? attachmentPath;

  factory CreateSupportTicketParams.fromJson(Map<String, dynamic> json) {
    return CreateSupportTicketParams(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      attachmentPath: json['attachment_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'attachment_path': attachmentPath,
      };
}
