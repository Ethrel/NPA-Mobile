import 'package:flutter/material.dart';
import 'package:neptunes_pride_agent_mobile/dead code/bottom_bar_settings.dart';
import 'package:neptunes_pride_agent_mobile/dead code/hideable.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:neptunes_pride_agent_mobile/dead code/npa_webview.dart';

class NPAMobile extends StatefulWidget {
  const NPAMobile({super.key});

  @override
  State<NPAMobile> createState() => _NPAMobileState();
}

class _NPAMobileState extends State<NPAMobile> {
  late final NPAWebView view;
  final BottomBarSettings barSettings = BottomBarSettings();
  late Hideable navBar;

  @override
  void initState() {
    super.initState();
    view = NPAWebView();
  }

  void showHideBar() {
    //navBar.isVisible = !navBar.isVisible;
  }

  void _handleHotkey(String hotkey, bool hideBar) {
    //view.handleHotkey(hotkey);
    if (hideBar) showHideBar();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> navBarItems = barSettings.getNavItems(_handleHotkey);
    navBar = Hideable(
        childHeight: barSettings.maxSize,
        child: Align(
          alignment: Alignment.center,
          child: Wrap(
            spacing: 20,
            children: [...navBarItems],
          ),
        ));
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            WebViewWidget(controller: view.controller),
            Align(
              alignment: Alignment.bottomCenter,
              child: navBar,
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50), //navBar.childHeight + 10),
          child: FloatingActionButton(
            onPressed: showHideBar,
            mini: true,
            tooltip: "Quick Actions",
            backgroundColor: Colors.black.withValues(alpha: 1.0),
            child: Image.asset("Logo/Logo-192x192.png"),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        //bottomNavigationBar: navBar,
      ),
    );
  }
}
