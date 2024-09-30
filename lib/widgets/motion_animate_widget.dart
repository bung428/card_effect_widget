import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef HoverCallback = void Function(bool isTouch, double x, double y);
typedef SizeCallback = void Function(Size size);

class MotionAnimateWidget extends StatefulWidget {
  final double maxHeight;
  final double aspectRatio;
  final double? borderRadius;
  final SizeCallback sizeCallback;
  final HoverCallback hoverCallback;
  final Widget child;

  const MotionAnimateWidget({
    super.key,
    required this.maxHeight,
    required this.aspectRatio,
    required this.sizeCallback,
    required this.hoverCallback,
    required this.child,
    this.borderRadius,
  });

  @override
  State<MotionAnimateWidget> createState() => _MotionAnimateWidgetState();
}

class _MotionAnimateWidgetState extends State<MotionAnimateWidget>
    with TickerProviderStateMixin {
  double _xRotation = 0;
  double _yRotation = 0;
  double _lightX = 0;
  double _lightY = 0;
  bool isOnHover = false;

  Size childSize = Size.zero;

  final widgetKey = GlobalKey();

  late AnimationController _controller;
  late Animation<double> _xRotationAnimation;
  late Animation<double> _yRotationAnimation;
  late Animation<double> _lightXAnimation;
  late Animation<double> _lightYAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widgetKey.currentContext == null) return;
      final box = widgetKey.currentContext!.findRenderObject() as RenderBox;
      _setConfigureBySize(box.size);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setConfigureBySize(Size size) {
    childSize = size;
    _lightX = size.width / 2;
    _lightY = size.height / 2;
    widget.hoverCallback.call(false, _lightX, _lightY);
    widget.sizeCallback.call(size);

    setState(() {});
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
    widget.hoverCallback.call(true, _lightX, _lightY);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
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
      if (mounted) {
        _controller.forward(from: 0);

        _controller.addListener(() {
          setState(() {
            _xRotation = _xRotationAnimation.value;
            _yRotation = _yRotationAnimation.value;
            _lightX = _lightXAnimation.value;
            _lightY = _lightYAnimation.value;
            widget.hoverCallback.call(false, _lightX, _lightY);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                // widget.touchCallback.call(true);

                _onPointerHover(event.localPosition);
              },
              onExit: (event) {
                isOnHover = false;
                // widget.touchCallback.call(false);

                _onPointerExit();
              },
              child: Listener(
                onPointerHover: (details) {
                  isOnHover = true;
                  // widget.touchCallback.call(true);

                  _onPointerHover(details.localPosition);
                },
                onPointerMove: (details) {
                  isOnHover = true;
                  // widget.touchCallback.call(true);

                  _onPointerHover(details.localPosition);
                },
                onPointerUp: (_) {
                  isOnHover = false;
                  // widget.touchCallback.call(false);

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
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
