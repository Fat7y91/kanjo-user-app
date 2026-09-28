import 'dart:ui';

import 'package:flutter/material.dart';

import '../../config/app_color.dart';
import '../../config/app_font.dart';
import 'loading_widget.dart';

/// Liquid-glass pill button inspired by iOS 26 design language.
///
/// Layers (back-to-front):
///  1. Outer ambient glow (soft halo around the pill).
///  2. BackdropFilter blur — picks up colours from whatever is behind it.
///  3. Tinted gradient body (uses [color] / [gradient]).
///  4. Inner radial sheen + top specular highlight (the "wet" glass shine).
///  5. Bright top-edge stroke + subtle bottom-edge stroke (rim light).
///  6. Foreground content (label / loader / custom child).
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.height = 64,
    this.width,
    this.radius = 999,
    this.color,
    this.gradient,
    this.textColor,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.blurSigma = 18,
  });

  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final double height;
  final double? width;
  final double radius;

  /// Base tint of the glass. If null, uses [AppColor.primary].
  final Color? color;

  /// Optional custom gradient. Overrides [color] for the body fill.
  final Gradient? gradient;

  final Color? textColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final Color tint = color ?? AppColor.primary;
    final bool isDisabled = onPressed == null || isLoading;

    final Gradient bodyGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(tint, Colors.white, 0.18)!.withOpacity(0.92),
            tint.withOpacity(0.95),
            Color.lerp(tint, Colors.black, 0.25)!.withOpacity(0.95),
          ],
          stops: const [0.0, 0.55, 1.0],
        );

    final BorderRadius br = BorderRadius.circular(radius);

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: text,
      child: Opacity(
        opacity: isDisabled && !isLoading ? 0.6 : 1,
        child: SizedBox(
          width: isExpanded ? double.infinity : width,
          height: height,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : onPressed,
              borderRadius: br,
              splashColor: Colors.white.withOpacity(0.10),
              highlightColor: Colors.white.withOpacity(0.06),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: br,
                  boxShadow: [
                    BoxShadow(
                      color: tint.withOpacity(0.45),
                      blurRadius: 28,
                      spreadRadius: 1,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: br,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurSigma,
                      sigmaY: blurSigma,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: bodyGradient,
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: const Alignment(0, -1.4),
                                  radius: 1.4,
                                  colors: [
                                    Colors.white.withOpacity(0.35),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                  stops: const [0.0, 0.7],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          top: 4,
                          height: height * 0.42,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(radius),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.32),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: br,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.55),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: padding,
                          child: Center(
                            child: _buildContent(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return LoadingWidget(color: textColor ?? Colors.white);
    }
    if (child != null) return child!;

    final TextStyle base = textStyle ??
        AppFont.font20W700White.copyWith(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: 0.2,
        );

    return Text(
      text ?? '',
      textAlign: TextAlign.center,
      style: base,
      overflow: TextOverflow.ellipsis,
    );
  }
}
