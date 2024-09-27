import 'dart:async';
import 'dart:math';

import 'package:card_effect_widget/enums/image_source_type.dart';
import 'package:card_effect_widget/models/configuration.dart';
import 'package:card_effect_widget/overlay_mixin.dart';
import 'package:card_effect_widget/widgets/glow_animate_widget.dart';
import 'package:card_effect_widget/widgets/motion_animate_widget.dart';
import 'package:flutter/material.dart';

import 'filter_widget.dart';
import 'mask_widget.dart';

typedef TouchCallback = void Function(bool isTouch);

class CardHolographicWidget extends StatefulWidget {
  final String image;
  final String? backImage;
  final int animateAngle;
  final double maxHeight;
  final double aspectRatio;
  final double? borderRadius;
  final TouchCallback touchCallback;
  final GlowConfiguration? glow;
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
    this.animateAngle = 2,
    this.borderRadius,
    this.backImage,
    this.glow,
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
    this.borderRadius = 12,
    this.animateAngle = 2,
    this.backImage,
    this.glare,
    this.filter,
    this.mask,
    this.glow,
  });

  factory CardHolographicWidget.network({
    required String image,
    required TouchCallback touchCallback,
    String? backImage,
    int animateAngle = 2,
    double maxHeight = 360,
    double aspectRatio = 734 / 1024,
    double borderRadius = 12,
    GlowConfiguration? glow,
    GlareConfiguration? glare,
    FilterConfiguration? filter,
    MaskConfiguration? mask,
    ShimmerConfiguration? shimmer,
  }) => CardHolographicWidget._(
    image: image,
    backImage: backImage,
    touchCallback: touchCallback,
    maxHeight: maxHeight,
    aspectRatio: aspectRatio,
    borderRadius: borderRadius,
    animateAngle: animateAngle,
    glow: glow,
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
    initializeOverlay(this, widget.animateAngle);
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
        Widget imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
          child: _CardImageWidget(
            image: widget.image,
            sourceType: widget.sourceType,
            lightPoints: (_lightX, _lightY),
            isOnHover: snapshot.data!,
            size: size,
            borderRadius: widget.borderRadius,
            glare: widget.glare,
            filter: widget.filter,
            mask: widget.mask,
          ),
        );
        if (widget.glow != null) {
          imageWidget = GlowAnimateWidget(
            glow: widget.glow!,
            borderRadius: widget.borderRadius,
            child: imageWidget,
          );
        }
        return MotionAnimateWidget(
          borderRadius: widget.borderRadius,
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
          child: imageWidget,
        );
      }
    );
    return !isOverlay ? GestureDetector(
      key: _overlayKey,
      onTap: () => showOverlay(context, _overlayKey.currentContext, child),
      child: child,
    ) : SizedBox(width: size.width, height: size.height,);
  }

  @override
  Widget? backCardWidget() {
    if (widget.backImage == null) {
      return null;
    } else {
      return Material(
        color: Colors.transparent,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(pi),
              child: Image.asset(
                widget.backImage!,
                fit: BoxFit.contain,
              )
            )
          ),
        ),
      );
    }
  }
}

class _CardImageWidget extends StatefulWidget {
  final String image;
  final bool isOnHover;
  final double? borderRadius;
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
    this.borderRadius,
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
          final width = rect.width == 0 ? 1 : rect.width;
          final height = rect.height == 0 ? 1 : rect.height;
          return RadialGradient(
            center: Alignment(
                (widget.lightPoints.$1 / width) * 2 - 1,
                (widget.lightPoints.$2 / height) * 2 - 1
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
