import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../preferences.dart';

class NPAWebView {
  late final WebViewController _controller;
  late final Preferences prefs;

  WebViewController get controller => _controller;

  late final String _npaJS;
  late final String _npaCSS;

  NPAWebView() {
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            debugPrint('Page finished loading: $url');
            if (url.contains("/game/")) {
              debugPrint('Injecting intel!');
              await _injectCSS(_npaCSS);
              await _injectJS(_npaJS);

              Future.delayed(const Duration(seconds: 1), () async {
                debugPrint("Starting hotkey gathering...");
                await _controller.runJavaScript("NeptunesPride.NPAM.listHotKeys();");
                debugPrint("Hotkeys gathered!");
                //_controller.removeJavaScriptChannel("HotkeyPipe");
              });
              //dynamic jsonData = json.decode(jsReturn);
              //print(jsonData);
              //HotkeyHandler.getInstance().injectHotkeys(jsonData);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (!request.url.startsWith('https://np.ironhelmet.com')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
            prefs.lastVisitedURI = change.url;
          },
        ),
      )
      ..addJavaScriptChannel("NPAMChannel", onMessageReceived: (message) {
        debugPrint(message.message);
      });

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
    _prepareAsyncController();
  }
  Future _prepareAsyncController() async {
    prefs = await Preferences.getInstance();

    String baseURI = prefs.npaInjectURI;
    List<String> assets = await Future.wait([
      _fetchWebAsset(Uri.parse("${baseURI}intel.js")),
      rootBundle.loadString('lib/npam_inject.js'),
      _fetchWebAsset(Uri.parse("${baseURI}intel.css")),
    ]);

    //const String splitAfter = 'console.log("Neptune\'s Pride Agent injection fini.")}()';
    //int asset0idx = assets[0].indexOf(splitAfter) + splitAfter.length;
    //assets[0] = assets[0].substring(0, asset0idx) + ";NeptunesPride.getHotkeys = function() {var hks={};for(var key of u()) {hks[key] = l(key)}return hks}" + assets[0].substring(asset0idx);

    _npaJS = assets[0] + assets[1];
    _npaCSS = assets[2];

    _controller.loadRequest(Uri.parse(prefs.lastVisitedURI));
  }

  Future<String> _fetchWebAsset(Uri uri) async {
    http.Response res = await http.get(uri);
    return utf8.decode(res.bodyBytes);
  }

  Future<void> _injectJS(String js) async {
    await controller.runJavaScript(js);
  }

  Future<void> _injectCSS(String css) async {
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

  void handleHotkey(String hotkey) async {
    if (hotkey.startsWith("NPAM:")) {
      switch (hotkey.substring(5)) {
        case 'refresh':
          _controller.loadRequest(Uri.parse(await _controller.currentUrl() ?? prefs.lastVisitedURI));
          break;

        case 'settings':
          debugPrint("MPAM Settings!");
          break;
      }
    } else {
      await _controller.runJavaScript("Mousetrap.trigger('$hotkey')");
    }
  }
}
