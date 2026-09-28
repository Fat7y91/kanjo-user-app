import 'package:flutter/material.dart';

mixin ChatScrollToEndMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  static const _nearBottomThreshold = 140.0;

  ScrollController get chatScrollController;

  double _lastViewInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    final inset = View.of(context).viewInsets.bottom;
    if (inset > _lastViewInset + 20) {
      scrollChatToEnd(force: true);
    }
    _lastViewInset = inset;
  }

  void scrollChatToEnd({bool force = true}) {
    void go() {
      if (!mounted || !chatScrollController.hasClients) return;
      final position = chatScrollController.position;
      if (!position.hasContentDimensions) return;
      if (!force &&
          position.maxScrollExtent - position.pixels > _nearBottomThreshold) {
        return;
      }
      final target = position.maxScrollExtent;
      if ((position.pixels - target).abs() < 1) return;
      chatScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      go();
      WidgetsBinding.instance.addPostFrameCallback((_) => go());
    });
    Future<void>.delayed(const Duration(milliseconds: 400), go);
  }
}
