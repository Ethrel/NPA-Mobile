import 'package:flutter/material.dart';

class Hideable extends StatefulWidget {
  const Hideable({
    super.key,
    required this.child,
    this.duration,
    this.childHeight,
  });

  final Widget child;
  final Duration? duration;
  final double? childHeight;

  @override
  State<StatefulWidget> createState() => HideableState();
}

class HideableState extends State<Hideable> {
  Duration duration = const Duration(milliseconds: 500);
  double childHeight = kBottomNavigationBarHeight;
  bool isVisible = false;

  HideableState();

  void show() => setState(() {
        isVisible = true;
      });
  void hide() => setState(() {
        isVisible = false;
      });
  void toggleVisibility() => setState(() {
        isVisible = !isVisible;
      });

  @override
  void initState() {
    super.initState();
    duration = widget.duration != null ? widget.duration! : duration;
    childHeight = widget.childHeight != null ? widget.childHeight! : childHeight;
    isVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      height: isVisible ? childHeight : 0.0,
      child: widget.child,
    );
  }
}
