import 'package:flutter/material.dart';
import 'package:neptunes_pride_agent_mobile/main.dart';
import 'package:neptunes_pride_agent_mobile/typedef/hotkey_data.dart';

class HotkeyBar extends StatefulWidget {
  HotkeyBar({super.key});

  final ValueNotifier<bool> _isVisible = ValueNotifier(false);
  bool get isVisible => _isVisible.value;
  set isVisible(bool visible) => _isVisible.value = visible;

  void toggleVisible() => isVisible = !isVisible;

  @override
  State<StatefulWidget> createState() => _HotkeyBarState();
}

class _HotkeyBarState extends State<HotkeyBar> {
  static const Color _circleColor = Color.fromARGB(255, 25, 28, 65);
  static const Color _iconColor = Colors.white;

  bool isVisible = false;
  Duration duration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    widget._isVisible.addListener(() => setState(() {
          isVisible = widget.isVisible;
        }));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    for (String hkLabel in preferences.quickAccessHotkeys) {
      HotkeyData? data = hotkeys.getHotkey(hkLabel);
      if (data == null) continue;

      buttons.add(Container(
          decoration: const BoxDecoration(
            color: _circleColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              bool menuStaysVisible = hotkeys.trigger(data);
              widget.isVisible = menuStaysVisible;
            },
            icon: Icon(hotkeys.getHotkeyIconFromLabel(data.label)),
            color: _iconColor,
          )));
    }

    return AnimatedContainer(
      duration: duration,
      height: isVisible ? kBottomNavigationBarHeight : 0.0,
      child: Wrap(
        spacing: 5,
        alignment: WrapAlignment.spaceEvenly,
        children: buttons,
      ),
    );
  }
}
