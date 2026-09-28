import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as gg;
import '../../features/auth/presentation/view/login_page.dart';
import '../../features/splash/presentation/managers/splash_provider.dart';
import '../../main.dart';
import '../service/local_data_manager.dart';
import '../service/webservice/dio_helper.dart';

class GeneralError extends Failure {
  GeneralError(e, [String? text])
      : super(text ?? e?.toString() ?? 'There was an Error, Please try again');
}

class StopFailure extends Failure {
  StopFailure([String? reason])
      : super(reason ?? 'There was an Error, Please try again');
}

class PendingVerificationFailure extends Failure {
  final List<String> pendingVerification;

  PendingVerificationFailure({
    required this.pendingVerification,
    String? message,
  }) : super(
          message ??
              'Account verification is required before you can continue.',
        );

  List<String> get normalizedPending => pendingVerification
      .map((e) => e.toLowerCase().trim())
      .where((e) => e.isNotEmpty)
      .toList();

  bool get needsPhone => normalizedPending.contains('phone');

  bool get needsEmail => normalizedPending.contains('email');
}

List<String>? pendingVerificationFromResponse(dynamic data) {
  if (data is! Map) return null;
  final root = Map<String, dynamic>.from(data);
  final nestedData = root['data'];
  final errors = root['errors'] is Map
      ? Map<String, dynamic>.from(root['errors'] as Map)
      : (nestedData is Map && nestedData['errors'] is Map
          ? Map<String, dynamic>.from(nestedData['errors'] as Map)
          : null);

  final pending = errors?['pending_verification'] ??
      root['pending_verification'] ??
      (nestedData is Map ? nestedData['pending_verification'] : null);
  if (pending is! List || pending.isEmpty) return null;
  return pending.map((e) => e.toString().toLowerCase().trim()).toList();
}

class ServerFailure extends Failure {
  ServerFailure(super.message);

  factory ServerFailure.fromDioError(DioException e) {
    logger.e(e.response);
    if (e.response?.statusCode == 401 &&
        (dataManager.getToken() ?? '').isNotEmpty) {
      dataManager.removeLoggedUser();
      if (gg.Get.currentRoute != "/$LoginPage") {
        gg.Get.snackbar("Session Expired".tr, "Please login again".tr);
        gg.Get.offAll(() => const LoginPage());
      }
    }
    if (e.type == DioExceptionType.connectionError &&
        e.error is SocketException) {
      providerContainer.read(hasInternetProvider2.notifier).state = false;
    }

    return switch (e.type) {
      DioExceptionType.badResponse => ServerFailure.fromResponse(e.response),
      _ => ServerFailure(e.message ?? 'Something went wrong'),
    };
  }

  static String getMessage(int? code) {
    switch (code) {
      case 400:
        return 'Bad Request';
      case 401:
        return "No active account found with the given credentials";
      case 403:
        return "You are not authorized to access this endpoint";
      case 404:
        return "The endpoint you are trying to access is not found";
      case 406:
        return "Code Expired or not correct";
      case 500:
        return "Something went wrong";
      case 503:
        return "Service is unavailable";
      default:
        return "Something went wrong";
    }
  }

  factory ServerFailure.fromResponse(Response<dynamic>? response) {
    String error;

    if (response?.data['errors'] != null &&
        response?.data['errors'] is String) {
      error = response?.data['errors'];
    } else if (response?.data['message'] != null &&
        response?.data['message'] is String) {
      error = response?.data['message'];
    } else {
      error = getMessage(response?.statusCode);
    }
    return ServerFailure(error);
  }
}

abstract class Failure {
  final String message;

  Failure(this.message);

  @override
  String toString() {
    return message;
  }
}
