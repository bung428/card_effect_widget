import 'dart:math';
import 'dart:ui';

import 'package:card_effect_widget/models/configuration.dart';
import 'package:flutter/material.dart';

class GlowAnimateWidget extends StatefulWidget {
  final Widget child;
  final double? borderRadius;
  final GlowConfiguration glow;

  const GlowAnimateWidget({
    super.key,
    required this.child,
    required this.glow,
    this.borderRadius,
  });

  @override
  State<GlowAnimateWidget> createState() => _GlowAnimateWidgetState();
}

class _GlowAnimateWidgetState extends State<GlowAnimateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _angleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: widget.glow.animateDuration)
    );
    _controller.addListener(() => setState(() {}));
    _angleAnimation = Tween<double>(
        begin: 0.1,
        end: widget.glow.angleDegree * pi
    ).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GlowAnimateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final glow = widget.glow;
    return Container(
      // padding: EdgeInsets.all((glow.glowSize) * 3 + (glow.borderSize) * 3),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(glow.borderRadius)),
      child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
        Positioned(
            top: glow.glowSize,
            left: glow.glowSize,
            right: glow.glowSize,
            bottom: glow.glowSize,
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(glow.borderRadius),
                    gradient: SweepGradient(
                        colors: [...glow.colors, ...glow.colors.reversed],
                        stops: _generateColorStops([...glow.colors, ...glow.colors.reversed]),
                        transform: GradientRotation(_angleAnimation.value)
                    )
                )
            )
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: glow.glowSize, sigmaY: glow.glowSize - 3),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                  top: glow.glowSize,
                  right: glow.glowSize,
                  left: glow.glowSize,
                  bottom: glow.glowSize,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(glow.borderRadius),
                          gradient: SweepGradient(
                              colors: [...glow.colors, ...glow.colors.reversed],
                              stops: _generateColorStops([...glow.colors, ...glow.colors.reversed]),
                              transform: GradientRotation(_angleAnimation.value)
                          )
                      )
                  )
              ),
              Padding(
                padding: EdgeInsets.all(glow.glowSize + glow.borderSize),
                child: widget.child
              ),
            ],
          ),
        ),
      ]),
    );

  }

  List<double> _generateColorStops(List<dynamic> colors) {
    return colors.asMap().entries.map((entry) {
      double percentageStop = entry.key / colors.length;
      return percentageStop;
    }).toList();
  }
}