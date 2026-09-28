import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../verify/presentation/manager/verify_provider.dart';
import '../../domain/repositories/forget_password_repo.dart';

final forgetPasswordProvider = StateNotifierProvider.family.autoDispose<
    ForgetPasswordNotifier,
    CustomNotifierState,
    ForgetPasswordRepo>((ref, ForgetPasswordRepo repo) {
  return ForgetPasswordNotifier(repo);
});

class ForgetPasswordNotifier extends StateNotifier<CustomNotifierState> {
  ForgetPasswordRepo repo;

  ForgetPasswordNotifier(this.repo)
      : super(NewPasswordState(code: repo.code, sendTo: repo.sendTo));

  Future<void> reset(String newPassword) async {
    state = LoadingState('reset');
    final result = await repo.resetPassword(password: newPassword);
    result.fold(
      (failure) => state = ErrorState(failure.message),
      (success) {
        state = CloseState('Password Changes Succesfully'.tr, true);
      },
    );
  }
}
