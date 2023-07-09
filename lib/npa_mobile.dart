import 'package:flutter/material.dart';
import 'package:neptunes_pride_agent_mobile/bottom_bar_settings.dart';
import 'package:neptunes_pride_agent_mobile/hideable.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'npa_webview.dart';

class NPAMobile extends StatefulWidget {
  const NPAMobile({super.key});

  @override
  State<NPAMobile> createState() => _NPAMobileState();
}

class _NPAMobileState extends State<NPAMobile> {
  late final NPAWebView view;
  final BottomBarSettings barSettings = BottomBarSettings();
  late final Hideable navBar;

  @override
  void initState() {
    super.initState();
    view = NPAWebView();

    navBar = Hideable(
      child: Wrap(
        children: <Widget>[
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.blue,
            fixedColor: Colors.white,
            unselectedItemColor: Colors.white,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
              ...barSettings.getNavItems(),
            ],
          ),
        ],
      ),
    );
  }

  void buttonPress() {
    navBar.isVisible.value = !navBar.isVisible.value;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewWidget(controller: view.controller),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: navBar.childHeight + 10),
          child: FloatingActionButton(
            onPressed: buttonPress,
            mini: true,
            tooltip: "Quick Actions",
            backgroundColor: Colors.black.withOpacity(1.0),
            child: Image.asset("Logo/Logo-192x192.png"),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
        bottomNavigationBar: navBar,
      ),
    );
  }
}
