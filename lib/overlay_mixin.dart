import 'dart:math';

import 'package:flutter/material.dart';

mixin OverlayMixin<T extends StatefulWidget> on State<T> {
  late AnimationController _overlayController;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  late Offset _centerOffset;

  OverlayEntry? _overlayEntry;

  Offset begin = Offset.zero;
  Offset end = Offset.zero;
  Size? widgetSize;

  int? _overlayAnimateAngle;
  bool _isCompleted = false;
  bool isOverlay = false;

  void initializeOverlay(TickerProvider vsync, [int? angle]) {
    if (angle != null) {
      _overlayAnimateAngle = angle;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final center = MediaQuery.of(context).size.center(Offset.zero);
      _centerOffset = Offset(center.dx, center.dy);
      setState(() {});
    });

    _overlayController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: pi * (_overlayAnimateAngle ?? 2))
        .animate(CurvedAnimation(
        parent: _overlayController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.3).animate(
      CurvedAnimation(
        parent: _overlayController,
        curve: Curves.easeInOut,
      ),
    );

    _overlayController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _overlayEntry?.remove();
        setState(() {
          isOverlay = false;
          _isCompleted = false;
        });
      } else if (status == AnimationStatus.completed) {
        setState(() {
          _isCompleted = true;
        });
      } else {
        setState(() {
          _isCompleted = false;
        });
      }
    });
  }

  void setWidgetSize(Size size) {
    widgetSize = size;
    setState(() {});
  }

  void showOverlay(BuildContext context, BuildContext? keyContext, Widget child) {
    if (keyContext == null) return;
    begin = Offset.zero;
    end = Offset.zero;

    final box = keyContext.findRenderObject() as RenderBox;
    begin = box.localToGlobal(Offset.zero);
    end = _centerOffset - Offset(widgetSize!.width / 2, widgetSize!.height / 2);

    _positionAnimation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    ));

    _overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _overlayController,
        builder: (context, _) {
          final frontWidget = Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
          return Positioned(
            left: _positionAnimation.value.dx,
            top: _positionAnimation.value.dy,
            width: widgetSize!.width,
            height: widgetSize!.height,
            child: GestureDetector(
              onTap: hideOverlay,
              child: !_isCompleted ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateY(_rotationAnimation.value),
                child: (_rotationAnimation.value % (2 * pi)) >= pi / 2 &&
                    (_rotationAnimation.value % (2 * pi)) <= (3 * pi) / 2
                    ? buildBackCard()
                    : frontWidget,
              ) : frontWidget,
            ),
          );
        },
      ),
    );

    /// todo: flutter overlay entries 접근 및 관리가 안되고있음.
    Overlay.of(context).insert(_overlayEntry!);
    _overlayController.forward();

    isOverlay = true;
    setState(() {});
  }

  void hideOverlay() {
    _overlayController.reverse();
  }

  Widget buildBackCard() {
    if (widgetSize == null) return const SizedBox.shrink();
    return Container(
      width: widgetSize!.width,
      height: widgetSize!.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Back Side',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    _overlayController.dispose();
    super.dispose();
  }
}
