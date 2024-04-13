import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neptunes_pride_agent_mobile/hotkey_handler.dart';
import 'package:neptunes_pride_agent_mobile/main.dart';
import 'package:neptunes_pride_agent_mobile/typedef/channel_message.dart';
import 'package:neptunes_pride_agent_mobile/typedef/hotkey_data.dart';
import 'package:webview_flutter/webview_flutter.dart';

final Key webviewKey = GlobalKey(debugLabel: "webviewKey");

class NPWebview extends StatelessWidget {
  final WebViewController _wvc = WebViewController();
  late final NPWebviewController controller;
  NPWebview({super.key}) {
    controller = NPWebviewController(_wvc);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _wvc, key: webviewKey);
  }
}

class NPWebviewController {
  final WebViewController _controller;
  Event<ChannelMessage> channelRecv = Event<ChannelMessage>();

  final injections = {
    "js": [],
    "css": [],
  };

  NPWebviewController(this._controller) {
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setBackgroundColor(const Color(0x00000000));
    _controller.addJavaScriptChannel("NPAMChannel", onMessageReceived: (message) => channelRecv.broadcast(ChannelMessage(message.message)));
    _controller.setNavigationDelegate(NavigationDelegate(
      onProgress: _onProgress,
      onPageStarted: _onPageStarted,
      onWebResourceError: _onWebResourceError,
      onNavigationRequest: _onNavigationRequest,
      onUrlChange: _onURLChange,
      onPageFinished: _onPageFinished,
    ));
    channelRecv.subscribe((args) {
      if (args == null) return;
      Map<String, dynamic> jsonWrapper = json.decode(args.message);
      switch (jsonWrapper['type']) {
        case 'string':
          debugPrint(jsonWrapper['data']);
          break;

        case 'json':
          debugPrint(jsonWrapper['data']);
          break;

        case 'hotkey':
          debugPrint("Setting hotkey");
          HotkeyData hotkey = HotkeyData.fromJson(json.decode(jsonWrapper['data']));
          hotkeys.setHotkey(hotkey);
          break;

        default:
          debugPrint("Unknown type ${jsonWrapper['type']}");
          debugPrint(jsonWrapper['data']);
      }
    });

    HotkeyHandler.triggerHotkey.subscribe((args) {
      if (args == null) return;
      if (args.hotkey.startsWith("NPAM:")) {
        switch (args.hotkey.substring(5).toUpperCase()) {
          case "REFRESH":
            _controller.reload();
            break;

          default:
            return;
        }
      }
      _triggerHotkey(args);
    });

    debugPrint("Set up controller");
    debugPrint("Calling async init...");
    _init();
  }

  Future<void> _init() async {
    debugPrint("Running async init...");

    // Load injections
    debugPrint("Loading injections...");
    String baseURI = preferences.npaInjectURI;
    List<String> assets = await Future.wait([
      _fetchAsset("${baseURI}intel.js"),
      _fetchAsset('lib/npam_inject.js'),
      _fetchAsset("${baseURI}intel.css"),
    ]);
    injections["js"]?.add(assets[0]);
    injections["js"]?.add(assets[1]);
    injections["css"]?.add(assets[2]);
    debugPrint("Injections loaded!");

    debugPrint("loading page: ${preferences.lastVisitedURI}");
    _controller.loadRequest(Uri.parse(preferences.lastVisitedURI));
  }

  //#region NavigationDelegate
  void _onProgress(int progress) {
    debugPrint('WebView is loading (progress : $progress%)');
  }

  void _onPageStarted(String url) {
    debugPrint('Page started loading: $url');
  }

  void _onWebResourceError(WebResourceError error) {
    debugPrint('''
Page resource error:
  url: ${error.url}
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
  }

  FutureOr<NavigationDecision> _onNavigationRequest(NavigationRequest request) {
    if (!request.url.startsWith('https://np.ironhelmet.com')) {
      debugPrint('blocking navigation to ${request.url}');
      return NavigationDecision.prevent;
    }
    debugPrint('allowing navigation to ${request.url}');
    return NavigationDecision.navigate;
  }

  void _onURLChange(UrlChange change) {
    debugPrint('url change to ${change.url}');
    preferences.lastVisitedURI = change.url;
  }

  void _onPageFinished(String url) async {
    debugPrint('Page finished loading: $url');
    if (!url.contains("/game/")) return;
    await _injectIntel();
  }
  //#endregion

  Future<void> _injectIntel() async {
    debugPrint('Injecting intel!');

    List<Future<void>> futures = [];
    for (String js in injections['js']!) {
      futures.add(_controller.runJavaScript(js));
    }
    for (String css in injections['css']!) {
      futures.add(injectCSS(css));
    }
    await Future.wait(futures);

    Future.delayed(const Duration(seconds: 1), () async {
      await _controller.runJavaScript("NeptunesPride.NPAM.listHotkeys();");
      hotkeys.passFinished();
      //_controller.removeJavaScriptChannel("HotkeyPipe");
    });
  }

  Future<String> _fetchAsset(String location) async {
    if (location.startsWith("http://") || location.startsWith("https://")) {
      // web asset
      http.Response res = await http.get(Uri.parse(location));
      return utf8.decode(res.bodyBytes);
    } else {
      // local asset
      return rootBundle.loadString('lib/npam_inject.js');
    }
  }

  Future<void> injectCSS(String css) async {
    var bytes = utf8.encode(css);
    var base64Str = base64.encode(bytes);
    await _controller.runJavaScript("""
      (function() {
      var parent = document.getElementsByTagName('head').item(0);
      var style = document.createElement('style');
      style.type = 'text/css';
      // Tell the browser to BASE64-decode the string into your script !!!
      style.innerHTML = window.atob('$base64Str');
      parent.appendChild(style)
      })();
    """);
  }

  Future<void> _triggerHotkey(HotkeyData hotkey) async {
    await _controller.runJavaScript("{Mousetrap.trigger(\"${hotkey.hotkey}\")}");
  }
}
