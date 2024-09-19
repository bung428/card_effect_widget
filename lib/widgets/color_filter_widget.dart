import 'package:card_effect_widget/enums/filter_type.dart';
import 'package:card_effect_widget/utils/filter_matrix.dart';
import 'package:flutter/material.dart';

class ColorFilterWidget extends StatelessWidget {
  final bool isOnHover;
  final double value;
  final Widget child;
  final FilterType type;

  const ColorFilterWidget({
    super.key,
    required this.type,
    required this.value,
    required this.child,
    this.isOnHover = false,
  });

  @override
  Widget build(BuildContext context) {
    final matrix = baseMatrix();
    final typeMatrix = switch (type) {
      FilterType.contrast => FilterMatrix.contrast(matrix: matrix, value: value),
      FilterType.grayScale => FilterMatrix.grayscale(matrix: matrix, value: value),
      FilterType.sepia => FilterMatrix.sepia(matrix: matrix, value: value),
      FilterType.invert => FilterMatrix.invert(matrix: matrix, value: value),
      FilterType.hue => FilterMatrix.hue(matrix: matrix, value: value),
      FilterType.brightness => FilterMatrix.brightness(matrix: matrix, value: value),
      FilterType.saturate => FilterMatrix.saturate(matrix: matrix, value: value),
      FilterType.opacity => FilterMatrix.opacity(matrix: matrix, value: value),
    };
    return ColorFiltered(
      colorFilter: toColorFilterMatrix(isOnHover ? typeMatrix : matrix),
      child: child,
    );
  }
}
