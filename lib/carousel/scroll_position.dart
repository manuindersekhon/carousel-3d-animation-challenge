import 'package:carousel_animation_challenge/carousel/scroll_metrics.dart';
import 'package:carousel_animation_challenge/carousel/scrollable_builder.dart';
import 'package:carousel_animation_challenge/helpers/utils.dart';
import 'package:flutter/widgets.dart';

class CarouselScrollPosition extends ScrollPositionWithSingleContext implements CarouselExtentMetrics {
  CarouselScrollPosition({
    required super.physics,
    required super.context,
    required int initialItem,
    super.oldPosition,
  })  : assert(context is ScrollableBuilderState),
        super(
          initialPixels: _getItemExtentFromScrollContext(context) * initialItem,
        );

  double get itemExtent => _getItemExtentFromScrollContext(context);
  static double _getItemExtentFromScrollContext(ScrollContext context) {
    return (context as ScrollableBuilderState).itemExtent;
  }

  int get itemCount => _getItemCountFromScrollContext(context);
  static int _getItemCountFromScrollContext(ScrollContext context) {
    return (context as ScrollableBuilderState).itemCount;
  }

  @override
  double get maxScrollExtent => super.hasContentDimensions ? super.maxScrollExtent : 0.0;

  @override
  int get itemIndex {
    return getItemFromOffset(
      offset: pixels,
      itemExtent: itemExtent,
      minScrollExtent: hasContentDimensions ? minScrollExtent : 0.0,
      maxScrollExtent: maxScrollExtent,
    );
  }

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
}
