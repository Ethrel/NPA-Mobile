import 'package:flutter/material.dart';
import 'package:neptunes_pride_agent_mobile/widgets/hotkey_bar.dart';
import 'package:neptunes_pride_agent_mobile/widgets/np_webview.dart';

class NPAMobile extends StatelessWidget {
  const NPAMobile({super.key});

  @override
  Widget build(BuildContext context) {
    HotkeyBar hotkeyBar = HotkeyBar();
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            NPWebview(),
            Align(
              alignment: Alignment.bottomCenter,
              child: hotkeyBar,
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50), //navBar.childHeight + 10),
          child: FloatingActionButton(
            onPressed: hotkeyBar.toggleVisible,
            mini: true,
            tooltip: "Quick Actions",
            backgroundColor: Colors.black.withOpacity(1.0),
            child: Image.asset("Logo/Logo-192x192.png"),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      ),
    );
  }
}
