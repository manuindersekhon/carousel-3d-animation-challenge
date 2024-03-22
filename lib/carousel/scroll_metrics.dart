import 'package:flutter/widgets.dart';

///
/// Metrics for Carousel scroll controller.
///
/// This is an immutable snapshot of the current values of scroll position. This can directly be accessed by ScrollNotification
/// to get currently selected indices at any time.
///
class CarouselExtentMetrics extends FixedScrollMetrics {
  CarouselExtentMetrics({
    required super.minScrollExtent,
    required super.maxScrollExtent,
    required super.pixels,
    required super.viewportDimension,
    required super.axisDirection,
    required super.devicePixelRatio,
    required this.itemIndex,
  });

  @override
  CarouselExtentMetrics copyWith({
    double? minScrollExtent,
    double? maxScrollExtent,
    double? pixels,
    double? viewportDimension,
    AxisDirection? axisDirection,
    double? devicePixelRatio,
    int? itemIndex,
  }) {
    return CarouselExtentMetrics(
      minScrollExtent: minScrollExtent ?? (hasContentDimensions ? this.minScrollExtent : 0.0),
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      pixels: pixels ?? this.pixels,
      viewportDimension: viewportDimension ?? this.viewportDimension,
      axisDirection: axisDirection ?? this.axisDirection,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
      itemIndex: itemIndex ?? this.itemIndex,
    );
  }

  final int itemIndex;
}
