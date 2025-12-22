import 'package:flutter/material.dart';
import 'package:neptunes_pride_agent_mobile/preferences.dart';

enum _BarButtonData {
  refresh("Refresh", Icons.refresh, "NPAM:refresh", true),
  colours("Colours", Icons.palette, "ctrl+a", true),
  timebase("Timebase", Icons.schedule, "%", false),
  //settings("Settings", Icons.settings, "NPAM:settings", true),
  npasettings("NPA Options", Icons.settings_applications, "ctrl+`", true),
  ;

  const _BarButtonData(this.label, this.iconData, this.hotkey, this.closeMenu);

  final String label;
  final IconData iconData;
  final String hotkey;
  final bool closeMenu;
}

typedef OnClickCallback = void Function(String label, bool hideBar);

class BottomBarSettings {
  BottomBarSettings() {
    init();
  }

  void init() async {
    Preferences prefs = await Preferences.getInstance();
    showLabels.value = prefs.labelsVisible;
  }

  final ValueNotifier<bool> showLabels = ValueNotifier<bool>(true);

  late List<_BarButtonData> _buttons = [];

  void _getButtonData() {
    _buttons = [
      _BarButtonData.npasettings,
      _BarButtonData.refresh,
      _BarButtonData.colours,
      _BarButtonData.timebase,
    ];
  }

  static const Color _barCircleColor = Color.fromARGB(255, 25, 28, 65);
  static const Color _iconColor = Colors.white;
  static const TextStyle _textStyle = TextStyle(color: _iconColor);

  double _maxSize = 0.0;
  double get maxSize => _maxSize;

  List<Widget> getNavItems(OnClickCallback onClick) {
    if (_buttons.isEmpty) {
      _getButtonData();
    }
    List<Widget> items = [];

    //if (!_buttons.contains(_BarButtonData.settings)) _buttons.insert(0, _BarButtonData.settings);

    for (_BarButtonData data in _buttons) {
      Size labelSize = _textSize(data.label, _textStyle);
      if (labelSize.width > _maxSize) _maxSize = labelSize.width;
    }

    for (_BarButtonData data in _buttons) {
      items.add(
        GestureDetector(
          onTap: () => onClick(data.hotkey, data.closeMenu),
          child: Container(
            decoration: const BoxDecoration(
              color: _barCircleColor,
              shape: BoxShape.circle,
            ),
            width: _maxSize,
            height: _maxSize,
            child: ValueListenableBuilder(
                valueListenable: showLabels,
                builder: (BuildContext context, bool value, Widget? child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        data.iconData,
                        color: _iconColor,
                      ),
                      if (value)
                        Text(
                          data.label,
                          style: _textStyle,
                        ),
                    ],
                  );
                }),
          ),
        ),
      );
    }
    return items;
  }

  // Here it is!
  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
