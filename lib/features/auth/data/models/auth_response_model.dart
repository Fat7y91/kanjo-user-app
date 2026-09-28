import '../../../../models/user_model.dart';

/// Top-level auth API payload (login / register / otp verify).
class AuthResponseModel {
  final bool success;
  final String message;
  final AuthDataModel? data;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] is Map
          ? AuthDataModel.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }

  UserAuthResponseModel toUserAuthResponse() {
    return UserAuthResponseModel(
      token: data?.token,
      user: data?.user,
      message: message,
      verificationRequired: data?.verificationRequired ?? false,
      pendingVerification: data?.pendingVerification ?? const [],
    );
  }
}

class AuthDataModel {
  final UserModel? user;
  final String? token;
  final bool verificationRequired;
  final List<String> pendingVerification;

  AuthDataModel({
    this.user,
    this.token,
    this.verificationRequired = false,
    this.pendingVerification = const [],
  });

  factory AuthDataModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    return AuthDataModel(
      user: userJson != null ? UserModel.fromJson(userJson) : null,
      token: json['token'] as String?,
      verificationRequired: json['verification_required'] ?? false,
      pendingVerification: (json['pending_verification'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'token': token,
      'verification_required': verificationRequired,
      'pending_verification': pendingVerification,
    };
  }
}
