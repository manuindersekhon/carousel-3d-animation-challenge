import 'package:carousel_animation_challenge/carousel/scroll_position.dart';
import 'package:carousel_animation_challenge/helpers/utils.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

///
/// Physics for [Carousel]. It guarantees to always land on a particular item after a free hand scroll.
///
class CarouselScrollPhysics extends ScrollPhysics {
  const CarouselScrollPhysics({super.parent});

  @override
  CarouselScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CarouselScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final CarouselScrollPosition metrics = position as CarouselScrollPosition;

    // Scenario 1: If we're out of range and not headed back in range, defer to the parent ballistics, which should put
    // us back in range at the scrollable's boundary.
    if ((velocity <= 0.0 && metrics.pixels <= metrics.minScrollExtent) ||
        (velocity >= 0.0 && metrics.pixels >= metrics.maxScrollExtent)) {
      return super.createBallisticSimulation(metrics, velocity);
    }

    // Create a test simulation to see where it would have ballistically fallen naturally without settling onto items.
    final Simulation? testFrictionSimulation = super.createBallisticSimulation(metrics, velocity);

    // Scenario 2: If it was going to end up past the scroll extent, defer back to the parent physics' ballistics again
    // which should put us on the scrollable's boundary.
    if (testFrictionSimulation != null &&
        (testFrictionSimulation.x(double.infinity) == metrics.minScrollExtent ||
            testFrictionSimulation.x(double.infinity) == metrics.maxScrollExtent)) {
      return super.createBallisticSimulation(metrics, velocity);
    }

    // From the natural final position, find the nearest item carousel should have settled to.
    final int settlingItemIndex = getItemFromOffset(
      offset: testFrictionSimulation?.x(double.infinity) ?? metrics.pixels,
      itemExtent: metrics.itemExtent,
      minScrollExtent: metrics.minScrollExtent,
      maxScrollExtent: metrics.maxScrollExtent,
    );
    final double settlingPixels = settlingItemIndex * metrics.itemExtent;

    // Scenario 3: If there's no velocity and we're already at where we intend to land, do nothing.
    final tolerance = toleranceFor(metrics);
    if (velocity.abs() < tolerance.velocity && (settlingPixels - metrics.pixels).abs() < tolerance.distance) {
      return null;
    }

    // Scenario 4: If we're going to end back at the same item because initial velocity is too low to break past it,
    // use a spring simulation to get back.
    if (settlingItemIndex == metrics.itemIndex) {
      return SpringSimulation(spring, metrics.pixels, settlingPixels, velocity, tolerance: tolerance);
    }

    // Scenario 5: Create a new friction simulation to land exactly on the item closest to the next natural stopping point.
    return FrictionSimulation.through(metrics.pixels, settlingPixels, velocity, tolerance.velocity * velocity.sign);
  }
}
