import 'package:liquid_glass_renderer/experimental.dart';
import 'package:universal_io/io.dart';
import 'dart:math';
import 'package:liquid_circle_floating_nav_bar/liquid_curved_bar_item.dart';
import 'package:liquid_circle_floating_nav_bar/src/nav_bar_item_widget.dart';
import 'package:liquid_circle_floating_nav_bar/src/nav_custom_clipper.dart';
import 'package:flutter/material.dart';
import 'src/nav_custom_painter.dart';

typedef _LetIndexPage = bool Function(int value);

enum LiquidCircleFloatingNavBarType {
  bouncing,
  inline,
}

class LiquidCircleFloatingNavBar extends StatefulWidget {
  /// Defines the appearance of the [LiquidCurvedBarItem] list that are
  /// arrayed within the bottom navigation bar.
  final List<LiquidCurvedBarItem> items;

  /// The index into [items] for the current active [LiquidCurvedBarItem].
  final int index;

  /// This is the outerPadding for [LiquidCurvedBarItem].
  final double outerPadding;

  /// This is the enable for the glass effect for [LiquidCurvedBarItem].
  /// This is Experimental not for usage yet.
  final bool enableGlass;

  /// This is the circular radius for [LiquidCurvedBarItem].
  final double? radius;

  /// Navigation bar layout style.
  ///
  /// - [LiquidCircleFloatingNavBarType.bouncing] keeps the existing behavior.
  /// - [LiquidCircleFloatingNavBarType.inline] renders selected item as a pill
  ///   with label + icon (like inline tab).
  final LiquidCircleFloatingNavBarType type;

  /// The color of the [LiquidCircleFloatingNavBar] itself, default Colors.white.
  final Color color;

  /// Inline mode selection pill base color (defaults to white).
  ///
  /// This controls the "pill" behind the selected icon/label in
  /// [LiquidCircleFloatingNavBarType.inline].
  final Color inlineIndicatorColor;

  /// The background color of floating button, default same as [color] attribute.
  final Color? buttonBackgroundColor;

  /// The color of [LiquidCircleFloatingNavBar]'s background, default Colors.blueAccent.
  final Color backgroundColor;

  /// Optional gradient for the nav bar background.
  ///
  /// When provided, it overrides [backgroundColor] for the bar background in both
  /// [LiquidCircleFloatingNavBarType.bouncing] and [LiquidCircleFloatingNavBarType.inline].
  final Gradient? backgroundGradient;

  /// Called when one of the [items] is tapped.
  final ValueChanged<int>? onTap;

  /// Function which takes page index as argument and returns bool. If function
  /// returns false then page is not changed on button tap. It returns true by
  /// default.
  final _LetIndexPage letIndexChange;

  /// Curves interpolating button change animation, default Curves.easeOut.
  final Curve animationCurve;

  /// Duration of button change animation, default Duration(milliseconds: 600).
  final Duration animationDuration;

  /// Height of [LiquidCircleFloatingNavBar].
  final double height;

  /// Max width of [LiquidCircleFloatingNavBar].
  final double? maxWidth;

  /// Padding of icon in floating button.
  final double iconPadding;

  /// Check if [LiquidCircleFloatingNavBar] has label.
  final bool hasLabel;

  LiquidCircleFloatingNavBar({
    Key? key,
    required this.items,
    this.index = 0,
    this.outerPadding = 0,
    this.enableGlass = false,
    this.radius,
    this.type = LiquidCircleFloatingNavBarType.bouncing,
    this.color = Colors.white,
    this.inlineIndicatorColor = Colors.white,
    this.buttonBackgroundColor,
    this.backgroundColor = Colors.blueAccent,
    this.backgroundGradient,
    this.onTap,
    _LetIndexPage? letIndexChange,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.iconPadding = 12.0,
    this.maxWidth,
    double? height,
  })  : letIndexChange = letIndexChange ?? ((_) => true),
        assert(items.isNotEmpty),
        assert(0 <= index && index < items.length),
        assert(maxWidth == null || 0 <= maxWidth),
        height = height ?? (Platform.isAndroid ? 70.0 : 80.0),
        hasLabel = items.any((item) => item.label != null),
        super(key: key);

