import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

extension AdaptiveView on BuildContext {
  bool get isIOS => Platform.isIOS;

  bool get isAndroid => Platform.isAndroid;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  double get shortestSide => MediaQuery.of(this).size.shortestSide;

  /// Returns the longest side of the screen
  double get longestSide => MediaQuery.of(this).size.longestSide;

  /// Returns true if the device is in portrait orientation
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  /// Returns true if the device is in landscape orientation
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Returns true if the screen width is considered mobile (< 600)
  bool get isMobile => screenWidth < 600;

  /// Returns true if the screen width is considered tablet (600-1024)
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  /// Returns true if the screen width is considered desktop (>= 1024)
  bool get isDesktop => screenWidth >= 1024;

  /// Returns the safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Returns the safe area top padding
  double get safeAreaTop => MediaQuery.of(this).padding.top;

  /// Returns the safe area bottom padding
  double get safeAreaBottom => MediaQuery.of(this).padding.bottom;

  /// Returns the safe area left padding
  double get safeAreaLeft => MediaQuery.of(this).padding.left;

  /// Returns the safe area right padding
  double get safeAreaRight => MediaQuery.of(this).padding.right;

  /// Returns the view padding
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;

  /// Returns the view insets
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Returns the device pixel ratio
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  /// Returns the text scale factor
  double get textScaleFactor => MediaQuery.of(this).textScaleFactor;

  /// Returns true if the device has notch or safe area
  bool get hasNotch => safeAreaTop > 0 || safeAreaBottom > 0;

  /// Returns true if the keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Returns the keyboard height
  double get keyboardHeight => viewInsets.bottom;

  /// Builds a widget based on platform (iOS or Android)
  /// 
  /// Example:
  /// ```dart
  /// context.adaptiveWidget(
  ///   ios: CupertinoButton(...),
  ///   android: ElevatedButton(...),
  /// )
  /// ```
  Widget adaptiveWidget({
    required Widget ios,
    required Widget android,
  }) {
    return isIOS ? ios : android;
  }

  /// Builds a widget based on screen size (mobile, tablet, or desktop)
  /// 
  /// Example:
  /// ```dart
  /// context.adaptiveBySize(
  ///   mobile: MobileLayout(),
  ///   tablet: TabletLayout(),
  ///   desktop: DesktopLayout(),
  /// )
  /// ```
  Widget adaptiveBySize({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop && desktop != null) {
      return desktop;
    } else if (isTablet && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  Widget adaptiveByOrientation({
    required Widget portrait,
    required Widget landscape,
  }) {
    return isPortrait ? portrait : landscape;
  }

  T adaptiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) {
      return desktop;
    } else if (isTablet && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  T adaptiveByOrientationValue<T>({
    required T portrait,
    required T landscape,
  }) {
    return isPortrait ? portrait : landscape;
  }

  /// Returns a value based on platform
  /// 
  /// Example:
  /// ```dart
  /// final padding = context.adaptiveByPlatformValue(
  ///   ios: 20.0,
  ///   android: 16.0,
  /// );
  /// ```
  T adaptiveByPlatformValue<T>({
    required T ios,
    required T android,
  }) {
    return isIOS ? ios : android;
  }

  /// Wraps a widget with safe area padding
  /// 
  /// Example:
  /// ```dart
  /// context.safeArea(child: MyWidget())
  /// ```
  Widget safeArea({required Widget child}) {
    return SafeArea(child: child);
  }

  /// Wraps a widget with platform-specific safe area
  /// 
  /// Example:
  /// ```dart
  /// context.platformSafeArea(child: MyWidget())
  /// ```
  Widget platformSafeArea({required Widget child}) {
    if (isIOS) {
      return SafeArea(child: child);
    } else {
      return Padding(
        padding: EdgeInsets.only(
          top: safeAreaTop,
          bottom: safeAreaBottom,
        ),
        child: child,
      );
    }
  }

  /// Returns responsive padding based on screen size
  /// 
  /// Example:
  /// ```dart
  /// Padding(
  ///   padding: context.responsivePadding(),
  ///   child: MyWidget(),
  /// )
  /// ```
  EdgeInsets responsivePadding({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final defaultPadding = 16.0;
    final padding = adaptiveValue<double>(
      mobile: mobile ?? defaultPadding,
      tablet: tablet ?? (mobile ?? defaultPadding) * 1.5,
      desktop: desktop ?? (mobile ?? defaultPadding) * 2.0,
    );
    return EdgeInsets.all(padding);
  }

  /// Returns responsive horizontal padding
  EdgeInsets responsiveHorizontalPadding({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final defaultPadding = 16.0;
    final padding = adaptiveValue<double>(
      mobile: mobile ?? safeAreaLeft,
      tablet: tablet ?? (mobile ?? defaultPadding) * 1.5,
      desktop: desktop ?? (mobile ?? defaultPadding) * 2.0,
    );
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Returns responsive vertical padding
  EdgeInsets responsiveVerticalPadding({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final defaultPadding = 16.0;
    final padding = adaptiveValue<double>(
      mobile: mobile ?? defaultPadding,
      tablet: tablet ?? (mobile ?? defaultPadding) * 1.5,
      desktop: desktop ?? (mobile ?? defaultPadding) * 2.0,
    );
    return EdgeInsets.symmetric(vertical: padding);
  }

  /// Returns responsive font size based on screen size
  /// 
  /// Example:
  /// ```dart
  /// Text(
  ///   'Hello',
  ///   style: TextStyle(
  ///     fontSize: context.responsiveFontSize(),
  ///   ),
  /// )
  /// ```
  double responsiveFontSize({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final defaultSize = 14.0;
    return adaptiveValue<double>(
      mobile: mobile ?? defaultSize,
      tablet: tablet ?? (mobile ?? defaultSize) * 1.2,
      desktop: desktop ?? (mobile ?? defaultSize) * 1.5,
    );
  }

  /// Returns responsive spacing based on screen size
  /// 
  /// Example:
  /// ```dart
  /// Gap(context.responsiveSpacing())
  /// ```
  double responsiveSpacing({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    final defaultSpacing = 16.0;
    return adaptiveValue<double>(
      mobile: mobile ?? defaultSpacing,
      tablet: tablet ?? (mobile ?? defaultSpacing) * 1.5,
      desktop: desktop ?? (mobile ?? defaultSpacing) * 2.0,
    );
  }

  /// Returns the number of columns for a grid based on screen size
  /// 
  /// Example:
  /// ```dart
  /// GridView.builder(
  ///   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  ///     crossAxisCount: context.responsiveGridColumns(),
  ///   ),
  ///   ...
  /// )
  /// ```
  int responsiveGridColumns({
    int? mobile,
    int? tablet,
    int? desktop,
  }) {
    return adaptiveValue<int>(
      mobile: mobile ?? 2,
      tablet: tablet ?? 3,
      desktop: desktop ?? 4,
    );
  }

  /// Returns responsive max width for content
  /// 
  /// Example:
  /// ```dart
  /// Container(
  ///   constraints: BoxConstraints(
  ///     maxWidth: context.responsiveMaxWidth(),
  ///   ),
  ///   child: MyWidget(),
  /// )
  /// ```
  double responsiveMaxWidth({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return adaptiveValue<double>(
      mobile: mobile ?? screenWidth,
      tablet: tablet ?? 800.0,
      desktop: desktop ?? 1200.0,
    );
  }
}

