import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../../data/repositories/forget_verify_repo_impl.dart';
import '../../domain/repositories/verification_repo.dart';

final verifyProvider = StateNotifierProvider.family
    .autoDispose<VerifyNotifier, CustomNotifierState, VerificationRepo>(
        (ref, VerificationRepo repo) {
  return VerifyNotifier(repo);
});

abstract class CustomNotifierState {}

class WritingOTPState extends CustomNotifierState {
  final String? message;

  WritingOTPState([this.message]);
}

class LoadingState extends CustomNotifierState {
  final String? key;

  LoadingState([this.key]);
}

class ErrorState extends CustomNotifierState {
  final String message;

  ErrorState(this.message);
}

class CloseState extends CustomNotifierState {
  final String? message;
  final bool? isSuccess;

  CloseState([this.message, this.isSuccess = true]);
}

class RegisterComplete extends CustomNotifierState {
  final String? message;
  final String? sendTo;
  final bool? isSuccess;

  RegisterComplete({
    this.message,
    this.isSuccess = true,
    this.sendTo
  });
}

class NewPasswordState extends CustomNotifierState {
  final String code;
  final String sendTo;

  NewPasswordState({required this.code, required this.sendTo});
}

class VerifyNotifier extends StateNotifier<CustomNotifierState> {
  final TextEditingController textController = TextEditingController();

  VerifyNotifier(this.verifyRepo) : super(LoadingState("all")) {
    // send();
  }

  final VerificationRepo verifyRepo;

  final StopWatchTimer stopWatch = StopWatchTimer(
    mode: StopWatchMode.countDown,
    presetMillisecond: const Duration(seconds: 60).inMilliseconds,
  );

  _resetTime() {
    stopWatch.onResetTimer();
    stopWatch.onStartTimer();
  }

  Future<void> send() async {
    final result = await verifyRepo.send();
    result.fold(
      (failure) => state = CloseState(failure.message, false),
      (success) {
        _resetTime();
        state = WritingOTPState();
      },
    );
  }

  Future<CustomNotifierState> verify(String code,{String? emailOrPhone}) async {
    state = LoadingState('verify');
    final result = await verifyRepo.verify(code,emailOrPhone: emailOrPhone);
    final CustomNotifierState res = result.fold(
      (failure) {
        state = ErrorState(failure.message);
        textController.clear();
        return state;
      },
      (success) {
        if (verifyRepo is CheckPhoneRepo) {
          state = RegisterComplete(sendTo: emailOrPhone);
        } else {
          state = CloseState('Verify Successfully', true);
        }
        return state;
      },
    );
    return res;
  }

  Future<void> resend() async {
    state = LoadingState('resend');
    // final result = await verifyRepo.resend();
    // result.fold(
    //   (failure) => state = ErrorState(failure.message),
    //   (success) {
    //     _resetTime();
    //     state = WritingOTPState("Resend Successfully");
    //   },
    // );
    _resetTime();
    state = WritingOTPState("Resend Successfully");
  }
}
