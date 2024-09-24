import 'dart:async';

import 'package:card_effect_widget/enums/image_source_type.dart';
import 'package:card_effect_widget/models/configuration.dart';
import 'package:card_effect_widget/overlay_mixin.dart';
import 'package:card_effect_widget/widgets/motion_animate_widget.dart';
import 'package:flutter/material.dart';

import 'filter_widget.dart';
import 'mask_widget.dart';

typedef TouchCallback = void Function(bool isTouch);

class CardHolographicWidget extends StatefulWidget {
  final String image;
  final double maxHeight;
  final double aspectRatio;
  final TouchCallback touchCallback;
  final GlareConfiguration? glare;
  final FilterConfiguration? filter;
  final MaskConfiguration? mask;
  final ImageSourceType sourceType;
  // final ShimmerConfiguration? shimmer;

  const CardHolographicWidget._({
    required this.image,
    required this.touchCallback,
    this.sourceType = ImageSourceType.asset,
    this.maxHeight = 360,
    this.aspectRatio = 734 / 1024,
    this.glare,
    this.filter,
    this.mask,
  });

  const CardHolographicWidget.asset({
    super.key,
    required this.image,
    required this.touchCallback,
    this.sourceType = ImageSourceType.asset,
    this.maxHeight = 360,
    this.aspectRatio = 734 / 1024,
    this.glare,
    this.filter,
    this.mask,
  });

  factory CardHolographicWidget.network({
    required String image,
    required TouchCallback touchCallback,
    double maxHeight = 360,
    double aspectRatio = 734 / 1024,
    GlareConfiguration? glare,
    FilterConfiguration? filter,
    MaskConfiguration? mask,
    ShimmerConfiguration? shimmer,
  }) => CardHolographicWidget._(
    image: image,
    touchCallback: touchCallback,
    maxHeight: maxHeight,
    aspectRatio: aspectRatio,
    glare: glare,
    filter: filter,
    mask: mask,
    sourceType: ImageSourceType.network,
  );

  @override
  State createState() => _CardHolographicWidgetState();
}

class _CardHolographicWidgetState extends State<CardHolographicWidget>
    with SingleTickerProviderStateMixin, OverlayMixin {
  double _lightX = 0;
  double _lightY = 0;

  final _isOnHover = StreamController<bool>.broadcast()..add(false);
  Stream<bool> get isOnHover => _isOnHover.stream;

  Size size = Size.zero;

  final _overlayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initializeOverlay(this);
  }

  @override
  void dispose() {
    _isOnHover.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = StreamBuilder<bool>(
      stream: isOnHover,
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.data == null) return const SizedBox.shrink();
        return MotionAnimateWidget(
          maxHeight: widget.maxHeight,
          aspectRatio: widget.aspectRatio,
          sizeCallback: (size) {
            if (size != Size.zero) {
              this.size = size;
              setWidgetSize(size);
              setState(() {});
            }
          },
          touchCallback: (value) {
            widget.touchCallback.call(value);
            _isOnHover.add(value);
          },
          offsetCallback: (double x, double y) {
            _lightX = x;
            _lightY = y;
            setState(() {});
          },
          child: _CardImageWidget(
            image: widget.image,
            sourceType: widget.sourceType,
            lightPoints: (_lightX, _lightY),
            isOnHover: snapshot.data!,
            size: size,
            glare: widget.glare,
            filter: widget.filter,
            mask: widget.mask,
          ),
        );
      }
    );
    return !isOverlay ? GestureDetector(
      key: _overlayKey,
      onTap: () => showOverlay(context, _overlayKey.currentContext, child),
      child: child,
    ) : SizedBox(width: size.width, height: size.height,);
  }
}

class _CardImageWidget extends StatefulWidget {
  final String image;
  final bool isOnHover;
  final Size size;
  final (double, double) lightPoints;
  final GlareConfiguration? glare;
  final FilterConfiguration? filter;
  final MaskConfiguration? mask;
  final ImageSourceType sourceType;

  const _CardImageWidget({
    required this.image,
    required this.sourceType,
    required this.lightPoints,
    required this.isOnHover,
    required this.size,
    this.glare,
    this.filter,
    this.mask,
  });

  @override
  State<_CardImageWidget> createState() => _CardImageWidgetState();
}

class _CardImageWidgetState extends State<_CardImageWidget> {
  @override
  Widget build(BuildContext context) {
    Widget child = switch (widget.sourceType) {
      ImageSourceType.asset => Image.asset(
        widget.image,
        fit: BoxFit.cover,
      ),
      ImageSourceType.network => Image.network(
        widget.image,
        fit: BoxFit.cover,
      ),
    };
    if (widget.mask != null) {
      child = MaskWidget(
          isOnHover: widget.isOnHover,
          image: widget.mask!.maskImg,
          width: widget.size.width,
          height: widget.size.height,
          mode: widget.mask!.blendMode,
          child: child
      );
    }
    if (widget.filter != null) {
      child = FilterWidget(
          filters: widget.filter!.filters,
          isOnHover: widget.isOnHover,
          child: child
      );
    }
    if (widget.glare != null) {
      child = ShaderMask(
          shaderCallback: (rect) {
            return RadialGradient(
              center: Alignment(
                (widget.lightPoints.$1 / rect.width) * 2 - 1,
                (widget.lightPoints.$2 / rect.height) * 2 - 1
              ),
              radius: widget.glare!.radius,
              tileMode: widget.glare!.tileMode,
              colors: widget.glare!.colors,
              stops: widget.glare!.stops,
            ).createShader(rect);
          },
          blendMode: widget.glare!.blendMode,
          child: child
      );
    }
    return child;
  }
}
