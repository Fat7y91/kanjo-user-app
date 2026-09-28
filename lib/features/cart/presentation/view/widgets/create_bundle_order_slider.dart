import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class CreateBundleOrderSlider extends StatefulWidget {
  const CreateBundleOrderSlider({
    super.key,
    required this.onCompleted,
    this.isLoading = false,
  });

  final VoidCallback onCompleted;
  final bool isLoading;

  @override
  State<CreateBundleOrderSlider> createState() =>
      _CreateBundleOrderSliderState();
}

class _CreateBundleOrderSliderState extends State<CreateBundleOrderSlider> {
  static const double _thumbSize = 52;
  static const double _trackHeight = 56;

  late final ValueNotifier<double> _progress;

  @override
  void initState() {
    super.initState();
    _progress = ValueNotifier<double>(0);
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CreateBundleOrderSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _progress.value = 1;
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _reset();
    }
  }

  void _reset() {
    _progress.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxTravel = (constraints.maxWidth - _thumbSize - 8).clamp(1.0, 400.0);

        return ValueListenableBuilder<double>(
          valueListenable: _progress,
          builder: (context, progress, _) {
            return GestureDetector(
              onHorizontalDragUpdate: widget.isLoading
                  ? null
                  : (details) {
                      final delta =
                          isRtl ? -details.delta.dx : details.delta.dx;
                      _progress.value =
                          (_progress.value + delta / maxTravel).clamp(0, 1);
                    },
              onHorizontalDragEnd: widget.isLoading
                  ? null
                  : (_) {
                      if (_progress.value >= 0.85) {
                        _progress.value = 1;
                        widget.onCompleted();
                      } else {
                        _reset();
                      }
                    },
              onHorizontalDragCancel: widget.isLoading ? null : _reset,
              child: Container(
                height: _trackHeight,
                decoration: BoxDecoration(
                  color: AppColor.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Text(
                        'Swipe to create bundle order'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFont.font14W700Black.copyWith(
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 4 + (progress * maxTravel),
                        ),
                        child: Container(
                          width: _thumbSize,
                          height: _thumbSize,
                          decoration: BoxDecoration(
                            gradient: AppColor.defaultPrimaryGradient2,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: widget.isLoading
                              ? const LoadingWidget(
                                  size: 22,
                                  color: Colors.white,
                                )
                              : Icon(
                                  isRtl
                                      ? Icons.keyboard_arrow_left_rounded
                                      : Icons.keyboard_arrow_right_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
