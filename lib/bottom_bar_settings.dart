import 'package:flutter/material.dart';

enum _BarButtonData {
  refresh("Refresh", Icons.refresh, "f5"),
  colours("Colours", Icons.palette, "ctrl+a"),
  ;

  const _BarButtonData(this.label, this.iconData, this.hotkey);

  final String label;
  final IconData iconData;
  final String hotkey;
}

class BottomBarSettings {
  BottomBarSettings();

  late List<_BarButtonData> _buttons = [];

  void _getButtonData() {
    _buttons = [
      _BarButtonData.refresh,
      _BarButtonData.colours,
    ];
  }

  List<BottomNavigationBarItem> getNavItems() {
    if (_buttons.isEmpty) {
      _getButtonData();
    }

    List<BottomNavigationBarItem> items = [];
    for (_BarButtonData data in _buttons) {
      items.add(BottomNavigationBarItem(
        icon: Icon(data.iconData),
        label: data.label,
      ));
    }
    return items;
  }

  void trigger(int tapIndex) {
    String hotkey = _buttons[tapIndex].hotkey;
    debugPrint("Button: $hotkey");
  }
}
