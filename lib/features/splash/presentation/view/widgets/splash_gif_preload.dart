import 'package:flutter/material.dart';
import 'package:heraj/features/splash/presentation/managers/splash_gif_cache.dart';

/// Invisible decoder used while the logo splash is visible.
class SplashGifPreload extends StatefulWidget {
  const SplashGifPreload({
    super.key,
    required this.gifUrl,
  });

  final String gifUrl;

  @override
  State<SplashGifPreload> createState() => _SplashGifPreloadState();
}

class _SplashGifPreloadState extends State<SplashGifPreload> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SplashGifCache.precache(context, widget.gifUrl);
    });
  }

  @override
  void didUpdateWidget(covariant SplashGifPreload oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gifUrl != widget.gifUrl) {
      SplashGifCache.precache(context, widget.gifUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = SplashGifCache.provider ?? NetworkImage(widget.gifUrl);
    return Positioned(
      left: 0,
      top: 0,
      width: 1,
      height: 1,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0,
          child: Image(
            image: image,
            gaplessPlayback: true,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
