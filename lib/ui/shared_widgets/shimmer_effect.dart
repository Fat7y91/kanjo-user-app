import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../helper/responsive.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key, required this.child, required this.enable});

  final Widget child;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    if (!enable) return child;
    return Shimmer(
      gradient: LinearGradient(
        colors: [
          Colors.grey[300]!,
          Colors.grey[100]!,
          Colors.grey[300]!,
        ],
        stops: const [
          0.4,
          0.5,
          0.6,
        ],
      ),
      child: child,
    );
  }
}
