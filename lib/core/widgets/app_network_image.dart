import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  static const _maxCacheWidth = 1600;

  static int _cacheWidth(double logicalWidth, double dpr) {
    final physical = ((logicalWidth * dpr) / 50).ceil() * 50;
    return physical.clamp(50, _maxCacheWidth);
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    if (width != null) {
      return _image(context, _cacheWidth(width!, dpr));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? _cacheWidth(constraints.maxWidth, dpr)
            : null;
        return _image(context, w);
      },
    );
  }

  Widget _image(BuildContext context, int? cacheWidth) {
    final theme = Theme.of(context);
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      placeholder: (_, _) =>
          ColoredBox(color: theme.colorScheme.surfaceContainerHighest),
      errorWidget: (_, _, _) => ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}
