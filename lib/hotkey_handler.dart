import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:neptunes_pride_agent_mobile/typedef/hotkey_data.dart';

class HotkeyHandler with ChangeNotifier {
  static HotkeyHandler? _instance;

  static Event<HotkeyData> triggerHotkey = Event<HotkeyData>();

  final Map<String, HotkeyData> _hotkeys = {
    "Refresh": HotkeyData(key: "NPAM:Refresh", modifier: "", label: "Refresh"),
    //"NPAM Settings": HotkeyData(key: "NPAM:Settings", modifier: "", label: "NPAM Settings"),
  };
  int get count => _hotkeys.length;
  List<HotkeyData> get hotkeys => _hotkeys.values.toList();
  bool _initialFill = false;

  HotkeyHandler._();

  static HotkeyHandler getInstance() {
    _instance ??= HotkeyHandler._();
    return _instance!;
  }

  void setHotkey(HotkeyData hotkey) {
    _hotkeys[hotkey.label] = hotkey;
    debugPrint("Recorded ${hotkey.hotkey} as ${hotkey.label}");
    if (!_hotkeyIcons.containsKey(hotkey.label)) {
      debugPrint("${hotkey.label} has no icon!");
    }
    if (_initialFill) notifyListeners();
  }

  void passFinished() {
    _initialFill = true;
    notifyListeners();
  }

  HotkeyData? getHotkey(String hotkey) {
    return _hotkeys[hotkey];
  }

  IconData getHotkeyIconFromLabel(String hotkey) {
    HotkeyData? data = _hotkeys[hotkey];
    if (data == null) return unknownIcon;
    return getHotkeyIconFromData(data);
  }

  IconData getHotkeyIconFromData(HotkeyData data) {
    return _hotkeyIcons[data.label] ?? unknownIcon;
  }

  // Returns if menu should stay visible (not close)
  bool trigger(HotkeyData hotkey) {
    triggerHotkey.broadcast(hotkey);
    return notCloseMenu.contains(hotkey.label);
  }

  static const Set<String> notCloseMenu = {
    "Timebase",
  };
  static const IconData unknownIcon = Icons.question_mark;
  static const Map<String, IconData> _hotkeyIcons = {
    "Colours": Icons.palette,
    "Timebase": Icons.schedule,
    "Refresh": Icons.refresh,
    "Open Options": Icons.settings_applications,
    "NPAM Settings": Icons.settings,
  };
}
