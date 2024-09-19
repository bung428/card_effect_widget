import 'package:flutter/material.dart';

class ShimmerWidget extends StatelessWidget {
  final List<Color> colors;
  final List<double>? stops;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final TileMode tileMode;
  final BlendMode blendMode;
  final Widget child;

  const ShimmerWidget({
    super.key,
    required this.child,
    required this.colors,
    this.tileMode = TileMode.clamp,
    this.blendMode = BlendMode.srcATop,
    this.stops,
    this.begin,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: blendMode,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: colors,
          stops: stops,
          begin: begin ?? Alignment.centerLeft,
          end: end ?? Alignment.centerRight,
          tileMode: tileMode,
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
