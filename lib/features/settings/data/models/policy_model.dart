import '../../domain/entities/message_entity.dart';

// class PrivacyPolicyModel {
//   final List<Message>? message;
//   final String? status;
//
//   PrivacyPolicyModel({
//     required this.message,
//     required this.status,
//   });
//
//   factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
//     return PrivacyPolicyModel(
//       status: json["status"],
//       message: json["message"] != null
//           ? List<Message>.from(json["message"].map((x) => Message.fromJson(x)))
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message != null
//             ? List<dynamic>.from(message!.map((x) => x.toJson()))
//             : null,
//       };
// }
