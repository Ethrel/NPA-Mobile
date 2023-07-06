import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'npa_webview.dart';

class NPAMobile extends StatefulWidget {
  const NPAMobile({super.key});

  @override
  State<NPAMobile> createState() => _NPAMobileState();
}

class _NPAMobileState extends State<NPAMobile> {
  late final NPAWebView view;

  @override
  void initState() {
    super.initState();
    view = NPAWebView();
  }

  void ButtonPress() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewWidget(controller: view.controller),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: FloatingActionButton(
            onPressed: ButtonPress,
            mini: true,
            tooltip: "Quick Actions",
            backgroundColor: Colors.black.withOpacity(1.0),
            child: Image.asset("Logo/Logo-192x192.png"),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      ),
    );
  }
}
