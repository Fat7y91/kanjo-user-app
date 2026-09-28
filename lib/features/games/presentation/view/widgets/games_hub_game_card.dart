import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';

class GamesHubGameCard extends StatefulWidget {
  const GamesHubGameCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.asset,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? asset;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<GamesHubGameCard> createState() => _GamesHubGameCardState();
}

class _GamesHubGameCardState extends State<GamesHubGameCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.enabled) {
      _loop.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant GamesHubGameCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_loop.isAnimating) {
      _loop.repeat();
    } else if (!widget.enabled && _loop.isAnimating) {
      _loop.stop();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          splashFactory: InkRipple.splashFactory,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _loop,
                  builder: (context, child) {
                    final bob = math.sin(_loop.value * math.pi * 2) * 3;
                    return Transform.translate(
                      offset: Offset(0, bob),
                      child: child,
                    );
                  },
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: AppColor.primaryDark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: widget.asset != null
                        ? ImageOrSvg(
                            widget.asset,
                            isLocal: true,
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            widget.icon ?? Icons.sports_esports_rounded,
                            size: 26,
                            color: AppColor.primary,
                          ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: AppFont.font14W700Black),
                      const Gap(4),
                      Text(widget.subtitle, style: AppFont.font12w500Grey2),
                    ],
                  ),
                ),
                Icon(
                  widget.enabled
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.lock_outline_rounded,
                  size: 18,
                  color: AppColor.grey2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
