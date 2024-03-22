import 'package:flutter/widgets.dart';

///
/// Extend Scrollable to also include viewport children's itemExtent and itemCount. This is done so that ScrollPosition
/// and Physics can also access these values via scroll context.
///
class ScrollableBuilder extends Scrollable {
  const ScrollableBuilder({
    super.key,
    super.axisDirection = AxisDirection.right,
    super.controller,
    super.physics,
    super.scrollBehavior,
    required this.itemExtent,
    required this.itemCount,
    required super.viewportBuilder,
  });

  final double itemExtent;
  final int itemCount;

  @override
  ScrollableBuilderState createState() => ScrollableBuilderState();
}

class ScrollableBuilderState extends ScrollableState {
  double get itemExtent => (widget as ScrollableBuilder).itemExtent;
  int get itemCount => (widget as ScrollableBuilder).itemCount;
}