  @override
  LiquidCircleFloatingNavBarState createState() =>
      LiquidCircleFloatingNavBarState();
}

class LiquidCircleFloatingNavBarState extends State<LiquidCircleFloatingNavBar>
    with SingleTickerProviderStateMixin {
  late double _startingPos;
  late int _endingIndex;
  late double _pos;
  late Widget _icon;
  late AnimationController _animationController;
  late int _length;
  double _buttonHide = 0;

  @override
  void initState() {
    super.initState();
    _icon = widget.items[widget.index].child;
    _length = widget.items.length;
    _pos = widget.index / _length;
    _startingPos = widget.index / _length;
    _endingIndex = widget.index;
    _animationController = AnimationController(vsync: this, value: _pos);
    _animationController.addListener(() {
      setState(() {
        _pos = _animationController.value;
        final endingPos = _endingIndex / widget.items.length;
        final middle = (endingPos + _startingPos) / 2;
        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icon = widget.items[_endingIndex].child;
        }
        _buttonHide =
            (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(LiquidCircleFloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;
      _animationController.animateTo(
        newPosition,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }
    if (!_animationController.isAnimating) {
      _icon = widget.items[_endingIndex].child;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);

    if (widget.type == LiquidCircleFloatingNavBarType.inline) {
      return SizedBox(
        height: widget.height,
        child: Padding(
          padding: EdgeInsets.only(
            left: widget.outerPadding,
            right: widget.outerPadding,
            bottom: widget.outerPadding,
          ),
          child: _InlineNavBar(
            items: widget.items,
            selectedIndex: _endingIndex,
            backgroundColor: widget.backgroundColor,
            backgroundGradient: widget.backgroundGradient,
            indicatorColor: widget.inlineIndicatorColor,
            enableGlass: widget.enableGlass,
            radius: widget.radius ?? widget.height / 2,
            animationCurve: widget.animationCurve,
            animationDuration: widget.animationDuration,
            onTap: _buttonTap,
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = min(constraints.maxWidth, widget.maxWidth ?? constraints.maxWidth);
          return Align(
            alignment: textDirection == TextDirection.ltr
                ? Alignment.bottomLeft
                : Alignment.bottomRight,
            child: SizedBox(
              width: maxWidth,
              child: ClipRect(
                clipper: NavCustomClipper(
                  deviceHeight: MediaQuery.sizeOf(context).height,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Positioned(
                      bottom: widget.height - 105.0,
                      left: textDirection == TextDirection.rtl
                          ? null
                          : _pos * maxWidth,
                      right: textDirection == TextDirection.rtl
                          ? _pos * maxWidth
                          : null,
                      width: maxWidth / _length,
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0, (_buttonHide - 1) * 80),
                          child: Material(
                            color: widget.buttonBackgroundColor ?? widget.color,
                            type: MaterialType.circle,
                            child: Padding(
                              padding: EdgeInsets.all(widget.iconPadding),
                              child: _icon,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Background
                    if (widget.enableGlass)
                      Positioned(
                        left: widget.outerPadding,
                        right: widget.outerPadding,
                        bottom: widget.outerPadding,
                        child: Glassify(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                widget.radius ?? widget.height / 2),
                            child: CustomPaint(
                              painter: NavCustomPainter(
                                startingLoc: _pos,
                                itemsLength: _length,
                                color: widget.color,
                                // gradient: widget.backgroundGradient,
                                textDirection: Directionality.of(context),
                                hasLabel: widget.hasLabel,
                              ),
                              child: Container(
                                height: widget.height,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      widget.radius ?? widget.height / 2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Background
                    Positioned(
                      left: widget.outerPadding,
                      right: widget.outerPadding,
                      bottom: widget.outerPadding,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            widget.radius ?? widget.height / 2),
                        child: CustomPaint(
                          painter: NavCustomPainter(
                            startingLoc: _pos,
                            itemsLength: _length,
                            color: widget.enableGlass
                                ? widget.color.withAlpha(200)
                                : widget.color,
                            // gradient: widget.enableGlass
                            //     ? _withAlpha(widget.backgroundGradient, 200)
                            //     : widget.backgroundGradient,
                            textDirection: Directionality.of(context),
                            hasLabel: widget.hasLabel,
                          ),
                          child: Container(
                            height: widget.height,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  widget.radius ?? widget.height / 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Unselected buttons
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SizedBox(
                        height: widget.height,
                        child: Row(
                          children: widget.items.map((item) {
                            return NavBarItemWidget(
                              onTap: _buttonTap,
                              position: _pos,
                              length: _length,
                              index: widget.items.indexOf(item),
                              label: item.label,
                              labelStyle: item.labelStyle,
                              child: Center(child: item.child),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void setPage(int index) {
    _buttonTap(index);
  }

  void _buttonTap(int index) {
    if (!widget.letIndexChange(index) || _animationController.isAnimating) {
      return;
    }
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
    final newPosition = index / _length;
    setState(() {
      _startingPos = _pos;
      _endingIndex = index;
      if (widget.type == LiquidCircleFloatingNavBarType.bouncing) {
        _animationController.animateTo(
          newPosition,
          duration: widget.animationDuration,
          curve: widget.animationCurve,
        );
      } else {
        _pos = newPosition;
      }
    });
  }
}

Gradient? _withAlpha(Gradient? gradient, int alpha) {
  final g = gradient;
  if (g == null) return null;

  switch (g.runtimeType) {
    case LinearGradient:
      final lg = g as LinearGradient;
      return LinearGradient(
        begin: lg.begin,
        end: lg.end,
        stops: lg.stops,
        tileMode: lg.tileMode,
        transform: lg.transform,
        colors: lg.colors.map((c) => c.withAlpha(alpha)).toList(growable: false),
      );
    case RadialGradient:
      final rg = g as RadialGradient;
      return RadialGradient(
        center: rg.center,
        radius: rg.radius,
        focal: rg.focal,
        focalRadius: rg.focalRadius,
        stops: rg.stops,
        tileMode: rg.tileMode,
        transform: rg.transform,
        colors: rg.colors.map((c) => c.withAlpha(alpha)).toList(growable: false),
      );
    case SweepGradient:
      final sg = g as SweepGradient;
      return SweepGradient(
        center: sg.center,
        startAngle: sg.startAngle,
        endAngle: sg.endAngle,
        stops: sg.stops,
        tileMode: sg.tileMode,
        transform: sg.transform,
        colors: sg.colors.map((c) => c.withAlpha(alpha)).toList(growable: false),
      );
    default:
      return g;
  }
}

class _InlineNavBar extends StatefulWidget {
  const _InlineNavBar({
    required this.items,
    required this.selectedIndex,
    required this.backgroundColor,
    required this.backgroundGradient,
    required this.indicatorColor,
    required this.enableGlass,
    required this.radius,
    required this.animationCurve,
    required this.animationDuration,
    required this.onTap,
  });

  final List<LiquidCurvedBarItem> items;
  final int selectedIndex;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final Color indicatorColor;
  final bool enableGlass;
  final double radius;
  final Curve animationCurve;
  final Duration animationDuration;
  final ValueChanged<int> onTap;

  @override
  State<_InlineNavBar> createState() => _InlineNavBarState();
}

class _InlineNavBarState extends State<_InlineNavBar> {
  final GlobalKey _activeContentKey = GlobalKey();
  Size? _activeContentSize;

  @override
  void didUpdateWidget(covariant _InlineNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureActive());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureActive());
  }

  void _measureActive() {
    final ctx = _activeContentKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox) return;
    final newSize = box.size;
    if (newSize.width <= 0 || newSize.height <= 0) return;

    final old = _activeContentSize;
    final changed = old == null ||
        (newSize.width - old.width).abs() > 0.5 ||
        (newSize.height - old.height).abs() > 0.5;
    if (changed) {
      setState(() => _activeContentSize = newSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const barInnerHorizontalPadding = 8.0; // padding inside the bar (start/end)

        final itemCount = widget.items.length;
        final availableWidth =
            max(0.0, constraints.maxWidth - (barInnerHorizontalPadding * 2));
        final itemWidth = availableWidth / itemCount;

        const pillPadding = 8.0; // 8 for each side (left/right/top/bottom)

        final measured = _activeContentSize;
        final fallbackWidth = itemWidth * 0.72;
        final fallbackHeight = constraints.maxHeight * 0.62;

        final desiredIndicatorWidth = (measured?.width ?? fallbackWidth) + (pillPadding * 2);
        final desiredIndicatorHeight =
            (measured?.height ?? fallbackHeight) + (pillPadding * 2);

        final indicatorWidth =
            desiredIndicatorWidth.clamp(0.0, availableWidth);
        final indicatorHeight =
            desiredIndicatorHeight.clamp(0.0, constraints.maxHeight);

        final centerXLtr = (widget.selectedIndex + 0.5) * itemWidth;
        final centerXRtl = (itemCount - 1 - widget.selectedIndex + 0.5) * itemWidth;
        final centerX =
            textDirection == TextDirection.rtl ? centerXRtl : centerXLtr;

        final minLeft = barInnerHorizontalPadding;
        final maxLeft =
            constraints.maxWidth - barInnerHorizontalPadding - indicatorWidth;
        final indicatorLeft = (barInnerHorizontalPadding + (centerX - indicatorWidth / 2))
            .clamp(minLeft, maxLeft);

        final indicatorTop = ((constraints.maxHeight - indicatorHeight) / 2)
            .clamp(0.0, constraints.maxHeight - indicatorHeight);

        final indicator = ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.indicatorColor.withAlpha(210),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFFFFF).withAlpha(45),
                  const Color(0xFFFFFFFF).withAlpha(10),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withAlpha(130),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withAlpha(30),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
              borderRadius: BorderRadius.circular(999),
            ),
            child: const SizedBox.expand(),
          ),
        );

        final indicatorWithGlass =
            widget.enableGlass ? Glassify(child: indicator) : indicator;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: widget.backgroundGradient == null ? widget.backgroundColor : null,
            gradient: widget.backgroundGradient,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  left: indicatorLeft,
                top: indicatorTop,
                  width: indicatorWidth,
                  height: indicatorHeight,
                  child: indicatorWithGlass,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: barInnerHorizontalPadding,
                  ),
                  child: Row(
                    children: List.generate(itemCount, (i) {
                      final item = widget.items[i];
                      final isSelected = i == widget.selectedIndex;
                      return Expanded(
                        child: _InlineNavBarItem(
                          isSelected: isSelected,
                          measureKey: isSelected ? _activeContentKey : null,
                          label: item.label,
                          labelStyle: item.labelStyle,
                          animationCurve: widget.animationCurve,
                          animationDuration: widget.animationDuration,
                          onTap: () => widget.onTap(i),
                          child: item.child,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InlineNavBarItem extends StatelessWidget {
  const _InlineNavBarItem({
    required this.isSelected,
    this.measureKey,
    required this.animationCurve,
    required this.animationDuration,
    required this.onTap,
    required this.child,
    this.label,
    this.labelStyle,
  });

  final bool isSelected;
  final Key? measureKey;
  final String? label;
  final TextStyle? labelStyle;
  final Curve animationCurve;
  final Duration animationDuration;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final effectiveLabelStyle = labelStyle ??
        Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            );

    final hasLabel = label != null && label!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Center(
          child: OverflowBox(
            alignment: Alignment.center,
            minWidth: 100,
            maxWidth: double.infinity,
            child: Row(
              key: measureKey,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                child,
                if (hasLabel) ...[
                  AnimatedSize(
                    duration: animationDuration,
                    curve: animationCurve,
                    alignment: Alignment.centerLeft,
                    child: AnimatedSwitcher(
                      duration: animationDuration,
                      switchInCurve: animationCurve,
                      switchOutCurve: animationCurve,
                      transitionBuilder: (child, animation) {
                        final fade = CurvedAnimation(
                          parent: animation,
                          curve: animationCurve,
                        );
                        return FadeTransition(
                          opacity: fade,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.96, end: 1.0)
                                .animate(fade),
                            child: child,
                          ),
                        );
                      },
                      child: isSelected
                          ? Padding(
                              key: const ValueKey('inline_label'),
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                label!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: effectiveLabelStyle,
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('inline_label_hidden'),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
