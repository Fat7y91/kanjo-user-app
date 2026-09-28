import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../../../../../config/api_path.dart';
import '../../../../../core/service/local_data_manager.dart';
import '../../../../../core/service/webservice/dio_helper.dart';
import '../../../../../models/user_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthDataSource {
  Future<UserAuthResponseModel> login(Map<String, dynamic> data);

  Future<UserAuthResponseModel> socialLogin(String idToken);

  Future<UserAuthResponseModel> register(Map<String, dynamic> data);

  Future<UserAuthResponseModel> vendorRegister(Map<String, dynamic> data);

  Future<UserAuthResponseModel> selectRole(String role);

  Future<UserModel> getMyProfile();

  Future<bool> logOut();

  Future<bool> deleteAccount();

  Future<PreLoginResponseModel> sendOtp(Map<String, dynamic> data);

  Future<UserAuthResponseModel> verifyOtp(Map<String, dynamic> data);

  Future<PreLoginResponseModel> sendEmailVerification();

  Future<PreLoginResponseModel> sendPhoneVerification();

  Future<UserAuthResponseModel> verifyEmailCode(String code);

  Future<UserAuthResponseModel> verifyPhoneCode(String code);

  /// Legacy alias used by older call sites.
  Future<PreLoginResponseModel> preLogin(Map<String, dynamic> data);

  Future<PreLoginResponseModel> forgotPassword(String phone);

  Future<PreLoginResponseModel> resetPassword({
    required String phone,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  });
}

class AuthDataSourceImpl extends AuthDataSource {
  final ApiService apiService;

  AuthDataSourceImpl(this.apiService);

  Future<void> _persistSession({
    required String? token,
    required UserModel? user,
  }) async {
    if (token != null && token.isNotEmpty) {
      await dataManager.setToken(token);
    }
    if (user != null) {
      await dataManager.setId(user.id);
    }
  }

  UserAuthResponseModel _fromAuthJson(
    Map<String, dynamic> res, {
    bool requireToken = true,
    bool requireUser = true,
  }) {
    final auth = AuthResponseModel.fromJson(res);
    final token = auth.data?.token;
    if (requireToken && (token == null || token.isEmpty)) {
      throw Exception('Invalid response: missing or empty token');
    }
    if (requireUser && auth.data?.user == null) {
      throw Exception('Invalid response: missing user field');
    }
    return auth.toUserAuthResponse();
  }

  @override
  Future<UserAuthResponseModel> login(Map<String, dynamic> data) async {
    final res = await apiService.post(
      url: ApiPath.userLogin,
      requestBody: {
        'phone': data['phone'],
        'password': data['password'],
        'fcm_token': data['fcm_token'] ?? dataManager.getFCMToken() ?? '',
      },
      returnDataOnly: false,
    );

    final auth = _fromAuthJson(res, requireToken: false);
    final needsPhoneVerification = auth.verificationRequired ||
        auth.pendingVerification.contains('phone');

    if (!needsPhoneVerification) {
      if (auth.token == null || auth.token!.isEmpty) {
        throw Exception('Invalid response: missing or empty token');
      }
      await _persistSession(token: auth.token, user: auth.user);
    } else if (auth.user != null) {
      await dataManager.setId(auth.user!.id);
    }

    return auth;
  }

  @override
  Future<UserAuthResponseModel> socialLogin(String idsToken) async {
    final res = await apiService.post(
      url: ApiPath.googleLogin,
      requestBody: {'idToken': idsToken},
      returnDataOnly: false,
    );

    final responseData = res['data'] as Map<String, dynamic>?;
    final tokens = responseData?['tokens'] as Map<String, dynamic>?;
    if (tokens == null) {
      throw Exception('Invalid response: missing tokens field');
    }

    final accessToken = tokens['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Invalid response: missing or empty accessToken');
    }

