import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  static const Set<String> _ignoreHotkeys = {
    "Controls",
    "Reload NPA",
    "Screenshot",
  };
  void setHotkey(HotkeyData hotkey) {
    if (_ignoreHotkeys.contains(hotkey.label)) return;
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

  Widget getHotkeyIconFromLabel(String hotkey) {
    HotkeyData? data = _hotkeys[hotkey];
    if (data == null) return unknownIcon;
    return getHotkeyIconFromData(data);
  }

  Widget getHotkeyIconFromData(HotkeyData data) {
    return _hotkeyIcons[data.label] ?? unknownIcon;
  }

  // Returns if menu should stay visible (not close)
  bool trigger(HotkeyData hotkey) {
    triggerHotkey.broadcast(hotkey);
    return notCloseMenu.contains(hotkey.label);
  }

  static const Set<String> notCloseMenu = {
    "Timebase",
    "- Territory Brightness",
    "+ Territory Brightness",
    "Time Machine: -24 ticks",
    "Time Machine: +24 ticks",
    "Time Machine: Back",
    "Time Machine: Forward",
    "- Rulers",
    "+ Rulers",
    "- Handicap",
    "+ Handicap",
  };
  static const Widget unknownIcon = Icon(Icons.question_mark);
  static final Map<String, Widget> _hotkeyIcons = {
    //#region NPAM icons
    "Refresh": const Icon(Icons.refresh),
    "NPAM Settings": const Icon(Icons.settings),
    //#endregion
    //#region NPA icons
    "- Handicap": SvgPicture.asset("icons/handicap/handicap_subtract.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
    "+ Handicap": SvgPicture.asset("icons/handicap/handicap_add.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
    "- Rulers": SvgPicture.asset("icons/ruler/ruler_subtract.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
    "+ Rulers": SvgPicture.asset("icons/ruler/ruler_add.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
    "- Territory Brightness": const Icon(Icons.brightness_4_outlined),
    "+ Territory Brightness": const Icon(Icons.brightness_4),
    "Accounting": const Icon(Icons.receipt_long),
    "Activity": const Icon(Icons.ssid_chart),
    "All Combats": const Icon(Icons.electric_bolt),
    "API Keys": const Icon(Icons.api),
    "Colours": const Icon(Icons.palette),
    "Combat Activity": const Icon(Icons.sports_mma),
    "Controls": const Icon(Icons.keyboard),
    "Economists": const Icon(Icons.paid),
    "Empires": const Icon(Icons.auto_awesome),
    "Fleets (short)": const Icon(Icons.rocket),
    "Fleets (long)": const Icon(Icons.rocket_launch),
    "Formal Alliances": const Icon(Icons.groups),
    "Help": const Icon(Icons.help),
    "Home Planets": const Icon(Icons.stars),
    "Merge All": const Icon(Icons.merge),
    "Merge User": const Icon(Icons.call_merge),
    "Next User": const Icon(Icons.skip_next),
    "NPA Menu": const Icon(Icons.menu_open),
    "Open NPA UI": const Icon(Icons.menu),
    "Open Options": const Icon(Icons.settings_applications),
    "Ownership": const Icon(Icons.real_estate_agent),
    "Route Enemy": const Icon(Icons.route),
    "Stars": const Icon(Icons.star),
    "Summary CSV": const Icon(Icons.file_open),
    "Timebase": const Icon(Icons.schedule),
    "Time Machine: -24 ticks": SvgPicture.asset("icons/time_machine/time_back_24.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
    "Time Machine: +24 ticks": SvgPicture.asset("icons/time_machine/time_forward_24.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
    "Time Machine: Back": SvgPicture.asset("icons/time_machine/time_back.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
    "Time Machine: Forward": SvgPicture.asset("icons/time_machine/time_forward.svg", colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
    "Toggle Territory": const Icon(Icons.join_full),
    "Trade Activity": const Icon(Icons.swap_horiz),
    "Trading": const Icon(Icons.swap_horizontal_circle),
    "Whiteout": const Icon(Icons.contrast),
    //#endregion
  };
}
