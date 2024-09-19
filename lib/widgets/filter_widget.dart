import 'package:card_effect_widget/models/configuration.dart';
import 'package:card_effect_widget/widgets/color_filter_widget.dart';
import 'package:flutter/material.dart';

class FilterWidget extends StatelessWidget {
  final Widget child;
  final bool isOnHover;
  final List<FilterData> filters;

  const FilterWidget({
    super.key,
    required this.filters,
    required this.child,
    required this.isOnHover
  });

  @override
  Widget build(BuildContext context) {
    Widget filterWidget = child;
    for (final filter in filters) {
      filterWidget = ColorFilterWidget(
        isOnHover: isOnHover,
        type: filter.type,
        value: filter.value,
        child: filterWidget,
      );
    }
    return filterWidget;
  }
}
