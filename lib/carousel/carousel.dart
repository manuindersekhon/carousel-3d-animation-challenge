import 'package:carousel_animation_challenge/carousel/carousel_physics.dart';
import 'package:carousel_animation_challenge/carousel/scroll_controller.dart';
import 'package:carousel_animation_challenge/carousel/scroll_metrics.dart';
import 'package:carousel_animation_challenge/carousel/scrollable_builder.dart';
import 'package:carousel_animation_challenge/helpers/utils.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

///
/// This widget builds the bare minimum carousel without any animations support, instead it builds the logic for
/// infinite looping, friction simulation based physics and scroll controller for programmatic control.
///
class Carousel extends StatefulWidget {
  Carousel.builder({
    super.key,
    required this.itemCount,
    required this.itemExtent,
    required this.itemBuilder,
    this.physics,
    this.controller,
    this.onIndexChanged,
    this.scrollBehavior,
  })  : assert(itemExtent > 0),
        assert(controller is CarouselScrollController),
        assert(itemCount > 0),
        childDelegate = SliverChildBuilderDelegate(
          (context, index) => itemBuilder(context, index.abs() % itemCount, index),
        ),
        reversedChildDelegate = SliverChildBuilderDelegate(
          (context, index) => itemBuilder(context, itemCount - (index.abs() % itemCount) - 1, -(index + 1)),
        );

  /// Total items to build for the carousel.
  final int itemCount;

  /// Maximum width for single item in viewport.
  final double itemExtent;

  /// To lazily build items on the viewport.
  final Widget Function(BuildContext context, int itemIndex, int realIndex) itemBuilder;

  /// Delegate to lazily build items in forward direction.
  final SliverChildDelegate? childDelegate;

  /// Delegate to lazily build items in reverse direction.
  final SliverChildDelegate? reversedChildDelegate;

  /// Defaults to [CarouselScrollPhysics], which makes sure we always land on a particular item even after free hand
  /// scrolling. You can set it to [NeverScrollableScrollPhysics] to disable user interaction.
  final ScrollPhysics? physics;

  /// Scroll behavior for [Carousel]. You can modify this to have different behavior on different platforms.
  final ScrollBehavior? scrollBehavior;

  /// Scroll controller for [CarouselScrollPhysics].
  final ScrollController? controller;

  /// Callback fired when item is changed.
  final void Function(int)? onIndexChanged;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final Key _forwardListKey = const ValueKey<String>('3d_carousel_key');

  // Decide carousel direction from LTR or RTL text directions.
  late final AxisDirection axisDirection = getDirectionFromContext(context);

  // Initialise scroll controller if not provided by user.
  late final CarouselScrollController scrollController = switch (widget.controller) {
    CarouselScrollController val => val,
    _ => CarouselScrollController(),
  };

  // Defaults to 0 if user does not provide one through the controller.
  late int _lastReportedItemIndex = scrollController.initialItem;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (ScrollUpdateNotification notification) {
        // Get snapshot of current scroll state and notify listeners.
        if (widget.onIndexChanged != null && notification.metrics is CarouselExtentMetrics) {
          final CarouselExtentMetrics metrics = notification.metrics as CarouselExtentMetrics;
          final int currentItem = metrics.itemIndex;
          if (currentItem != _lastReportedItemIndex) {
            _lastReportedItemIndex = currentItem;
            final int trueIndex = getTrueIndex(_lastReportedItemIndex, widget.itemCount);
            widget.onIndexChanged?.call(trueIndex);
          }
        }
        // Let the scroll state bubble up in case user has listenrs attached up the tree.
        return false;
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ScrollableBuilder(
            controller: scrollController,
            itemExtent: widget.itemExtent,
            itemCount: widget.itemCount,
            physics: widget.physics ?? const CarouselScrollPhysics(),
            axisDirection: axisDirection,
            scrollBehavior: widget.scrollBehavior ?? ScrollConfiguration.of(context).copyWith(scrollbars: false),
            viewportBuilder: (BuildContext context, ViewportOffset position) {
              return Viewport(
                center: _forwardListKey,
                anchor: getCenteredAnchor(constraints, widget.itemExtent),
                axisDirection: axisDirection,
                offset: position,
                slivers: [
                  SliverFixedExtentList(
                    delegate: widget.reversedChildDelegate!,
                    itemExtent: widget.itemExtent,
                  ),
                  SliverFixedExtentList(
                    key: _forwardListKey,
                    delegate: widget.childDelegate!,
                    itemExtent: widget.itemExtent,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
