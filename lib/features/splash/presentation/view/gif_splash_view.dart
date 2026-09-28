import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/splash/presentation/managers/gif_splash_actions_mixin.dart';
import 'package:heraj/features/splash/presentation/managers/splash_navigation_mixin.dart';
import 'package:heraj/features/splash/presentation/view/widgets/splash_gif_body.dart';
import 'package:heraj/ui/shared_widgets/loading_widget.dart';

class GifSplashView extends ConsumerStatefulWidget {
  const GifSplashView({
    super.key,
    required this.gifUrl,
  });

  final String gifUrl;

  @override
  ConsumerState<GifSplashView> createState() => _GifSplashViewState();
}

class _GifSplashViewState extends ConsumerState<GifSplashView>
    with SplashNavigationMixin, GifSplashActionsMixin {
  final ValueNotifier<bool> isResolvingAuth = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      runGifSplashFlow();
    });
  }

  @override
  void dispose() {
    isResolvingAuth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: SplashGifBody(gifUrl: widget.gifUrl)),
        ValueListenableBuilder<bool>(
          valueListenable: isResolvingAuth,
          builder: (context, resolving, _) {
            if (!resolving) return const SizedBox.shrink();
            return ColoredBox(
              color: Colors.white.withAlpha(102),
              child: const PageLoadingWidget(),
            );
          },
        ),
      ],
    );
  }
}
