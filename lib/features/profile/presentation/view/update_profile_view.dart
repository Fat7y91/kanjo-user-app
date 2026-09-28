import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/profile/presentation/managers/profile_verification_actions_mixin.dart';
import 'package:heraj/features/profile/presentation/view/widgets/profile_pending_verification_view.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/error_widget.dart';

import '../manager/update_profile_provider.dart';
import 'edit_profile.dart';

class UpdateProfileView extends ConsumerStatefulWidget {
  const UpdateProfileView({super.key});

  @override
  ConsumerState<UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends ConsumerState<UpdateProfileView>
    with ProfileVerificationActionsMixin {
  bool _autoStarted = false;

  void _maybeStartVerification(PendingVerificationFailure failure) {
    if (_autoStarted) return;
    _autoStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      startPendingVerification(failure);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(refreshProfileProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) {
          if (err is PendingVerificationFailure) {
            _maybeStartVerification(err);
          }
        },
      );
    });
    final updatedUser = ref.watch(refreshProfileProvider);
    updatedUser.whenOrNull(
      error: (err, _) {
        if (err is PendingVerificationFailure) {
          _maybeStartVerification(err);
        }
      },
    );
    return Scaffold(
      body: updatedUser.customWhen(
        ref: ref,
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        refreshable: refreshProfileProvider.future,
        error: (err, trace) {
          if (err is PendingVerificationFailure) {
            return ProfilePendingVerificationView(
              message: err.message,
              pendingVerification: err.normalizedPending,
              onVerify: () => startPendingVerification(err),
            );
          }
          return CustomErrorWidget(
            object: err,
            stackTrace: trace,
            onRetry: () => ref.refresh(refreshProfileProvider.future),
          );
        },
        data: (data) => const EditProfileScreen(),
      ),
    );
  }
}
