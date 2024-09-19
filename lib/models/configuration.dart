import 'package:card_effect_widget/enums/filter_type.dart';
import 'package:flutter/material.dart';

class GlareConfiguration {
  final double radius;
  final double minOpacity;
  final List<Color> colors;
  final List<double>? stops;
  final TileMode tileMode;
  final BlendMode blendMode;

  GlareConfiguration({
    this.radius = 0.85,
    this.minOpacity = 0.7,
    this.tileMode = TileMode.clamp,
    this.blendMode = BlendMode.overlay,
    this.stops,
    required this.colors,
  });

  factory GlareConfiguration.flash() => GlareConfiguration(
    colors: [
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(255, 255, 255, 0.5),
      const Color.fromRGBO(0, 0, 0, 0.5),
    ],
    stops: [
      0.1,
      0.2,
      1.2,
    ],
  );

  factory GlareConfiguration.focus() => GlareConfiguration(
    colors: [
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromRGBO(255, 255, 255, 0.9),
      const Color.fromRGBO(0, 0, 0, 0.9),
    ],
    stops: [0.0, 0.3, 0.5,],
    blendMode: BlendMode.overlay
  );
}

class MaskConfiguration {
  final String maskImg;
  final BlendMode blendMode;

  MaskConfiguration({required this.maskImg, this.blendMode = BlendMode.overlay});
}

class FilterConfiguration {
  final List<FilterData> filters;

  FilterConfiguration({required this.filters});
}

class ShimmerConfiguration {
  final List<Color> colors;
  final List<double>? stops;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final TileMode tileMode;
  final BlendMode blendMode;

  ShimmerConfiguration({
    required this.colors,
    this.stops,
    this.begin,
    this.end,
    this.tileMode = TileMode.clamp,
    this.blendMode = BlendMode.srcATop,
  });
}

class FilterData {
  final FilterType type;
  final double value;

  FilterData({required this.type, required this.value});
}