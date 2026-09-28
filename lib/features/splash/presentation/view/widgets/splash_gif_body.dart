import 'package:flutter/material.dart';
import 'package:heraj/features/splash/presentation/managers/splash_gif_cache.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class SplashGifBody extends StatelessWidget {
  const SplashGifBody({
    super.key,
    required this.gifUrl,
  });

  final String? gifUrl;

  @override
  Widget build(BuildContext context) {
    final cached = SplashGifCache.provider;
    final url = gifUrl?.trim();

    return cached != null
        ? Image(
            image: cached,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fitHeight,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
          )
        : url == null || url.isEmpty
            ? const PageLoadingWidget()
            : Image.network(
                url,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fitHeight,
                gaplessPlayback: true,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const PageLoadingWidget();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const PageLoadingWidget();
                },
              );
  }
}
