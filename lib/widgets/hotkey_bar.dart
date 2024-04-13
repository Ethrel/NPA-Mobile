import 'package:flutter/material.dart';
import 'package:neptunes_pride_agent_mobile/main.dart';
import 'package:neptunes_pride_agent_mobile/typedef/hotkey_data.dart';

class HotkeyBar extends StatefulWidget {
  HotkeyBar({super.key});

  final ValueNotifier<bool> _isVisible = ValueNotifier(false);
  bool get isVisible => _isVisible.value;
  set isVisible(bool visible) => _isVisible.value = visible;

  void toggleVisible() {
    isVisible = !isVisible;
  }

  @override
  State<StatefulWidget> createState() => _HotkeyBarState();
}

class _HotkeyBarState extends State<HotkeyBar> {
  static const Color _circleColor = Color.fromARGB(255, 25, 28, 65);
  static const Color _iconColor = Colors.white;

  bool isVisible = false;
  Duration duration = const Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    widget._isVisible.addListener(() => setState(() {
          isVisible = widget.isVisible;
          if (isVisible == false) extraIconsHeight = 0.0;
        }));
    hotkeys.addListener(() {
      _buildAllHotkeys();
      _buildQuickAccessHotkeys();
    });
    preferences.updateQuickAccessHotkeys.subscribe((args) {
      _buildQuickAccessHotkeys();
      _buildAllHotkeys();
    });

    _buildAllHotkeys();
    _buildQuickAccessHotkeys();
  }

  // Reload hotkey info when Hot Reloading app (Dev stuff)
  @override
  void reassemble() {
    super.reassemble();
    _buildAllHotkeys();
    _buildQuickAccessHotkeys();
  }

  final List<Widget> _quickAccessHotkeys = [];
  void _buildQuickAccessHotkeys() {
    _quickAccessHotkeys.clear();
    for (String hkLabel in preferences.quickAccessHotkeys) {
      HotkeyData? data = hotkeys.getHotkey(hkLabel);
      if (data == null) continue;

      _quickAccessHotkeys.add(_buildButton(data));
    }
  }

  final ValueNotifier<bool> _hotkeyWatch = ValueNotifier(true);
  final List<Widget> _allHotkeyButtons = [];
  void _buildAllHotkeys() {
    _allHotkeyButtons.clear();
    for (HotkeyData hotkey in hotkeys.hotkeys) {
      if (preferences.quickAccessHotkeys.contains(hotkey.label)) continue;
      _allHotkeyButtons.add(_buildButton(hotkey, showLabel: true));
    }
    setState(() {
      bool updateHeight = extraIconsHeight == maxExtraHeight;
      maxExtraHeight = (_allHotkeyButtons.length / 10.0).ceil() * 80;
      if (updateHeight) extraIconsHeight = maxExtraHeight;
      _hotkeyWatch.value = !_hotkeyWatch.value;
    });
  }

  double extraIconsHeight = 0.0;
  int iconsPerRow = 10;
  double maxExtraHeight = 0.0;
  double dragTotalDelta = 0.0;
  void _dragStart(DragStartDetails details) => dragTotalDelta = 0.0;

  void _dragUpdate(DragUpdateDetails details) {
    if (dragTotalDelta.sign != details.delta.direction.sign) {
      dragTotalDelta = 0.0;
    }
    dragTotalDelta += details.delta.direction;
    setState(() {
      extraIconsHeight = (extraIconsHeight - details.delta.direction).clamp(0.0, maxExtraHeight).toDouble();
    });
  }

  void _dragEnd(DragEndDetails details) {
    if (dragTotalDelta < 0) {
      setState(() {
        extraIconsHeight = maxExtraHeight;
      });
    }
    if (dragTotalDelta > 0) {
      setState(() {
        extraIconsHeight = 0.0;
      });
    }
  }

  Widget _buildButton(HotkeyData data, {bool showLabel = false}) {
    Widget hkIco = hotkeys.getHotkeyIconFromData(data);
    Widget icon = Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: _circleColor,
          shape: BoxShape.circle,
        ),
        child: Draggable(
            data: data,
            feedback: hkIco,
            onDragCompleted: () {
              debugPrint("Dragged hotkey ${data.label}");
            },
            child: IconButton(
              onPressed: () {
                bool menuStaysVisible = hotkeys.trigger(data);
                widget.isVisible = menuStaysVisible;
              },
              icon: hkIco,
              color: _iconColor,
            )));
    if (showLabel) {
      return Column(
        children: [
          icon,
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _iconColor,
              backgroundColor: _circleColor,
            ),
          ),
        ],
      );
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      height: isVisible ? 75 + extraIconsHeight : 0.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onVerticalDragStart: _dragStart,
            onVerticalDragUpdate: _dragUpdate,
            onVerticalDragEnd: _dragEnd,
            child: Container(
              height: 15,
              width: 50,
              decoration: BoxDecoration(
                color: _circleColor,
                border: Border.all(color: Colors.black, width: 0.0),
                borderRadius: const BorderRadius.all(Radius.elliptical(20, 15)),
              ),
              child: null, //Text(''),
            ),
          ),
          AnimatedContainer(
            duration: duration,
            height: extraIconsHeight,
            child: DragTarget(
              builder: (context, candidateData, rejectedData) => ValueListenableBuilder(
                valueListenable: _hotkeyWatch,
                builder: (context, value, child) {
                  return GridView(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: iconsPerRow, mainAxisExtent: 80),
                    children: _allHotkeyButtons,
                  );
                },
              ),
              onWillAcceptWithDetails: (rawData) {
                HotkeyData? hotkey = rawData as HotkeyData?;
                if (hotkey == null) return false;
                if (!preferences.quickAccessHotkeys.contains(hotkey.label)) return false;
                debugPrint("Would accept ${hotkey.label}");
                return true;
              },
              onAcceptWithDetails: (DragTargetDetails<HotkeyData> hotkey) {
                debugPrint("Accepting ${hotkey.data.label}");
                preferences.quickAccessHotkeys = preferences.quickAccessHotkeys..remove(hotkey.data.label);
                _buildQuickAccessHotkeys();
                _buildAllHotkeys();
                setState(() {});
              },
            ),
          ),
          DragTarget(
            builder: (context, candidateData, rejectedData) {
              return Wrap(
                spacing: 5,
                alignment: WrapAlignment.spaceEvenly,
                children: _quickAccessHotkeys,
              );
            },
            onWillAcceptWithDetails: (rawData) {
              HotkeyData? hotkey = rawData as HotkeyData?;
              if (hotkey == null) return false;
              if (preferences.quickAccessHotkeys.contains(hotkey.label)) return false;
              debugPrint("Would accept ${hotkey.label}");
              return true;
            },
            onAcceptWithDetails: (DragTargetDetails<HotkeyData> hotkey) {
              debugPrint("Accepting ${hotkey.data.label}");
              preferences.quickAccessHotkeys = preferences.quickAccessHotkeys..add(hotkey.data.label);
              _buildQuickAccessHotkeys();
              _buildAllHotkeys();
            },
          ),
        ],
      ),
    );
  }
}
