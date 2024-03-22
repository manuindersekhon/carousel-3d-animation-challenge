import "dart:math" as math;

import 'package:flutter/widgets.dart';

/// Get Axis direction from LTR or RTL text directions.
AxisDirection getDirectionFromContext(BuildContext context) {
  assert(debugCheckHasDirectionality(context));
  final TextDirection textDirection = Directionality.of(context);
  final AxisDirection axisDirection = textDirectionToAxisDirection(textDirection);
  return axisDirection;
}

/// Get anchor for viewport to place the selected item in exact center.
double getCenteredAnchor(BoxConstraints constraints, double itemExtent) {
  return ((constraints.maxWidth / 2) - (itemExtent / 2)) / constraints.maxWidth;
}

/// Get the modded item index from real index.
int getTrueIndex(int currentIndex, int totalCount) {
  if (currentIndex >= 0) {
    return currentIndex % totalCount;
  }

  return (totalCount + (currentIndex % totalCount)) % totalCount;
}

/// Get item index from raww pixels.
int getItemFromOffset({
  required double offset,
  required double itemExtent,
  required double minScrollExtent,
  required double maxScrollExtent,
}) {
  return (_clipOffsetToScrollableRange(offset, minScrollExtent, maxScrollExtent) / itemExtent).round();
}

double _clipOffsetToScrollableRange(double offset, double minScrollExtent, double maxScrollExtent) {
  return math.min(math.max(offset, minScrollExtent), maxScrollExtent);
}
