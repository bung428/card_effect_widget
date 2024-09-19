import 'package:card_effect_widget/enums/filter_type.dart';
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
    return ColorFiltered(
      colorFilter: type.filterByValue(isOnHover, value),
      child: child,
    );
  }
}
