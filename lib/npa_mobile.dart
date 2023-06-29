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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebViewWidget(controller: view.controller),
    );
  }
}
