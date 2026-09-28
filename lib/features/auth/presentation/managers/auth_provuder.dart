import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/location_service/location_provider.dart';
import 'package:heraj/features/auth/presentation/view/widgets/location_request_bottom_sheet.dart';
import 'package:heraj/models/user_model.dart';
import '../../../../../core/service/auth_service.dart';
import '../../../../core/service/socket_service/conversation_realtime_service.dart';
import '../../../../../core/service/local_data_manager.dart';
import '../../../../../core/service/fcm_token_service.dart';
import '../../../../../main.dart';
import '../../../verify/domain/repositories/verification_repo.dart';
import '../../../verify/presentation/pages/verify_view.dart';
import '../../../root/view/root_view.dart';
import '../../domain/use_cases/login_user_use_case.dart';
import '../../domain/use_cases/register_user_use_case.dart';
import '../../domain/use_cases/select_role_use_case.dart';
import '../view/widgets/role_selection_bottom_sheet.dart';

final authNotifierProvider =
    StateNotifierProvider.autoDispose<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref);
});

final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier(this.ref) : super(false);
  Ref ref;

  Future<UserAuthResponseModel?> login(Map<String, dynamic> data) async {
    state = true;
    try {
      final fcm = await getIt<FCMTokenService>().ensureFcmToken();
      if (fcm != null && fcm.isNotEmpty) {
        data = {...data, 'fcm_token': fcm};
      }
      final res = await getIt<LoginUserUseCase>().call(data);
      return res.fold((l) {
        throw l;
      }, (r) {
        return r;
      });
    } finally {
      state = false;
    }
  }

  Future<UserAuthResponseModel?> register(Map<String, dynamic> data) async {
    state = true;
    try {
      final res = await getIt<RegisterUserUseCase>().call(data);
      return res.fold((l) {
        throw l;
      }, (r) {
        return r;
      });
    } finally {
      state = false;
    }
  }

  Future vendorRegister(Map<String, dynamic> data) async {
    state = true;
    try {
      final res = await getIt<VendorRegisterUserUseCase>().call(data);
      res.fold((l) {
        throw l;
      }, (r) {
        handleVendorUser(r, data);
      });
    } finally {
      state = false;
    }
  }

  Future<PreLoginResponseModel?> sendOtp(Map<String, dynamic> data) async {
    state = true;
    try {
      final res = await getIt<SendOtpUseCase>().call(data);
      return res.fold((l) {
        throw l;
      }, (r) {
        return r;
      });
    } finally {
      state = false;
    }
  }

  Future<PreLoginResponseModel?> preLogin(Map<String, dynamic> data) {
    return sendOtp(data);
  }

  Future verifyOtp(Map<String, dynamic> data) async {
    state = true;
    try {
      final res = await getIt<VerifyOtpUseCase>().call(data);
      res.fold((l) {
        throw l;
      }, (r) {
        handleUser(r, null, data);
      });
    } finally {
      state = false;
    }
  }

  Future<PreLoginResponseModel?> forgotPassword(String phone) async {
    state = true;
    try {
      final res = await getIt<ForgotPasswordUseCase>().call(phone);
      return res.fold((l) {
        throw l;
      }, (r) {
        return r;
      });
    } finally {
      state = false;
    }
  }

  Future<PreLoginResponseModel?> resetPassword(
      Map<String, dynamic> data) async {
    state = true;
    try {
      final res = await getIt<ResetPasswordUseCase>().call(data);
      return res.fold((l) {
        throw l;
      }, (r) {
        return r;
      });
    } finally {
      state = false;
    }
  }

  Future socialLogin(String data) async {
    state = true;
    try {
      final res = await getIt<SocialLoginUserUseCase>().call(data);
      await res.fold((l) {
        throw l;
      }, (r) async {
        if (r.needsRoleSelection) {
          final hasPreSelectedRole = dataManager.hasVendorFlowPreference();
          String? selectedRole;

          if (hasPreSelectedRole) {
            final isVendor = dataManager.getVendorFlow();
            selectedRole = isVendor ? 'vendor' : 'customer';
          } else {
            selectedRole = await showRoleSelectionBottomSheet();
          }

          if (selectedRole != null) {
            final selectRoleRes =
                await getIt<SelectRoleUseCase>().call(selectedRole);
            await selectRoleRes.fold((l) {
              throw l;
            }, (roleResponse) async {
              final updatedUser = UserAuthResponseModel(
                token: r.token,
                user: roleResponse.user,
                message: roleResponse.message,
                needsRoleSelection: false,
              );

              if (selectedRole == 'vendor') {
                await dataManager.setVendorFlow(true);
              } else {
                await dataManager.setVendorFlow(false);
              }

              await handleUser(updatedUser, null, {}, checkIsVerified: true);
            });
          } else {
            state = false;
            return;
          }
        } else {
          await handleUser(r, null, {}, checkIsVerified: true);
        }
      });
    } finally {
      state = false;
    }
  }

  Future<void> handleUser(UserAuthResponseModel? user,
      PreAuthResponseModel? preAuth, Map<String, dynamic> data,
      {bool checkIsVerified = false}) async {
    state = true;
    try {
      if (preAuth != null) {
        return Get.offAll(() => VerifyView(
                repo: getIt<VerificationRepo>(
              param1: data['email'],
            )));
      }
      if (user != null) {
        final locationDetails = await showLocationRequestBottomSheet();
        if (user.token != null && user.user != null) {
          await dataManager.setUser(user.user!);
          await dataManager.setToken(user.token!);
        }
        ref.read(userProvider.notifier).state = user.user;
        if (locationDetails != null) {
          Future.microtask(() {
            ref.invalidate(fetchLocationDetailsProvider);
          });
        }

        try {
          await getIt<FCMTokenService>().registerFCMToken();
        } catch (e) {
          print('Error registering FCM token: $e');
        }
        await getIt<ConversationRealtimeService>().connectIfPossible();

        return Get.offAll(() => const RootView());
      }
    } finally {
      state = false;
    }
  }

  Future<void> handleVendorUser(
      UserAuthResponseModel user, Map<String, dynamic> data) async {
    state = true;
    try {
      final locationDetails = await showLocationRequestBottomSheet();
      if (user.token != null && user.user != null) {
        await dataManager.setUser(user.user!);
        await dataManager.setToken(user.token!);
        await dataManager.setVendorFlow(true);
      }
      ref.read(userProvider.notifier).state = user.user;
      if (locationDetails != null) {
        Future.microtask(() {
          ref.invalidate(fetchLocationDetailsProvider);
        });
      }

      try {
        await getIt<FCMTokenService>().registerFCMToken();
      } catch (e) {
        print('Error registering FCM token: $e');
      }
      await getIt<ConversationRealtimeService>().connectIfPossible();

      return Get.offAll(() => const RootView());
    } finally {
      state = false;
    }
  }
}

final fingerprintControllerProvider = StateProvider.autoDispose<bool>((ref) {
  return dataManager.getFingerprintEnabled();
});
