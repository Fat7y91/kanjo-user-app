import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '../../config/api_path.dart';
import '../../config/app_assets.dart';
import '../../config/app_color.dart';
import '../../helper/responsive.dart';
import 'back_icon.dart';
import 'shimmer_effect.dart';

class ImageOrSvg extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final bool magnifier;
  final bool isLocal;
  final bool isLoading;
  final bool isCircleLoading;
  final bool pickImageOnNull;
  final String? assetImageOnNull;
  final VoidCallback? onLoadCompleted;

  ImageOrSvg(
    this.url, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.magnifier = false,
    this.color,
    this.isLoading = false,
    this.isLocal = false,
    this.isCircleLoading = true,
    this.pickImageOnNull = false,
    this.assetImageOnNull,
    this.onLoadCompleted,
  }) : super(key: key ?? ValueKey(url));

  @override
  State<ImageOrSvg> createState() => _ImageOrSvgState();
}

class _ImageOrSvgState extends State<ImageOrSvg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _didNotifyLoad = false;

  /// Cache dimensions for decoding (reduces memory when displaying small).
  // (int?, int?) _cacheDimensions(BuildContext context) {
  //   if (widget.width == null ||
  //       widget.height == null ||
  //       widget.width! <= 0 ||
  //       widget.height! <= 0) {
  //     return (null, null);
  //   }
  //   final dpr = MediaQuery.devicePixelRatioOf(context);
  //   return (
  //     (widget.width! * dpr).round(),
  //     (widget.height! * dpr).round(),
  //   );
  // }

  Widget _shimmerPlaceholder() {
    return ShimmerEffect(
      enable: true,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          shape: widget.isCircleLoading ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    if (widget.isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColor.grey_3,
          shape: widget.isCircleLoading ? BoxShape.circle : BoxShape.rectangle,
        ),
        child: Center(child: _shimmerPlaceholder()),
      );
    }

    final url = widget.url?.trim();
    if (url == null || url.isEmpty) {
      return RepaintBoundary(
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape:
                widget.isCircleLoading ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: Center(
            child: widget.pickImageOnNull || widget.assetImageOnNull != null
                ? Image.asset(
                    widget.assetImageOnNull ?? AppAssets.profile,
                    width: widget.width != null ? widget.width! - 20 : null,
                    height: widget.height != null ? widget.height! - 20 : null,
                    color: widget.color,
                    fit: widget.fit,
                    gaplessPlayback: true,
                  )
                : _shimmerPlaceholder(),
          ),
        ),
      );
    }

    final fullPath = widget.isLocal
        ? url
        : url.startsWith('http')
            ? url
            : '${ApiPath.uploadPath}$url';

    if (fullPath.endsWith('.svg')) {
      final svg = widget.isLocal
          ? SvgPicture.asset(
              fullPath,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              color: widget.color,
            )
          : SvgPicture.network(
              fullPath,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              color: widget.color,
              placeholderBuilder: (_) => _shimmerPlaceholder(),
            );
      return RepaintBoundary(child: svg);
    }

    final image = widget.isLocal
        ? ExtendedImage.asset(
            fullPath,
            width: widget.width,
            height: widget.height,
            color: widget.color,
            fit: widget.fit,
            opacity: _controller,
            enableLoadState: true,
            loadStateChanged: _handleLoadStateChange,
          )
        : ExtendedImage.network(
            fullPath,
            width: widget.width,
            height: widget.height,
            color: widget.color,
            fit: widget.fit,
            cache: true,
            opacity: _controller,
            handleLoadingProgress: true,
            enableLoadState: true,
            cacheMaxAge: const Duration(days: 7),
            loadStateChanged: _handleLoadStateChange,
          );
    return RepaintBoundary(child: image);
  }

  Widget _handleLoadStateChange(ExtendedImageState ff) {
    switch (ff.extendedImageLoadState) {
      case LoadState.loading:
        _controller.reset();
        return RepaintBoundary(
          child: Center(child: _shimmerPlaceholder()),
        );
      case LoadState.failed:
        _controller.forward();
        return FadeTransition(
          opacity: _controller,
          child: InkWell(
            onTap: () => ff.reLoadImage(),
            child: const RepaintBoundary(
              child: Icon(Icons.error, color: Colors.red),
            ),
          ),
        );
      case LoadState.completed:
        _controller.forward();
        if (!_didNotifyLoad) {
          _didNotifyLoad = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onLoadCompleted?.call();
          });
        }
        return FadeTransition(
          opacity: _controller,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: !widget.magnifier
                  ? null
                  : () {
                      if (ff.extendedImageInfo != null) {
                        Get.to(() => _ImageMagnifier(
                              image: ff.extendedImageInfo!,
                            ));
                      }
                    },
              child: RepaintBoundary(
                child: ExtendedRawImage(
                  image: ff.extendedImageInfo?.image,
                  width: widget.width,
                  height: widget.height,
                  color: widget.color,
                  fit: widget.fit,
                ),
              ),
            ),
          ),
        );
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ImageMagnifier extends StatelessWidget {
  const _ImageMagnifier({required this.image});

  final ImageInfo image;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: const BackIcon(),
      body: PhotoView.customChild(
        child: ExtendedRawImage(
          image: image.image,
        ),
      ),
    );
  }
}
