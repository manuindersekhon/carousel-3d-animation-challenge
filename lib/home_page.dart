import 'dart:math' as math;

import 'package:carousel_animation_challenge/carousel/carousel.dart';
import 'package:carousel_animation_challenge/carousel/scroll_controller.dart';
import 'package:carousel_animation_challenge/helpers/data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CarouselScrollController _scrollController = CarouselScrollController();

  // Slowly increase with item size w.r.t screen width.
  late double _itemExtent = 200 + 50 * math.log(MediaQuery.of(context).size.width / 300);

  @override
  void initState() {
    super.initState();

    // Pre cache images for a little smoother first time.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      for (final url in kImageUrls) {
        precacheImage(NetworkImage(url), context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Watch for screen width changes.
    _itemExtent = 200 + 50 * math.log(MediaQuery.of(context).size.width / 300);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        children: [
          const Spacer(),
          FloatingActionButton(
            heroTag: 'prev-item',
            onPressed: () {
              _scrollController.previousItem();
            },
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'next-item',
            onPressed: () {
              _scrollController.nextItem();
            },
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Carousel Animation Challenge'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.lightBlue.shade50],
          ),
        ),
        alignment: Alignment.center,
        child: Carousel.builder(
          itemCount: kImageUrls.length,
          itemExtent: _itemExtent,
          controller: _scrollController,
          // Allow drag by all pointer devices.
          scrollBehavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus
            },
          ),
          itemBuilder: (context, itemIndex, realIndex) {
            final double currentOffset = _itemExtent * realIndex;

            return IndexedSemantics(
              index: itemIndex,
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  final double offsetDiff = _scrollController.offset - currentOffset;

                  // Angle and scale factor for perspective effect. Don't let it do below 0.001 to prevent distortion.
                  final double angle = -offsetDiff * math.min(0.001, 0.002);

                  // Increase the scale as the angle increases.
                  final double scaleFactor = math.max(0.75, math.sin(angle.abs()));

                  // Slighlty rotate on Z axis to give a little more depth.
                  final double zAxisAngle = angle * 0.1;

                  return Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Transform(
                          alignment: FractionalOffset.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.004)
                            ..rotateY(angle)
                            ..rotateZ(zAxisAngle)
                            ..scale(1.0, scaleFactor),
                          child: child,
                        ),
                      ),
                      // Create mirror reflection, but smaller than the actual item.
                      Flexible(
                        flex: 3,
                        child: Transform(
                          alignment: FractionalOffset.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.004)
                            ..rotateY(angle)
                            ..rotateZ(zAxisAngle)
                            ..scale(1.0, -scaleFactor),
                          child: Opacity(
                            opacity: 0.2,
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                child: Semantics(
                  label: 'Image ${itemIndex + 1} of ${kImageUrls.length}',
                  hint: 'Swipe left or right to navigate between images',
                  child: _imageContent(itemIndex),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ///
  /// To demonstrate the simple text widget as carousel item.
  ///
  Widget _simpleContent(int itemIndex) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 15),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(kImageUrls[itemIndex]),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  ///
  /// To demonstrate the image widget as carousel item.
  ///
  Widget _imageContent(int itemIndex) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, 15),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(kImageUrls[itemIndex]),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
