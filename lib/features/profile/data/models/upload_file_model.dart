class UploadFileModel {
  String filePath;

  UploadFileModel({required this.filePath});

  UploadFileModel.fromJson(Map<String, dynamic> json) : filePath = json['data'];
}
