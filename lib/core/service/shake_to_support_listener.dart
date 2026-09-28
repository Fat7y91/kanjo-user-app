import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/support_tickets/presentation/view/widgets/create_support_ticket_bottom_sheet.dart';
import 'package:shake/shake.dart';

class ShakeToSupportListener extends ConsumerStatefulWidget {
  const ShakeToSupportListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<ShakeToSupportListener> createState() =>
      _ShakeToSupportListenerState();
}

class _ShakeToSupportListenerState extends ConsumerState<ShakeToSupportListener> {
  ShakeDetector? _detector;
  bool _sheetOpen = false;
  DateTime? _lastShakeAt;

  static const _shakeCooldown = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncDetector());
  }

  @override
  void dispose() {
    _stopDetector();
    super.dispose();
  }

  bool get _hasToken => dataManager.getToken() != null;

  void _syncDetector() {
    if (!mounted) return;
    if (kIsWeb) {
      _stopDetector();
      return;
    }
    if (_hasToken) {
      _startDetector();
    } else {
      _stopDetector();
    }
  }

  void _startDetector() {
    if (_detector != null) return;
    _detector = ShakeDetector.autoStart(
      onPhoneShake: _onPhoneShake,
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
    );
  }

  void _stopDetector() {
    _detector?.stopListening();
    _detector = null;
  }

  void _onPhoneShake(ShakeEvent event) {
    if (!_hasToken || _sheetOpen) return;

    final now = DateTime.now();
    if (_lastShakeAt != null &&
        now.difference(_lastShakeAt!) < _shakeCooldown) {
      return;
    }
    _lastShakeAt = now;

    final context = Get.key.currentContext ?? Get.context;
    if (context == null || !context.mounted) return;

    _sheetOpen = true;
    unawaited(_openSupportSheet(context));
  }

  Future<void> _openSupportSheet(BuildContext context) async {
    try {
      await showCreateSupportTicketBottomSheet(context);
    } finally {
      _sheetOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProvider, (_, __) => _syncDetector());
    return widget.child;
  }
}
