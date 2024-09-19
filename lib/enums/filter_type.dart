import 'dart:math';

import 'package:flutter/material.dart';

const defaultMatrix = <double>[
1, 0, 0, 0, 0,
0, 1, 0, 0, 0,
0, 0, 1, 0, 0,
0, 0, 0, 1, 0,
];

enum FilterType {
  contrast,
  grayScale,
  sepia,
  invert,
  hue,
  brightness,
  saturate,
  opacity,
}

extension FilterExtension on FilterType {
  ColorFilter filterByValue(bool isOnHover, double value) {
    final filterMatrix = switch (this) {
      FilterType.contrast => _contrastMatrix(value),
      FilterType.grayScale => _grayscaleMatrix(value),
      FilterType.sepia => _sepiaMatrix(value),
      FilterType.invert => _invertMatrix(value),
      FilterType.hue => _hueMatrix(value),
      FilterType.brightness => _brightnessMatrix(value),
      FilterType.saturate => _saturateMatrix(value),
      FilterType.opacity => _opacityMatrix(value),
    };
    return ColorFilter.matrix(isOnHover ? filterMatrix : defaultMatrix);
  }

  List<double> _contrastMatrix(double contrast) {
    double offset = (1.0 - contrast) * 0.5 * 255.0;

    return [
      contrast, 0, 0, 0, offset,
      0, contrast, 0, 0, offset,
      0, 0, contrast, 0, offset,
      0, 0, 0, 1, 0,
    ];
  }

  List<double> _hueMatrix(double value) {
    double v = pi * (value / 180.0);
    double cosVal = cos(v);
    double sinVal = sin(v);
    double lumR = 0.213;
    double lumG = 0.715;
    double lumB = 0.072;

    return [
      lumR + cosVal * (1 - lumR) + sinVal * (-lumR),
      lumG + cosVal * (-lumG) + sinVal * (-lumG),
      lumB + cosVal * (-lumB) + sinVal * (1 - lumB),
      0, 0,
      lumR + cosVal * (-lumR) + sinVal * 0.143,
      lumG + cosVal * (1 - lumG) + sinVal * 0.14,
      lumB + cosVal * (-lumB) + sinVal * (-0.283),
      0, 0,
      lumR + cosVal * (-lumR) + sinVal * (-(1 - lumR)),
      lumG + cosVal * (-lumG) + sinVal * lumG,
      lumB + cosVal * (1 - lumB) + sinVal * lumB,
      0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  List<double> _sepiaMatrix(double value) {
    return [
      0.393 + (1 - value) * 0.607, 0.769 - (1 - value) * 0.769, 0.189 - (1 - value) * 0.189, 0, 0,
      0.349 - (1 - value) * 0.349, 0.686 + (1 - value) * 0.314, 0.168 - (1 - value) * 0.168, 0, 0,
      0.272 - (1 - value) * 0.272, 0.534 - (1 - value) * 0.534, 0.131 + (1 - value) * 0.869, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  List<double> _invertMatrix(double value) {
    return [
      (1 - value) * 1 + value * -1, 0, 0, 0, value * 255,
      0, (1 - value) * 1 + value * -1, 0, 0, value * 255,
      0, 0, (1 - value) * 1 + value * -1, 0, value * 255,
      0, 0, 0, 1, 0,
    ];
  }

  List<double> _brightnessMatrix(double brightness) {
    return [
      brightness, 0, 0, 0, 0,
      0, brightness, 0, 0, 0,
      0, 0, brightness, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  List<double> _saturateMatrix(double saturation) {
    return [
      0.213 + 0.787 * saturation, 0.715 - 0.715 * saturation, 0.072 - 0.072 * saturation, 0, 0,
      0.213 - 0.213 * saturation, 0.715 + 0.285 * saturation, 0.072 - 0.072 * saturation, 0, 0,
      0.213 - 0.213 * saturation, 0.715 - 0.715 * saturation, 0.072 + 0.928 * saturation, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  List<double> _grayscaleMatrix(double value) {
    double v = 1.0 - value;
    double lumR = 0.2126;
    double lumG = 0.7152;
    double lumB = 0.0722;

    return [
      (lumR + (1 - lumR) * v), (lumG - lumG * v), (lumB - lumB * v), 0, 0,
      (lumR - lumR * v), (lumG + (1 - lumG) * v), (lumB - lumB * v), 0, 0,
      (lumR - lumR * v), (lumG - lumG * v), (lumB + (1 - lumB) * v), 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  List<double> _opacityMatrix(double opacity) {
    return [
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, opacity, 0,
    ];
  }
}
