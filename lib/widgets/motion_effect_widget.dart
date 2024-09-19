import 'package:card_effect_widget/enums/image_source_type.dart';
import 'package:card_effect_widget/models/configuration.dart';
import 'package:card_effect_widget/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'filter_widget.dart';
import 'mask_widget.dart';

typedef TouchCallback = void Function(bool isTouch);

class MotionEffectWidget extends StatefulWidget {
  final String image;
  final double maxHeight;
  final double aspectRatio;
  final TouchCallback touchCallback;
  final GlareConfiguration? glare;
  final FilterConfiguration? filter;
  final MaskConfiguration? mask;
  final ShimmerConfiguration? shimmer;
  final ImageSourceType sourceType;

  const MotionEffectWidget._({
    required this.image,
    required this.touchCallback,
    this.sourceType = ImageSourceType.asset,
    this.maxHeight = 360,
    this.aspectRatio = 734 / 1024,
    this.glare,
    this.filter,
    this.mask,
    this.shimmer,
  });

  const MotionEffectWidget.asset({
    super.key,
    required this.image,
    required this.touchCallback,
    this.sourceType = ImageSourceType.asset,
    this.maxHeight = 360,
    this.aspectRatio = 734 / 1024,
    this.glare,
    this.filter,
    this.mask,
    this.shimmer,
  });

  factory MotionEffectWidget.network({
    required String image,
    required TouchCallback touchCallback,
    double maxHeight = 360,
    double aspectRatio = 734 / 1024,
    GlareConfiguration? glare,
    FilterConfiguration? filter,
    MaskConfiguration? mask,
    ShimmerConfiguration? shimmer,
  }) => MotionEffectWidget._(
    image: image,
    touchCallback: touchCallback,
    maxHeight: maxHeight,
    aspectRatio: aspectRatio,
    glare: glare,
    filter: filter,
    mask: mask,
    shimmer: shimmer,
    sourceType: ImageSourceType.network,
  );

  @override
  State createState() => _MotionEffectWidgetState();
}

class _MotionEffectWidgetState extends State<MotionEffectWidget> with SingleTickerProviderStateMixin {
  double _xRotation = 0;
  double _yRotation = 0;
  double _lightX = 0;
  double _lightY = 0;
  Size childSize = Size.zero;

  bool isOnHover = false;

  final widgetKey = GlobalKey();

  late AnimationController _controller;
  late Animation<double> _xRotationAnimation;
  late Animation<double> _yRotationAnimation;
  late Animation<double> _lightXAnimation;
  late Animation<double> _lightYAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Animation duration
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widgetKey.currentContext == null) return;
      final box = widgetKey.currentContext!.findRenderObject() as RenderBox;
      _setChildSize(box.size);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setChildSize(Size size) {
    if (!mounted) return;
    if (childSize == Size.zero) {
      childSize = size;
      _lightX = size.width / 2;
      _lightY = size.height / 2;
      setState(() {});
    }
  }

  void _onPointerHover(Offset localPosition) {
    if (!mounted) return;

    final centerX = childSize.width / 2;
    final centerY = childSize.height / 2;

    var x = (localPosition.dx - centerX) / centerX;
    var y = (localPosition.dy - centerY) / centerY;

    _xRotation = y * -0.5;
    _yRotation = x * 0.5;
    _lightX = localPosition.dx;
    _lightY = localPosition.dy;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _onPointerExit() async {
    if (!mounted) return;
    if (childSize == Size.zero) return;

    _xRotationAnimation = Tween<double>(begin: _xRotation, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _yRotationAnimation = Tween<double>(begin: _yRotation, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _lightXAnimation = Tween<double>(begin: _lightX, end: childSize.width / 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _lightYAnimation = Tween<double>(begin: _lightY, end: childSize.height / 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward(from: 0);

      _controller.addListener(() {
        setState(() {
          _xRotation = _xRotationAnimation.value;
          _yRotation = _yRotationAnimation.value;
          _lightX = _lightXAnimation.value;
          _lightY = _lightYAnimation.value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var child = _buildMotionWidgetByConfig();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          key: widgetKey,
          height: widget.maxHeight,
          color: Colors.transparent,
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: MouseRegion(
              onHover: (event) {
                isOnHover = true;
                widget.touchCallback.call(true);

                _onPointerHover(event.localPosition);
              },
              onExit: (event) {
                isOnHover = false;
                widget.touchCallback.call(false);

                _onPointerExit();
              },
              child: Listener(
                onPointerHover: (details) {
                  isOnHover = true;
                  widget.touchCallback.call(true);

                  _onPointerHover(details.localPosition);
                },
                onPointerMove: (details) {
                  isOnHover = true;
                  widget.touchCallback.call(true);

                  _onPointerHover(details.localPosition);
                },
                onPointerUp: (_) {
                  isOnHover = false;
                  widget.touchCallback.call(false);

                  _onPointerExit();
                },
                behavior: HitTestBehavior.opaque,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_xRotation)
                    ..rotateY(_yRotation),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotionWidgetByConfig() {
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
          isOnHover: isOnHover,
          image: widget.mask!.maskImg,
          width: childSize.width,
          height: childSize.height,
          mode: widget.mask!.blendMode,
          child: child
      );
    }
    if (widget.filter != null) {
      child = FilterWidget(
          filters: widget.filter!.filters,
          isOnHover: isOnHover,
          child: child
      );
    }
    if (widget.shimmer != null) {
      child = ShimmerWidget(
        end: widget.shimmer!.end,
        begin: widget.shimmer!.begin,
        stops: widget.shimmer!.stops,
        colors: widget.shimmer!.colors,
        tileMode: widget.shimmer!.tileMode,
        blendMode: widget.shimmer!.blendMode,
        child: child,
      );
    }
    if (widget.glare != null) {
      child = ShaderMask(
          shaderCallback: (rect) {
            return RadialGradient(
              center: Alignment((_lightX / rect.width) * 2 - 1, (_lightY / rect.height) * 2 - 1),
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