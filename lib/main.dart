import "package:flutter/material.dart";
import 'package:flutter/services.dart';

import 'npa_mobile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MaterialApp(
    home: NPAMobile(),
  ));
}
