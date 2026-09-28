import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../helper/responsive.dart';

class FlutterCloseAppPage extends StatefulWidget {
  const FlutterCloseAppPage({
    super.key,
    required this.child,
    this.interval = 2,
    this.condition = true,
    this.onCloseFailed,
  });

  /// The widget to wrap.
  final Widget child;

  /// The interval in seconds to close the app.
  final int interval;

  /// The custom condition to close the app.
  final bool condition;

  /// The callback when the condition is failed.
  final VoidCallback? onCloseFailed;

  @override
  State<FlutterCloseAppPage> createState() => _FlutterCloseAppPageState();
}

class _FlutterCloseAppPageState extends State<FlutterCloseAppPage> {
  int lastTime = 0;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return PopScope(
      canPop: kIsWeb ? true : !Platform.isAndroid,
      onPopInvoked: (_) {
        if (!Platform.isAndroid) {
          return;
        }
        int diff = DateTime.now().second - lastTime;
        if (widget.condition && diff >= 0 && diff <= widget.interval) {
          exit(0);
        } else {
          if (widget.condition) lastTime = DateTime.now().second;
          widget.onCloseFailed?.call();
        }
      },
      child: widget.child,
    );
  }
}
