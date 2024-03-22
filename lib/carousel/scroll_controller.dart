//
import 'package:carousel_animation_challenge/helpers/constants.dart';
import 'package:carousel_animation_challenge/carousel/scroll_position.dart';
import 'package:carousel_animation_challenge/helpers/utils.dart';
import 'package:flutter/widgets.dart';

/// Scroll controller for [Carousel].
///
class CarouselScrollController extends ScrollController {
  /// Scroll controller for [Carousel].
  CarouselScrollController({this.initialItem = 0});

  /// Initial item index for [CarouselScrollController]. Defaults to 0.
  final int initialItem;

  /// Returns selected Item index. If loop => true, then it returns the modded index value.
  int get selectedItem => getTrueIndex(
        (position as CarouselScrollPosition).itemIndex,
        (position as CarouselScrollPosition).itemCount,
      );

  /// Animate to specific item index.
  Future<void> animateToItem(int itemIndex, {Duration duration = kDefaultDuration, Curve curve = kDefaultCurve}) async {
    if (!hasClients) return;

    await Future.wait<void>([
      for (final position in positions.cast<CarouselScrollPosition>())
        position.animateTo(itemIndex * position.itemExtent, duration: duration, curve: curve),
    ]);
  }

  /// Jump to specific item index.
  void jumpToItem(int itemIndex) {
    for (final position in positions.cast<CarouselScrollPosition>()) {
      position.jumpTo(itemIndex * position.itemExtent);
    }
  }

  /// Animate to next item in viewport.
  Future<void> nextItem({Duration duration = kDefaultDuration, Curve curve = kDefaultCurve}) async {
    if (!hasClients) return;

    await Future.wait<void>([
      for (final position in positions.cast<CarouselScrollPosition>())
        position.animateTo(offset + position.itemExtent, duration: duration, curve: curve),
    ]);
  }

  /// Animate to previous item in viewport.
  Future<void> previousItem({Duration duration = kDefaultDuration, Curve curve = kDefaultCurve}) async {
    if (!hasClients) return;

    await Future.wait<void>([
      for (final position in positions.cast<CarouselScrollPosition>())
        position.animateTo(offset - position.itemExtent, duration: duration, curve: curve),
    ]);
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition? oldPosition) {
    return CarouselScrollPosition(
      physics: physics,
      context: context,
      initialItem: initialItem,
      oldPosition: oldPosition,
    );
  }
}