    final refreshToken = tokens['refreshToken'] as String?;
    await dataManager.setToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await dataManager.setRefreshToken(refreshToken);
    }

    final userData = responseData?['user'] as Map<String, dynamic>?;
    if (userData == null) {
      throw Exception('Invalid response: missing user field');
    }

    final user = UserModel.fromJson(userData);
    await dataManager.setId(user.id);

    return UserAuthResponseModel(
      message: res['message'] as String? ?? 'Logged in successfully',
      token: accessToken,
      needsRoleSelection: res['needsRoleSelection'] as bool? ?? false,
      user: user,
    );
  }

  @override
  Future<PreLoginResponseModel> sendOtp(Map<String, dynamic> data) async {
    final res = await apiService.post(
      url: ApiPath.sendOTP,
      requestBody: {
        'purpose': data['purpose'] ?? 'verify_phone',
        if (data['phone'] != null) 'phone': data['phone'],
        if (data['email'] != null) 'email': data['email'],
      },
      returnDataOnly: false,
    );
    return PreLoginResponseModel.fromJson(res);
  }

  @override
  Future<PreLoginResponseModel> preLogin(Map<String, dynamic> data) {
    return sendOtp(data);
  }

  @override
  Future<UserAuthResponseModel> verifyOtp(Map<String, dynamic> data) async {
    final code = (data['code'] ?? data['otp'])?.toString() ?? '';
    final alreadyHasToken = (dataManager.getToken() ?? '').isNotEmpty;

    final res = await apiService.post(
      url: ApiPath.verifyOTP,
      requestBody: {
        'purpose': data['purpose'] ?? 'verify_phone',
        'code': code,
        'fcm_token': data['fcm_token'] ?? dataManager.getFCMToken() ?? '',
        if (data['phone'] != null) 'phone': data['phone'],
        if (data['email'] != null) 'email': data['email'],
      },
      returnDataOnly: false,
    );

    try {
      final auth = _fromAuthJson(
        res,
        requireToken: !alreadyHasToken,
        requireUser: !alreadyHasToken,
      );
      await _persistSession(
        token: auth.token,
        user: auth.user ?? dataManager.getUser(),
      );
      return UserAuthResponseModel(
        token: auth.token ?? dataManager.getToken(),
        user: auth.user ?? dataManager.getUser(),
        message: auth.message,
        verificationRequired: auth.verificationRequired,
        pendingVerification: auth.pendingVerification,
      );
    } catch (_) {
      if (!alreadyHasToken) rethrow;
      return UserAuthResponseModel(
        token: dataManager.getToken(),
        user: dataManager.getUser(),
        message: res is Map ? res['message']?.toString() : null,
      );
    }
  }

  @override
  Future<UserAuthResponseModel> register(Map<String, dynamic> data) async {
    final formMap = <String, dynamic>{
      'name': data['name'],
      'email': data['email'],
      'phone': data['phone'],
      'password': data['password'],
      'password_confirmation':
          data['password_confirmation'] ?? data['password'],
      'fcm_token': data['fcm_token'] ?? dataManager.getFCMToken() ?? '',
      if (data['gender'] != null &&
          data['gender'].toString().trim().isNotEmpty)
        'gender': data['gender'].toString().trim().toLowerCase(),
    };

    final profileImage = data['profile_image'];
    if (profileImage is File) {
      formMap['profile_image'] = await MultipartFile.fromFile(
        profileImage.path,
        filename: path.basename(profileImage.path),
      );
    } else if (profileImage is String && profileImage.isNotEmpty) {
      formMap['profile_image'] = await MultipartFile.fromFile(
        profileImage,
        filename: path.basename(profileImage),
      );
    }

    final res = await apiService.post(
      url: ApiPath.userRegister,
      requestBody: FormData.fromMap(formMap),
      returnDataOnly: false,
    );

    final auth = _fromAuthJson(res, requireToken: false);
    if (auth.user != null) {
      await dataManager.setId(auth.user!.id);
    }
    return auth;
  }

  @override
  Future<UserAuthResponseModel> vendorRegister(
      Map<String, dynamic> data) async {
    final res = await apiService.post(
      url: ApiPath.vendorRegister,
      requestBody: data,
      returnDataOnly: false,
    );

    final responseData = res['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      throw Exception('Invalid response: missing data field');
    }

    final tokens = responseData['tokens'] as Map<String, dynamic>?;
    if (tokens == null) {
      throw Exception('Invalid response: missing tokens field');
    }

    final accessToken = tokens['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Invalid response: missing or empty accessToken');
    }

    final refreshToken = tokens['refreshToken'] as String?;
    await dataManager.setToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await dataManager.setRefreshToken(refreshToken);
    }

    final userData = responseData['user'] as Map<String, dynamic>?;
    if (userData == null) {
      throw Exception('Invalid response: missing user field');
    }

    final user = UserModel.fromJson(userData);
    await dataManager.setId(user.id);

    return UserAuthResponseModel(
      message: res['message'] as String? ?? 'Vendor registered successfully',
      token: accessToken,
      user: user,
    );
  }

  PreLoginResponseModel _parseSendVerification(dynamic res) {
    if (res is! Map) {
      return PreLoginResponseModel(success: true, message: '');
    }
    final json = Map<String, dynamic>.from(res);
    return PreLoginResponseModel(
      success: json['success'] ?? true,
      message: json['message']?.toString() ?? '',
    );
  }

  Future<UserAuthResponseModel> _verifyLoggedInCode({
    required String url,
    required String code,
  }) async {
    final res = await apiService.post(
      url: url,
      requestBody: {'code': code},
      returnDataOnly: false,
    );

    try {
      final auth = _fromAuthJson(
        res,
        requireToken: false,
        requireUser: false,
      );
      await _persistSession(
        token: auth.token,
        user: auth.user ?? dataManager.getUser(),
      );
      return UserAuthResponseModel(
        token: auth.token ?? dataManager.getToken(),
        user: auth.user ?? dataManager.getUser(),
        message: auth.message,
        verificationRequired: auth.verificationRequired,
        pendingVerification: auth.pendingVerification,
      );
    } catch (_) {
      return UserAuthResponseModel(
        token: dataManager.getToken(),
        user: dataManager.getUser(),
        message: res is Map ? res['message']?.toString() : null,
      );
    }
  }

  @override
  Future<PreLoginResponseModel> sendEmailVerification() async {
    final res = await apiService.post(
      url: ApiPath.sendEmailVerification,
      requestBody: const <String, dynamic>{},
      returnDataOnly: false,
    );
    return _parseSendVerification(res);
  }

  @override
  Future<PreLoginResponseModel> sendPhoneVerification() async {
    final res = await apiService.post(
      url: ApiPath.sendPhoneVerification,
      requestBody: const <String, dynamic>{},
      returnDataOnly: false,
    );
    return _parseSendVerification(res);
  }

  @override
  Future<UserAuthResponseModel> verifyEmailCode(String code) {
    return _verifyLoggedInCode(url: ApiPath.verifyEmail, code: code);
  }

  @override
  Future<UserAuthResponseModel> verifyPhoneCode(String code) {
    return _verifyLoggedInCode(url: ApiPath.verifyPhone, code: code);
  }

  @override
  Future<UserModel> getMyProfile() async {
    final response =
        await apiService.get(url: ApiPath.getUser, returnDataOnly: true);
    if (response is! Map) {
      throw Exception('Invalid profile response');
    }
    final data = Map<String, dynamic>.from(response);
    final userRaw = data['user'];
    final userJson = userRaw is Map
        ? Map<String, dynamic>.from(userRaw)
        : data;
    return UserModel.fromJson(userJson);
  }

  @override
  Future<bool> logOut() async {
    await apiService.post(url: ApiPath.logOut);
    return true;
  }

  @override
  Future<bool> deleteAccount() async {
    await apiService.post(url: ApiPath.deleteAccount);
    return true;
  }

  PreLoginResponseModel _messageResponse(dynamic res) {
    if (res is! Map) {
      return PreLoginResponseModel(success: true, message: '');
    }
    final model = PreLoginResponseModel.fromJson(Map<String, dynamic>.from(res));
    if (!model.success) {
      throw Exception(
        model.message.isEmpty ? 'Request failed' : model.message,
      );
    }
    return model;
  }

  @override
  Future<PreLoginResponseModel> forgotPassword(String phone) async {
    final res = await apiService.post(
      url: ApiPath.forgotPassword,
      requestBody: {'phone': phone},
      returnDataOnly: false,
    );
    return _messageResponse(res);
  }

  @override
  Future<PreLoginResponseModel> resetPassword({
    required String phone,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await apiService.post(
      url: ApiPath.resetPassword,
      requestBody: {
        'phone': phone,
        'otp_code': otpCode,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      returnDataOnly: false,
    );
    return _messageResponse(res);
  }

  @override
  Future<UserAuthResponseModel> selectRole(String role) async {
    final res = await apiService.post(
      url: ApiPath.selectRole,
      requestBody: {'role': role},
      returnDataOnly: false,
    );

    final responseData = res['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      throw Exception('Invalid response: missing data field');
    }

    final userData = responseData['user'] as Map<String, dynamic>?;
    if (userData == null) {
      throw Exception('Invalid response: missing user field');
    }

    final user = UserModel.fromJson(userData);
    await dataManager.setId(user.id);

    return UserAuthResponseModel(
      message: res['message'] as String? ?? 'Role selected successfully',
      token: null,
      user: user,
    );
  }
}
