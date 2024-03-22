import "dart:math" as math;

import 'package:carousel_animation_challenge/data.dart';
import 'package:carousel_animation_challenge/infinite_carousel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carousel Animation Challenge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final InfiniteScrollController _scrollController = InfiniteScrollController();
  late double _itemExtent = 200 + 50 * math.log(MediaQuery.of(context).size.width / 300);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      for (final url in kImageUrls) {
        precacheImage(NetworkImage(url), context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _itemExtent = 200 + 50 * math.log(MediaQuery.of(context).size.width / 300);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: InfiniteCarousel.builder(
          itemCount: kImageUrls.length,
          itemExtent: _itemExtent,
          controller: _scrollController,
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

            return AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final double offsetDiff = _scrollController.offset - currentOffset;
                final double angle = -offsetDiff * math.min(0.001, 0.002);
                final double scaleFactor = math.max(0.75, math.sin(angle.abs()));
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
              child: Container(
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
              ),
            );
          },
        ),
      ),
    );
  }
}
