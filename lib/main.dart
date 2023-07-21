import 'package:flutter/material.dart';
import 'package:neptunes_pride_agent_mobile/preferences.dart';
import 'package:neptunes_pride_agent_mobile/widgets/npa_mobile.dart';

import 'hotkey_handler.dart';

late HotkeyHandler hotkeys;
late Preferences preferences;

void main() async {
  // pre-run warmup
  WidgetsFlutterBinding.ensureInitialized();

  // setup
  hotkeys = HotkeyHandler.getInstance();
  preferences = await Preferences.getInstance();

  runApp(const MaterialApp(
    home: NPAMobile(),
  ));
}
