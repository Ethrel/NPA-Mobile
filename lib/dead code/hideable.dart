import 'package:flutter/material.dart';

class Hideable extends StatelessWidget {
  Hideable({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.childHeight = kBottomNavigationBarHeight,
  });

  final Widget child;
  final Duration duration;
  final double childHeight;

  final ValueNotifier<bool> isVisible = ValueNotifier<bool>(false);

  void dispose() {
    isVisible.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isVisible,
      builder: (BuildContext context, bool value, Widget? child) => AnimatedContainer(
        duration: duration,
        height: value ? childHeight : 0.0,
        child: this.child,
      ),
    );
  }
}
