import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/orders/domain/entities/order_entity.dart';

class OrderStatusStepper extends StatefulWidget {
  const OrderStatusStepper({
    super.key,
    required this.status,
    this.onGradient = false,
  });

  final OrderStatus status;
  final bool onGradient;

  @override
  State<OrderStatusStepper> createState() => _OrderStatusStepperState();
}

class _OrderStatusStepperState extends State<OrderStatusStepper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  late final Animation<double> _pulse;

  bool get _isFailed =>
      widget.status == OrderStatus.rejected ||
      widget.status == OrderStatus.cancelled ||
      widget.status == OrderStatus.refunded;

  int get _activeIndex => orderTrackingStepIndex(widget.status);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _pulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.12), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1, curve: Curves.easeInOut),
      ),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant OrderStatusStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = orderTrackingSteps;
    final activeIndex = _activeIndex;
    final activeColor = widget.onGradient
        ? (_isFailed ? const Color(0xFFFFAEAE) : Colors.white)
        : (_isFailed ? AppColor.danger : AppColor.primary);
    final idleColor = widget.onGradient
        ? Colors.white.withAlpha(64)
        : const Color(0xFFE0E0E0);
    final labelColor = widget.onGradient
        ? (_isFailed ? const Color(0xFFFFAEAE) : Colors.white)
        : activeColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0) const Gap(6),
                  Expanded(
                    child: Transform.scale(
                      scale: i == activeIndex ? _pulse.value : 1,
                      alignment: Alignment.center,
                      child: _StatusDash(
                        fill: _dashFill(
                          index: i,
                          activeIndex: activeIndex,
                          anim: _progress.value,
                        ),
                        color: activeColor,
                        idleColor: idleColor,
                        isCurrent: i == activeIndex,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Gap(12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                orderStatusLabel(widget.status),
                key: ValueKey(widget.status),
                textAlign: TextAlign.center,
                style: AppFont.font14W600Black.copyWith(
                  color: labelColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _dashFill({
    required int index,
    required int activeIndex,
    required double anim,
  }) {
    if (index < activeIndex) return 1;
    if (index > activeIndex) return 0;
    if (widget.status == OrderStatus.delivered) return 1;
    return (0.35 + (0.65 * anim)).clamp(0.0, 1.0);
  }
}

class _StatusDash extends StatelessWidget {
  const _StatusDash({
    required this.fill,
    required this.color,
    required this.idleColor,
    required this.isCurrent,
  });

  final double fill;
  final Color color;
  final Color idleColor;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5,
      child: Stack(
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: idleColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          FractionallySizedBox(
            widthFactor: fill.clamp(0.0, 1.0),
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
                boxShadow: isCurrent && fill > 0
                    ? [
                        BoxShadow(
                          color: color.withAlpha(70),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
