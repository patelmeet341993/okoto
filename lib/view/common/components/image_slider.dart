import 'dart:async';

import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  /// Children in slideView to slide
  final List<Widget> children;

  /// If automatic sliding is required
  final bool autoSlide;

  /// If manual sliding is required
  final bool allowManualSlide;

  /// Animation curves of sliding
  final Curve curve;

  /// Time for automatic sliding
  final Duration duration;

  /// Width of the slider
  final double width;

  /// Height of the slider
  final double height;

  /// Shows the tab indicating circles at the bottom
  final bool showTabIndicator;

  /// Cutomize tab's colors
  final Color tabIndicatorColor;

  /// Customize selected tab's colors
  final Color tabIndicatorSelectedColor;

  /// Size of the tab indicator circles
  final double tabIndicatorSize;

  /// Height of the indicators from the bottom
  final double tabIndicatorHeight;

  /// tabController for walkthrough or other implementations
  final TabController tabController;

  const ImageSlider({
    Key? key,
    required this.children,
    required this.width,
    required this.height,
    required this.curve,
    this.tabIndicatorColor = Colors.white,
    this.tabIndicatorSelectedColor = Colors.black,
    this.tabIndicatorSize = 5,
    this.tabIndicatorHeight = 10,
    this.allowManualSlide = true,
    this.autoSlide = false,
    this.showTabIndicator = false,
    required this.tabController,
    this.duration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider>
    with SingleTickerProviderStateMixin {
  /// Setting timer and physics on init!
  @override
  void initState() {
    if (widget.autoSlide) {
      timer = Timer.periodic(widget.duration, (Timer t) {
        widget.tabController.animateTo(
            (widget.tabController.index + 1) % (widget.tabController.length > 0 ? widget.tabController.length : 1),
            curve: widget.curve);
      });
    }
    if (widget.allowManualSlide) {
      scrollPhysics = const ScrollPhysics();
    } else {
      scrollPhysics = const NeverScrollableScrollPhysics();
    }
    super.initState();
  }

//Declared Timer and physics.
  Timer? timer;
  ScrollPhysics? scrollPhysics;

  @override
  Widget build(BuildContext context) {
    // Container has a stack with the tab indicators and the tab bar view!
    return Column(
      children: [
        ClipPath(
          clipper: _CustomClipper(),
          clipBehavior: Clip.antiAlias,
          child:  SizedBox(
              width: widget.width,
              height: widget.height,
              child: TabBarView(
                controller: widget.tabController,
                physics: scrollPhysics,
                children: widget.children,
              )),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          width: widget.width,
          child: TabPageSelectorCustom(
            controller: widget.tabController,
            color: widget.tabIndicatorColor,
            selectedColor: widget.tabIndicatorSelectedColor,
            indicatorSize: widget.tabIndicatorSize,
          ),
        ),
      ],
    );
  }
}

double _indexChangeProgress(TabController controller) {
  final double controllerValue = controller.animation!.value;
  final double previousIndex = controller.previousIndex.toDouble();
  final double currentIndex = controller.index.toDouble();

  // The controller's offset is changing because the user is dragging the
  // TabBarView's PageView to the left or right.
  if (!controller.indexIsChanging) {
    return (currentIndex - controllerValue).abs().clamp(0.0, 1.0);
  }

  // The TabController animation's value is changing from previousIndex to currentIndex.
  return (controllerValue - currentIndex).abs() / (currentIndex - previousIndex).abs();
}

class TabPageSelectorCustom extends StatelessWidget {
  /// Creates a compact widget that indicates which tab has been selected.
  const TabPageSelectorCustom({
    Key? key,
    this.controller,
    this.indicatorSize = 12.0,
    this.color,
    this.selectedColor,
  })  : assert(indicatorSize > 0.0),
        super(key: key);

  /// This widget's selection and animation state.
  ///
  /// If [TabController] is not provided, then the value of
  /// [DefaultTabController.of] will be used.
  final TabController? controller;

  /// The indicator circle's diameter (the default value is 12.0).
  final double indicatorSize;

  /// The indicator circle's fill color for unselected pages.
  ///
  /// If this parameter is null, then the indicator is filled with [Colors.transparent].
  final Color? color;

  /// The indicator circle's fill color for selected pages and border color
  /// for all indicator circles.
  ///
  /// If this parameter is null, then the indicator is filled with the theme's
  /// accent color, [ThemeData.accentColor].
  final Color? selectedColor;

  Widget _buildTabIndicator(
      int tabIndex,
      TabController tabController,
      ColorTween selectedColorTween,
      ColorTween previousColorTween,
      ) {
    final Color background;
    if (tabController.indexIsChanging) {
      // The selection's animation is animating from previousValue to value.
      final double t = 1.0 - _indexChangeProgress(tabController);
      if (tabController.index == tabIndex) {
        background = selectedColorTween.lerp(t)!;
      } else if (tabController.previousIndex == tabIndex) {
        background = previousColorTween.lerp(t)!;
      } else {
        background = selectedColorTween.begin!;
      }
    } else {
      // The selection's offset reflects how far the TabBarView has / been dragged
      // to the previous page (-1.0 to 0.0) or the next page (0.0 to 1.0).
      final double offset = tabController.offset;
      if (tabController.index == tabIndex) {
        background = selectedColorTween.lerp(1.0 - offset.abs())!;
      } else if (tabController.index == tabIndex - 1 && offset > 0.0) {
        background = selectedColorTween.lerp(offset)!;
      } else if (tabController.index == tabIndex + 1 && offset < 0.0) {
        background = selectedColorTween.lerp(-offset)!;
      } else {
        background = selectedColorTween.begin!;
      }
    }
    return TabPageSelectorIndicatorCustom(
      backgroundColor: background,
      borderColor: selectedColorTween.end!,
      size: indicatorSize,
      isSelected: tabController.index == tabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color fixColor = color ?? Colors.transparent;
    final Color fixSelectedColor =
        selectedColor ?? Theme.of(context).accentColor;
    final ColorTween selectedColorTween =
    ColorTween(begin: fixColor, end: fixSelectedColor);
    final ColorTween previousColorTween =
    ColorTween(begin: fixSelectedColor, end: fixColor);
    final TabController? tabController =
        controller ?? DefaultTabController.of(context);
    assert(() {
      if (tabController == null) {
        throw FlutterError('No TabController for $runtimeType.\n'
            'When creating a $runtimeType, you must either provide an explicit TabController '
            'using the "controller" property, or you must ensure that there is a '
            'DefaultTabController above the $runtimeType.\n'
            'In this case, there was neither an explicit controller nor a default controller.');
      }
      return true;
    }());
    final Animation<double> animation = CurvedAnimation(
      parent: tabController!.animation!,
      curve: Curves.fastOutSlowIn,
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Semantics(
          label: 'Page ${tabController.index + 1} of ${tabController.length}',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children:
            List<Widget>.generate(tabController.length, (int tabIndex) {
              return _buildTabIndicator(tabIndex, tabController,
                  selectedColorTween, previousColorTween);
            }).toList(),
          ),
        );
      },
    );
  }
}

class TabPageSelectorIndicatorCustom extends StatelessWidget {
  /// Creates an indicator used by [TabPageSelector].
  ///
  /// The [backgroundColor], [borderColor], and [size] parameters must not be null.
   TabPageSelectorIndicatorCustom({
    Key? key,
    required this.backgroundColor,
    required this.borderColor,
    required this.size,
    this.isSelected = false
  })  : super(key: key);

  /// The indicator circle's background color.
  final Color backgroundColor;

  /// The indicator circle's border color.
  final Color borderColor;

  /// The indicator circle's diameter.
  final double size;

   bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isSelected ? size+30:size,
      height: size,
      margin: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}


class _CustomClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0,0);
    path.quadraticBezierTo(size.width/2,size.height*0.2,size.width,0);
    path.cubicTo(size.width,size.height,size.width,size.height,size.width,size.height-12);
    //path.cubicTo(0,0,0,0,0,0,);
    path.quadraticBezierTo(size.width/2,size.height*.8,0,size.height-12);
    //path.quadraticBezierTo(size.width*0.5700000,size.height*0.7494286,size.width*0.1216667,size.height*0.9931429);
    path.lineTo(0,0);
    path.close();
    path.close();
    return path;


    // return Path()
    //   //..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
    //  ..moveTo(0, 0)
    //  ..quadraticBezierTo(size.width / 2, size.height *.2, size.width, 0)
    //  ..moveTo(0, size.height)
    //  ..quadraticBezierTo(size.width / 2, size.height *.8, size.width, size.height)

    //..quadraticBezierTo(size.width / 2, size.height *.4, size.width, size.height)

    // ..quadraticBezierTo(size.width / 2, size.height *.8, size.width, size.height)

    //        ..quadraticBezierTo(size.width / 2, size.height *.2, size.width, 0)
    //   ..moveTo(0, size.height)
    // ..quadraticBezierTo(size.width / 2, size.height *.8, size.width, size.height);
    /* ..quadraticBezierTo(
        size.width / 2,
        heightDelta - size.width / 2,
        size.width,
        heightDelta,
      )*/;

  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}




